#!/bin/bash
## =============================================================================
## run.sh: recreate the `airflow` container on the Airflow host from an image built by build.airflow.sh.
## Run it on the Airflow host itself, as the deploy user.
##
##   ./run.sh TAG [--from local|tarball|registry] [--force] [--dry-run] [--no-rollback]
##
##   TAG            image tag, e.g. 20261111T171500 (run without TAG to list them)
##   --from         where the image comes from (default: local image if present,
##                  else $TARBALL_DIR/airflow-TAG.tar.gz if present, else the registry)
##   --force        recreate even while tasks are running/queued (their runners die;
##                  trade containers keep running, but the tasks need re-adopting)
##   --dry-run      show the plan and the docker run command, change nothing
##   --no-rollback  keep the new container even if it fails the health check
##
## The new container gets the running container's mounts, ports, hostname, restart policy
## and AIRFLOW env (saved to $DEPLOY_ROOT/<time>/airflow.env, mode 600), and runs
## `/app/restart.sh run`, which keeps the scheduler and webserver up. The old container is
## kept stopped as airflow-prev-<time>; if the new one is unhealthy it is put back.
## =============================================================================
set -euo pipefail

CONTAINER=${CONTAINER:-airflow}
REPO=${REPO:-192.168.1.162:5000/airflow}
TARBALL_DIR=${TARBALL_DIR:-/data/docker-images/airflow}
DEPLOY_ROOT=${DEPLOY_ROOT:-$HOME/airflow-deploy}
HEALTH_TIMEOUT=${HEALTH_TIMEOUT:-300}
KEEP_PREV=${KEEP_PREV:-3}
REQUIRED_MOUNTS="/app/dags /app/logs /shared /data /var/run/docker.sock"

TAG=; FROM=auto; FORCE=0; DRY=0; ROLLBACK=1
while [ $# -gt 0 ]; do
    case $1 in
        --from)        FROM=${2:?--from needs local, tarball or registry}; shift ;;
        --force)       FORCE=1 ;;
        --dry-run)     DRY=1 ;;
        --no-rollback) ROLLBACK=0 ;;
        -h|--help)     awk 'NR>2 && /^## ====/{exit} NR>2' "$0"; exit 0 ;;
        -*)            echo "unknown option $1" >&2; exit 2 ;;
        *)             TAG=$1 ;;
    esac
    shift
done
if [ -z "$TAG" ]; then
    awk 'NR>2 && /^## ====/{exit} NR>2' "$0"
    echo "local images:"
    docker images --format '{{.Tag}}\t{{.CreatedSince}}' "$REPO" | sed 's/^/  /'   # newest first
    echo "tarballs in $TARBALL_DIR:"
    ls -1t "$TARBALL_DIR"/airflow-*.tar.gz 2>/dev/null | sed -E 's|.*/airflow-(.*)\.tar\.gz$|  \1|'
    exit 2
fi
IMAGE=$REPO:$TAG
TARBALL=$TARBALL_DIR/airflow-$TAG.tar.gz
TS=$(date +%Y%m%dT%H%M%S)
DIR=$DEPLOY_ROOT/$TS
PREV=$CONTAINER-prev-$TS

log() { echo "[$(date '+%F %T')] $*"; }
die() { log "ERROR: $*"; exit 1; }

exec 9>/tmp/airflow-run.lock
flock -n 9 || die "another run.sh is running"
mkdir -p "$DIR"; chmod 700 "$DEPLOY_ROOT" "$DIR"
exec > >(tee -a "$DIR/run.log") 2>&1
log "deploying $IMAGE as $CONTAINER (log $DIR/run.log)"

## -----------------------------------------------------------------------------
## 1. the image
case $FROM in
    auto)
        if docker image inspect "$IMAGE" >/dev/null 2>&1; then FROM=local
        elif [ -f "$TARBALL" ]; then FROM=tarball
        else FROM=registry; fi ;;
    local|tarball|registry) ;;
    *) die "--from must be local, tarball or registry" ;;
