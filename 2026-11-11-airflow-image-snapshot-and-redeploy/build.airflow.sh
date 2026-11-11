#!/bin/bash
## =============================================================================
## build.airflow.sh: build an Airflow image from the running `airflow` container on the Airflow host.
## Run it on the Airflow host itself, as the deploy user.
##
##   ./build.airflow.sh [TAG] [--no-push] [--no-tarball] [--force]
##
##   TAG          image tag, default the current time as yyyymmddTHHMMSS (e.g. 20261111T171500)
##   --no-push    do not push to $REPO
##   --no-tarball do not write $TARBALL_DIR/airflow-TAG.tar.gz
##   --force      overwrite an existing TAG
##
## What goes into the image: the running container's image, plus every file the
## container changed (`docker diff`), plus restart.sh from this folder as /app/restart.sh.
## Left out: everything mounted (/app/logs, /app/dags, /shared, /data, docker.sock ...),
## /tmp, pid/out files, shell history, ~/.ssh, ~/.docker, editor state, __pycache__.
## The DB connection, fernet key and webserver secret key are blanked in the image;
## run.sh passes them at runtime from the running container's env.
##
## Output: image $REPO:TAG (pushed unless --no-push), tarball $TARBALL_DIR/airflow-TAG.tar.gz,
##         build context and log in $BUILD_ROOT/TAG/.
## =============================================================================
set -euo pipefail

CONTAINER=${CONTAINER:-airflow}
REPO=${REPO:-192.168.1.162:5000/airflow}
BUILD_ROOT=${BUILD_ROOT:-$HOME/airflow-build}
TARBALL_DIR=${TARBALL_DIR:-/data/docker-images/airflow}
KEEP_TARBALLS=${KEEP_TARBALLS:-7}
HERE=$(cd "$(dirname "$0")" && pwd)

TAG=$(date +%Y%m%dT%H%M%S); PUSH=1; TARBALL=1; FORCE=0
for a in "$@"; do
    case $a in
        --no-push)    PUSH=0 ;;
        --no-tarball) TARBALL=0 ;;
        --force)      FORCE=1 ;;
        -h|--help)    awk 'NR>2 && /^## ====/{exit} NR>2' "$0"; exit 0 ;;
        -*)           echo "unknown option $a" >&2; exit 2 ;;
        *)            TAG=$a ;;
    esac
done
IMAGE=$REPO:$TAG
DIR=$BUILD_ROOT/$TAG

log() { echo "[$(date '+%F %T')] $*"; }
die() { log "ERROR: $*"; exit 1; }

exec 9>/tmp/airflow-build.lock
flock -n 9 || die "another build.airflow.sh is running"

## -----------------------------------------------------------------------------
## preflight
[ -f "$HERE/restart.sh" ] || die "$HERE/restart.sh not found"
bash -n "$HERE/restart.sh" || die "$HERE/restart.sh has a syntax error"
[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = true ] || die "container $CONTAINER is not running"
if docker image inspect "$IMAGE" >/dev/null 2>&1 && [ $FORCE = 0 ]; then
    die "$IMAGE already exists; pass --force to rebuild it, or give another tag"
fi
mkdir -p "$DIR"; chmod 700 "$DIR"
exec > >(tee -a "$DIR/build.log") 2>&1
log "building $IMAGE from container $CONTAINER, context $DIR"

