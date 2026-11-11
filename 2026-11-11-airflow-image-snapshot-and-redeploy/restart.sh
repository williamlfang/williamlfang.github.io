#!/bin/bash
## =============================================================================
## /app/restart.sh: keeps the Airflow scheduler and webserver running in the container.
##
##   restart.sh run       container entrypoint: start both, restart either one if it exits
##   restart.sh           (via docker exec) restart both under the running supervisor;
##                        refuses while tasks are running, add --force to do it anyway
##   restart.sh status    exit 0 only if the scheduler is alive and the webserver is healthy
##
## build.airflow.sh bakes this file into the image; run.sh starts the container with `run`.
## =============================================================================
set -u
export AIRFLOW_HOME=${AIRFLOW_HOME:-/app}
cd "$AIRFLOW_HOME" || exit 1

PIDFILE=$AIRFLOW_HOME/restart.sh.pid
SCHED_LOG=$AIRFLOW_HOME/airflow-scheduler.out
PORT=8080

log() { echo "[$(date '+%F %T')] restart.sh: $*"; }

## pid of the running supervisor, or nothing (the pid file survives container restarts)
supervisor_pid() {
    local pid
    pid=$(cat "$PIDFILE" 2>/dev/null) || return 1
    [ -n "$pid" ] && [ "$pid" != "$$" ] && grep -qa 'restart.sh' /proc/"$pid"/cmdline 2>/dev/null && echo "$pid"
}

## "<n> running/queued: dag.task (state), ..." for task instances that a restart would kill
active_tasks() {
    python3 - 2>/dev/null <<'EOF'
from airflow.utils.session import create_session
from airflow.models import TaskInstance as TI
with create_session() as s:
    tis = s.query(TI).filter(TI.state.in_(["running", "queued"])).all()
    for t in tis:
        print(f"{t.dag_id} {t.task_id} {t.state}")
EOF
}

status() {
    local ok=0 h
    if pgrep -f 'airflow scheduler' >/dev/null; then
        airflow jobs check --job-type SchedulerJob --local --limit 5 --allow-multiple >/dev/null 2>&1 \
            && echo "scheduler: alive" || { echo "scheduler: process up, no live SchedulerJob heartbeat yet"; ok=1; }
    else
        echo "scheduler: not running"; ok=1
    fi
    h=$(curl -s --noproxy '*' -m 5 "http://localhost:$PORT/health")
    if echo "$h" | grep -q '"metadatabase": {"status": "healthy"}'; then
        echo "webserver: healthy ($h)"
    else
        echo "webserver: not healthy (${h:-no response})"; ok=1
    fi
    return $ok
}

## ---------------------------------------------------------------------------
## supervisor
SCHED=; WEB=; STOPPING=0; RESTART=0

start_scheduler() {
    rm -f "$AIRFLOW_HOME"/airflow-scheduler.pid
    airflow scheduler >> "$SCHED_LOG" 2>&1 &
    SCHED=$!; SCHED_AT=$(date +%s)
    log "scheduler started, pid $SCHED (log $SCHED_LOG)"
}

start_webserver() {
    rm -f "$AIRFLOW_HOME"/airflow-webserver.pid "$AIRFLOW_HOME"/airflow-webserver-monitor.pid
    airflow webserver --port $PORT &
    WEB=$!; WEB_AT=$(date +%s)
    log "webserver started, pid $WEB"
}

## SIGTERM both, wait up to 60s, then SIGKILL whatever is left
stop_all() {
    local i
    log "stopping scheduler ($SCHED) and webserver ($WEB)"
    kill -TERM $SCHED $WEB 2>/dev/null
    for i in $(seq 60); do
        kill -0 $SCHED 2>/dev/null || kill -0 $WEB 2>/dev/null || break
        sleep 1
    done
    kill -0 $SCHED 2>/dev/null && { log "scheduler still up after 60s, SIGKILL"; kill -KILL $SCHED; }
    kill -0 $WEB 2>/dev/null && { log "webserver still up after 60s, SIGKILL"; kill -KILL $WEB; }
    pkill -KILL -f '^gunicorn: ' 2>/dev/null   # webserver workers left behind
    wait 2>/dev/null
}

supervise() {
    local now
    if [ -n "$(supervisor_pid)" ]; then
        log "a supervisor is already running (pid $(supervisor_pid)); use 'restart.sh' to restart it"
        exit 1
    fi
    echo $$ > "$PIDFILE"
    trap 'STOPPING=1' TERM INT
    trap 'RESTART=1' HUP

    start_scheduler
    start_webserver
    while :; do
        sleep 5 & wait $!          # wait, not plain sleep, so traps fire at once
        if [ $STOPPING = 1 ]; then
            stop_all; rm -f "$PIDFILE"; log "stopped"; exit 0
        fi
        if [ $RESTART = 1 ]; then
            RESTART=0; log "restart requested"
            stop_all; start_scheduler; start_webserver
            continue
        fi
        now=$(date +%s)
        if ! kill -0 $SCHED 2>/dev/null; then
            wait $SCHED; log "scheduler exited (code $?)"
            [ $((now - SCHED_AT)) -lt 60 ] && { log "it lived under 60s, waiting 30s before restarting"; sleep 30; }
            start_scheduler
        fi
        if ! kill -0 $WEB 2>/dev/null; then
            wait $WEB; log "webserver exited (code $?)"
            [ $((now - WEB_AT)) -lt 60 ] && { log "it lived under 60s, waiting 30s before restarting"; sleep 30; }
            start_webserver
        fi
    done
}

## ---------------------------------------------------------------------------
## restart via docker exec
restart_services() {
    local force=${1:-} sup tasks i
    sup=$(supervisor_pid) || { log "no supervisor running (this container was not started with 'restart.sh run'); use run.sh on the host"; exit 1; }
    tasks=$(active_tasks)
    if [ -n "$tasks" ]; then
        log "$(echo "$tasks" | wc -l) task(s) are running/queued; restarting the scheduler kills their runners:"
        echo "$tasks" | sed 's/^/    /'
        [ "$force" = "--force" ] || { log "not restarting; add --force to do it anyway"; exit 1; }
        log "--force given, restarting anyway"
    fi
    kill -HUP "$sup"
    log "asked supervisor $sup to restart; waiting for the services to come back"
    sleep 15
    for i in $(seq 24); do
        status >/dev/null && { status; log "airflow is back"; exit 0; }
        sleep 5
    done
    status; log "airflow did not come back within 2 minutes"; exit 1
}

case "${1:-}" in
    run)          supervise ;;
    status)       status ;;
    ""|--force)   restart_services "${1:-}" ;;
    *)            sed -n '3,9p' "$0"; exit 2 ;;
esac