esac
log "image source: $FROM"
if [ $DRY = 0 ]; then
    case $FROM in
        local)
            docker image inspect "$IMAGE" >/dev/null 2>&1 || die "no local image $IMAGE" ;;
        tarball)
            [ -f "$TARBALL" ] || die "no tarball $TARBALL"
            if [ -f "$TARBALL.sha256" ]; then
                (cd "$TARBALL_DIR" && sha256sum -c --quiet "airflow-$TAG.tar.gz.sha256") || die "checksum mismatch for $TARBALL"
            fi
            log "loading $TARBALL"
            gunzip -c "$TARBALL" | docker load
            docker image inspect "$IMAGE" >/dev/null 2>&1 || die "$TARBALL did not contain $IMAGE" ;;
        registry)
            log "pulling $IMAGE"
            docker pull "$IMAGE" | tail -2 ;;
    esac
    docker run --rm --entrypoint test "$IMAGE" -x /app/restart.sh \
        || die "$IMAGE has no /app/restart.sh; it was not built by build.airflow.sh"
fi

## -----------------------------------------------------------------------------
## 2. the current container's settings (or the last saved ones if it is gone)
if docker inspect "$CONTAINER" > "$DIR/inspect.json" 2>/dev/null; then
    SRC="container $CONTAINER"
    umask 077
    jq -r '.[0].Config.Env[]' "$DIR/inspect.json" | grep -E '^(AIRFLOW|TZ=|LANG=)' > "$DIR/airflow.env"
    umask 022