## only snapshot a container whose Airflow works
H=$(docker exec "$CONTAINER" curl -s --noproxy '*' -m 10 http://localhost:8080/health || true)
echo "$H" | grep -q '"metadatabase": {"status": "healthy"}' && echo "$H" | grep -q '"scheduler": {[^}]*"status": "healthy"' \
    || die "Airflow in $CONTAINER is not healthy, not building from it: ${H:-no response from /health}"
log "source container healthy: $H"

docker inspect "$CONTAINER" > "$DIR/container.json"
BASE_ID=$(jq -r '.[0].Image' "$DIR/container.json")
BASE=$(jq -r '.[0].Config.Image' "$DIR/container.json")
if [ "$(docker image inspect -f '{{.Id}}' "$BASE" 2>/dev/null)" != "$BASE_ID" ]; then
    ## the tag moved since the container started; pin the exact image it runs
    BASE=$REPO:base-$TAG
    docker tag "$BASE_ID" "$BASE"
    log "container image tag has moved, tagged its image ${BASE_ID:7:12} as $BASE"
fi
log "base image: $BASE (${BASE_ID:7:12})"

## -----------------------------------------------------------------------------
## files the container changed, minus mounts and noise
jq -r '.[0].Mounts[].Destination' "$DIR/container.json" > "$DIR/mounts.txt"
docker diff "$CONTAINER" > "$DIR/diff.txt"

awk -v mounts="$DIR/mounts.txt" '
BEGIN {
    while ((getline m < mounts) > 0) skip[m] = 1
    n = split("/tmp /run /var/run /var/tmp /proc /sys /dev /etc/hostname /etc/hosts /etc/resolv.conf " \
              "/app/logs /app/dags /app/restart.sh.pid " \
              "/root/.zsh_history /root/.bash_history /root/.python_history /root/.lesshst /root/.viminfo " \
              "/root/.ssh /root/.docker /root/.vim /root/.cache /root/.local /root/.z /root/log", fixed, " ")
    for (i = 1; i <= n; i++) skip[fixed[i]] = 1
}
{
    kind = $1; path = substr($0, 3)
    for (p = path; p != ""; sub(/\/[^\/]*$/, "", p)) if (p in skip) next   # path or a parent is skipped
    if (path ~ /\/__pycache__(\/|$)/ || path ~ /\.pyc$/) next
    if (path ~ /^\/app\/[^\/]*\.(pid|out|err)$/ || path ~ /^\/app\/airflow-scheduler\.log$/) next
    if (kind == "D") print path > "/dev/stderr"; else print substr(path, 2)
}' "$DIR/diff.txt" > "$DIR/changed.txt" 2> "$DIR/deleted.txt"

log "docker diff: $(wc -l < "$DIR/diff.txt") entries; keeping $(wc -l < "$DIR/changed.txt") added/changed and $(wc -l < "$DIR/deleted.txt") deleted"
grep -v '/$' "$DIR/changed.txt" | head -30 | sed 's/^/    \//'

docker exec -i "$CONTAINER" tar -C / --no-recursion --ignore-failed-read -cf - -T - \
    < "$DIR/changed.txt" > "$DIR/changes.tar"
log "changes.tar: $(du -h "$DIR/changes.tar" | cut -f1)"

## -----------------------------------------------------------------------------
## env: bake non-secret runtime AIRFLOW__* settings, blank secrets
SECRET_RE='(CONN|KEY|SECRET|PASSW|TOKEN)'
jq -r '.[0].Config.Env[]' "$DIR/container.json" | sort > "$DIR/env.container"
docker image inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$BASE" | grep -v '^$' | sort > "$DIR/env.base"

ENV_LINES=$(comm -23 "$DIR/env.container" "$DIR/env.base" | grep '^AIRFLOW__' | grep -vE "^[^=]*$SECRET_RE" \
    | sed -E 's/\\/\\\\/g; s/"/\\"/g; s/^([^=]+)=(.*)$/ENV \1="\2"/' || true)
BLANK_LINES=$(grep -E "^AIRFLOW[^=]*${SECRET_RE}[^=]*=" "$DIR/env.base" | cut -d= -f1 | sed 's/.*/ENV &=""/' || true)

cp "$HERE/restart.sh" "$DIR/restart.sh"
cat > "$DIR/Dockerfile" <<EOF
FROM $BASE
## files changed in container $CONTAINER (see changed.txt / deleted.txt)
ADD changes.tar /
COPY deleted.txt /tmp/airflow-deleted.txt
RUN xargs -r -d '\n' rm -rf < /tmp/airflow-deleted.txt; rm -f /tmp/airflow-deleted.txt
COPY restart.sh /app/restart.sh
RUN chmod 755 /app/restart.sh
## runtime settings of the running container
${ENV_LINES:-# (no extra AIRFLOW__ settings)}
## secrets come from run.sh's --env-file, never from the image
${BLANK_LINES:-# (no secrets in the base env)}
LABEL airflow.build.tag="$TAG" airflow.build.date="$(date '+%F %T %z')" \\
      airflow.build.base="$BASE" airflow.build.container="$CONTAINER"
ENTRYPOINT ["/app/restart.sh", "run"]
CMD []
EOF
log "Dockerfile:"; sed 's/^/    /' "$DIR/Dockerfile"

## -----------------------------------------------------------------------------
docker build -t "$IMAGE" "$DIR"
LEAK=$(docker image inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$IMAGE" | grep -E "^AIRFLOW[^=]*${SECRET_RE}[^=]*=." | cut -d= -f1 || true)
[ -z "$LEAK" ] || die "image env still holds secrets: $LEAK"
log "built $IMAGE ($(docker image inspect -f '{{.Id}}' "$IMAGE" | cut -c8-19), $(docker image inspect -f '{{.Size}}' "$IMAGE" | awk '{printf "%.2fGB", $1/1e9}'))"

## -----------------------------------------------------------------------------
## verify: throwaway container, runtime env, the same binds read-only, no docker.sock, no ports
log "verifying $IMAGE"
umask 077
grep -E '^(AIRFLOW|TZ=|LANG=)' "$DIR/env.container" > "$DIR/verify.env"
umask 022
VOLS=()
while read -r b; do
    case $b in *docker.sock*) continue ;; esac
    IFS=: read -r src dst _ <<< "$b"
    VOLS+=(-v "$src:$dst:ro")
done < <(jq -r '.[0].HostConfig.Binds[]?' "$DIR/container.json")

if ! docker run --rm --env-file "$DIR/verify.env" "${VOLS[@]}" --entrypoint bash "$IMAGE" -c '
    set -e
    echo "airflow $(airflow version 2>/dev/null)"
    echo "parallelism=$(airflow config get-value core parallelism 2>/dev/null) max_active_tasks_per_dag=$(airflow config get-value core max_active_tasks_per_dag 2>/dev/null)"
    test -x /app/restart.sh && bash -n /app/restart.sh && echo "/app/restart.sh ok"
    test ! -e /root/.docker/config.json && echo "no registry login in image"
    python3 - <<EOF
import wepy.utils.airflow_util as a
assert hasattr(a, "CleanStartDockerOperator"), "wepy has no CleanStartDockerOperator"
print("wepy CleanStartDockerOperator ok")
from airflow.models import DagBag
b = DagBag("/app/dags", include_examples=False)
print(f"dags parsed: {len(b.dags)}, import errors: {len(b.import_errors)}")
for f, e in b.import_errors.items():
    print("  ", f, str(e).splitlines()[-1])
assert not b.import_errors, "DAG import errors"
EOF
' 2>&1 | grep -vi warning; then
    die "verification failed; image $IMAGE is built but not pushed or saved"
fi

## boot test: start Airflow the way run.sh does (entrypoint /app/restart.sh run) and require
## `restart.sh status` to pass. Sandboxed so it cannot touch production: sqlite DB,
## SequentialExecutor, empty DAG folder, no docker socket, no published ports, no mounts.
BOOT=airflow-boottest-$TAG
docker rm -f "$BOOT" >/dev/null 2>&1 || true
log "boot test in sandbox container $BOOT"
docker run -d --name "$BOOT" --hostname "$BOOT" --init \
    -e AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:////tmp/boottest.db \
    -e AIRFLOW__CORE__EXECUTOR=SequentialExecutor \
    -e AIRFLOW__CORE__DAGS_FOLDER=/tmp/no-dags \
    --entrypoint bash "$IMAGE" -c 'mkdir -p /tmp/no-dags && airflow db migrate >/dev/null 2>&1 && exec /app/restart.sh run' >/dev/null
BOOT_OK=0
for _ in $(seq 18); do
    sleep 10
    [ "$(docker inspect -f '{{.State.Running}}' "$BOOT")" = true ] || break
    docker exec "$BOOT" /app/restart.sh status > "$DIR/boottest.status" 2>&1 && { BOOT_OK=1; break; }
done
sed 's/^/    /' "$DIR/boottest.status" 2>/dev/null || true
docker logs "$BOOT" > "$DIR/boottest.log" 2>&1 || true
docker stop -t 60 "$BOOT" >/dev/null 2>&1 || true
docker rm -f "$BOOT" >/dev/null 2>&1 || true
[ $BOOT_OK = 1 ] || die "boot test failed (log $DIR/boottest.log); image $IMAGE is built but not pushed or saved"
log "boot test passed: scheduler and webserver come up under /app/restart.sh"

## -----------------------------------------------------------------------------
if [ $PUSH = 1 ]; then
    log "pushing $IMAGE"
    docker push "$IMAGE" | tail -3
fi

if [ $TARBALL = 1 ]; then
    mkdir -p "$TARBALL_DIR"
    OUT=$TARBALL_DIR/airflow-$TAG.tar.gz
    log "saving $OUT (takes a few minutes)"
    umask 077
    docker save "$IMAGE" | gzip > "$OUT.part"
    mv -f "$OUT.part" "$OUT"
    (cd "$TARBALL_DIR" && sha256sum "airflow-$TAG.tar.gz" > "airflow-$TAG.tar.gz.sha256")
    log "tarball: $OUT ($(du -h "$OUT" | cut -f1))"
    ## keep the newest $KEEP_TARBALLS
    ls -1t "$TARBALL_DIR"/airflow-*.tar.gz | tail -n +$((KEEP_TARBALLS + 1)) | while read -r old; do
        log "removing old tarball $old"; rm -f "$old" "$old.sha256"
    done
fi

log "done: $IMAGE"
log "deploy with: $HERE/run.sh $TAG"