else
    LAST=$(ls -1d "$DEPLOY_ROOT"/*/ 2>/dev/null | grep -v "$TS" | while read -r d; do
        [ -s "$d/inspect.json" ] && [ -s "$d/airflow.env" ] && echo "$d"; done | tail -1)
    [ -n "$LAST" ] || die "no container $CONTAINER and no saved settings in $DEPLOY_ROOT"
    cp "$LAST/inspect.json" "$LAST/airflow.env" "$DIR/"
    SRC="saved settings $LAST"
fi
log "settings from $SRC"
grep -q '^AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=.\+' "$DIR/airflow.env" || die "no AIRFLOW__DATABASE__SQL_ALCHEMY_CONN in the env"

ARGS=(-d --name "$CONTAINER" --init -w /app)
ARGS+=(--hostname "$(jq -r '.[0].Config.Hostname' "$DIR/inspect.json")")
RP=$(jq -r '.[0].HostConfig.RestartPolicy | if .Name == "on-failure" then "on-failure:\(.MaximumRetryCount)" elif .Name == "" or .Name == "no" then "unless-stopped" else .Name end' "$DIR/inspect.json")
ARGS+=(--restart "$RP")
while read -r p; do ARGS+=(-p "$p"); done < <(jq -r '.[0].HostConfig.PortBindings // {} | to_entries[] | .key as $c | .value[] |
    (if .HostIp != "" then "\(.HostIp):" else "" end) + "\(.HostPort):\($c | sub("/tcp$"; ""))"' "$DIR/inspect.json")
while read -r b; do ARGS+=(-v "$b"); done < <(jq -r '.[0].HostConfig.Binds[]?' "$DIR/inspect.json")
while read -r h; do ARGS+=(--add-host "$h"); done < <(jq -r '.[0].HostConfig.ExtraHosts[]?' "$DIR/inspect.json")
[ "$(jq -r '.[0].HostConfig.Privileged' "$DIR/inspect.json")" = true ] && ARGS+=(--privileged)
SHM=$(jq -r '.[0].HostConfig.ShmSize' "$DIR/inspect.json")
[ "$SHM" != 67108864 ] && [ "$SHM" != 0 ] && ARGS+=(--shm-size "$SHM")
NET=$(jq -r '.[0].HostConfig.NetworkMode' "$DIR/inspect.json")
case $NET in default|bridge) ;; *) ARGS+=(--network "$NET") ;; esac
ARGS+=(--env-file "$DIR/airflow.env" --entrypoint /app/restart.sh "$IMAGE" run)

MISSING=
for m in $REQUIRED_MOUNTS; do
    jq -e --arg m "$m" '[.[0].HostConfig.Binds[]? | split(":")[1]] | index($m)' "$DIR/inspect.json" >/dev/null || MISSING="$MISSING $m"
done
[ -z "$MISSING" ] || die "the container settings lack required mounts:$MISSING (DAGs/tasks break without them)"
HOST_PORT=$(jq -r '.[0].HostConfig.PortBindings["8080/tcp"][0].HostPort // empty' "$DIR/inspect.json")

## -----------------------------------------------------------------------------
## 3. tasks a recreate would kill
TASKS=
if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = true ]; then
    TASKS=$(docker exec -i "$CONTAINER" python3 - 2>/dev/null <<'EOF' || echo "(could not query the metadata DB)"
from airflow.utils.session import create_session
from airflow.models import TaskInstance as TI
with create_session() as s:
    for t in s.query(TI).filter(TI.state.in_(["running", "queued"])).order_by(TI.dag_id, TI.task_id):
        print(f"{t.dag_id} {t.task_id} {t.state} try={t.try_number}")
EOF
)
fi
if [ -n "$TASKS" ]; then
    log "$(echo "$TASKS" | wc -l) task(s) running/queued:"; echo "$TASKS" | sed 's/^/    /'
    [ $FORCE = 1 ] || [ $DRY = 1 ] || die "not recreating while tasks run; wait for them, or pass --force"
fi

log "plan:"
log "    stop $CONTAINER ($(docker inspect -f '{{.Config.Image}}' "$CONTAINER" 2>/dev/null || echo absent)), keep it as $PREV"
log "    docker run ${ARGS[*]}"
[ $DRY = 1 ] && { log "dry run, nothing changed"; exit 0; }

## -----------------------------------------------------------------------------
## 4. swap containers
## From here on, any non-zero exit puts the previous container back (unless --no-rollback).
OLD_RP=; SWAPPED=0; DONE=0

rollback() {
    set +e
    [ -n "$OLD_RP" ] || { log "no previous container to roll back to"; return; }
    log "rolling back to the previous container"
    if docker inspect "$PREV" >/dev/null 2>&1; then
        docker logs "$CONTAINER" > "$DIR/failed-container.log" 2>&1
        docker rm -f "$CONTAINER" >/dev/null 2>&1
        docker rename "$PREV" "$CONTAINER"
    fi
    docker update --restart="$OLD_RP" "$CONTAINER" >/dev/null
    docker start "$CONTAINER" >/dev/null && log "previous container started again (failed one's logs: $DIR/failed-container.log)" \
        || log "ERROR: could not start the previous container; fix by hand (see README, Restore by hand)"
}
on_exit() {
    local rc=$?
    if [ $rc -ne 0 ] && [ $SWAPPED = 1 ] && [ $DONE = 0 ]; then
        if [ $ROLLBACK = 1 ]; then rollback; else log "--no-rollback: leaving $CONTAINER as it is"; fi
    fi
    exit $rc
}
trap on_exit EXIT

if docker inspect "$CONTAINER" >/dev/null 2>&1; then
    OLD_RP=$(jq -r '.[0].HostConfig.RestartPolicy.Name' "$DIR/inspect.json")
    SWAPPED=1
    if [ -n "$TASKS" ]; then
        ## SIGKILL: a graceful stop SIGTERMs the task runners, whose on_kill stops the trade containers
        log "killing $CONTAINER (SIGKILL, so on_kill does not stop task containers)"
        docker kill "$CONTAINER" >/dev/null
    else
        log "stopping $CONTAINER"
        docker stop -t 120 "$CONTAINER" >/dev/null
    fi
    docker rename "$CONTAINER" "$PREV"
    docker update --restart=no "$PREV" >/dev/null
fi

log "starting $CONTAINER from $IMAGE"
SWAPPED=1
docker run "${ARGS[@]}" > "$DIR/container.id" || die "docker run failed"

## -----------------------------------------------------------------------------
## 5. health
log "waiting up to ${HEALTH_TIMEOUT}s for the scheduler and webserver"
OK=0
for i in $(seq $((HEALTH_TIMEOUT / 10))); do
    sleep 10
    [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" = true ] || { log "container is not running"; break; }
    if docker exec "$CONTAINER" /app/restart.sh status > "$DIR/status.txt" 2>&1; then OK=1; break; fi
done
sed 's/^/    /' "$DIR/status.txt" 2>/dev/null || true

if [ $OK = 1 ]; then
    STARTED=$(docker inspect -f '{{.State.StartedAt}}' "$CONTAINER")
    CHECKS=$(docker exec -i -e STARTED="$STARTED" "$CONTAINER" bash -s 2>&1 <<'EOF'
fail=0
check() { if eval "$2" >/dev/null 2>&1; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi; }
## /health can still show the old scheduler's last heartbeat; require a job from this container
JOB=$(python3 - 2>/dev/null <<'PY'
import os
from datetime import datetime, timezone
from airflow.utils.session import create_session
from airflow.jobs.job import Job
started = datetime.fromisoformat(os.environ["STARTED"][:26].rstrip("Z")).replace(tzinfo=timezone.utc)
with create_session() as s:
    j = (s.query(Job).filter(Job.job_type == "SchedulerJob", Job.state == "running", Job.start_date >= started)
         .order_by(Job.id.desc()).first())
    print(j.id if j else "")
PY
)
check "SchedulerJob started by this container (id ${JOB:-none})" 'test -n "$JOB"'
check "trading calendar in /shared"   'test -s /shared/trading/PublicInfo/Calendar/ChinaFutures.csv'
check "/data mounted"                 'test -n "$(ls -A /data)"'
check "/app/dags has DAGs"            'ls /app/dags/*.py'
check "docker socket reachable"       'python3 -c "import docker; docker.from_env().ping()"'
check "registry login present"        'test -s /root/.docker/config.json'
check "parallelism >= 128"            'test "$(airflow config get-value core parallelism 2>/dev/null)" -ge 128'
check "max_active_tasks_per_dag >= 128" 'test "$(airflow config get-value core max_active_tasks_per_dag 2>/dev/null)" -ge 128'
check "MultiCronTimetable plugin"     'airflow plugins 2>/dev/null | grep -qi mycron'
exit $fail
EOF
) && CHECK_OK=1 || CHECK_OK=0
    echo "$CHECKS" | sed 's/^/    /'
    [ $CHECK_OK = 1 ] || OK=0
fi
if [ $OK = 1 ] && [ -n "$HOST_PORT" ]; then
    H=$(curl -s --noproxy '*' -m 5 "http://127.0.0.1:$HOST_PORT/health" || true)
    echo "$H" | grep -q '"scheduler": {[^}]*"status": "healthy"' && log "UI http://127.0.0.1:$HOST_PORT/health: scheduler healthy" \
        || { log "UI on host port $HOST_PORT does not report a healthy scheduler: ${H:-no response}"; OK=0; }
fi

[ $OK = 1 ] || die "$CONTAINER from $IMAGE is not healthy"
DONE=1

## -----------------------------------------------------------------------------
## 6. done
log "$CONTAINER is running $IMAGE and healthy; previous container kept as $PREV"
docker ps -a --format '{{.CreatedAt}}\t{{.Names}}' | grep -P "\t$CONTAINER-prev-" | sort -r | tail -n +$((KEEP_PREV + 1)) | cut -f2 | while read -r c; do
    log "removing old $c"; docker rm "$c" >/dev/null
done
log "import errors after the first parse: run 'docker exec $CONTAINER airflow dags list-import-errors' in a minute"
if [ -n "$TASKS" ]; then
    log "WARNING: these tasks were running; their runners are gone, their trade containers are not:"
    echo "$TASKS" | sed 's/^/    /'
    log "re-adopt each with 'airflow tasks run <dag> <task> <run_id> --local -A', then set its"
    log "queued_by_job_id to the new SchedulerJob id, or the orphan check resets it within 5 minutes"
fi
