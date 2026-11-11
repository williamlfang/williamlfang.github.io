# Rebuildable Airflow: snapshot the running container, redeploy with a rollback


The [outage postmortem]({{&lt; relref &#34;2026-11-11-airflow-outage-postmortem&#34; &gt;}}) had one recurring theme: every time someone rebuilt the Airflow container by hand, it came back missing something. A mount, the concurrency settings, the plugin, the registry login. The image was whatever someone last typed, and the settings that mattered lived only in a running container.

So the same afternoon I wrote three small scripts. `build.airflow.sh` turns the running container into a dated image (`airflow:20261111`), pushes it, and saves a tarball. `run.sh` recreates the container from that tag and checks it&#39;s actually healthy, or puts the old one back. `restart.sh` runs inside the container and keeps the scheduler and webserver up. **From the 170 entries in `docker diff`, the image keeps 13 files (172K). A redeploy is healthy about 15 s after the new container starts, and a failed one rolls back in 1 s.**

&lt;!--more--&gt;

![run.sh against the stand-in container](featured-image.png &#34;run.sh swapping a stand-in container and running its health checks&#34;)

## The setup

- One host runs Airflow 2.7.3 in a single container: LocalExecutor, MySQL metadata DB, about 66 DAGs. Most tasks are `DockerOperator`s that start containers through the host&#39;s docker socket.
- The container needs five mounts or things break: `/app/dags`, `/app/logs`, `/shared` (the trading calendar), `/data`, and `/var/run/docker.sock`. It also needs a read-only registry login.
- Images live in a LAN registry, `192.168.1.162:5000/airflow`. Before today the tags were `v1.1`, `v1.2` and `v1.3`, each made by hand the night before.
- The host has `docker`, `jq` and `curl`, but no `python3`. Inside the container it&#39;s CentOS 7 with bash 4.2.

The scripts are in this post&#39;s folder: [build.airflow.sh](build.airflow.sh), [run.sh](run.sh), [restart.sh](restart.sh). Both host scripts run on the Airflow host itself, as the deploy user.

![build → three image sources → run.sh → healthy or rollback](flow.svg &#34;The whole flow&#34;)

## Why not just `docker commit`

My first thought was `docker commit airflow airflow:20261111`. Two things in the container made that a bad idea.

**The container layer is mostly junk.** `docker diff airflow` listed 170 entries: 92 of them were `/tmp/manual_*.log` files from the morning&#39;s manual task runs. The rest included SSH agent sockets, a `/tmp/root_*_access_token.conf`, root&#39;s `.zsh_history`, vim state, the scheduler&#39;s 4.7 MB `airflow-scheduler.out`, and `__pycache__`. A commit would ship all of it, history included.

**The env holds secrets.** `docker commit` copies the container&#39;s `Config.Env` into the image. Counting secret env vars per image:

```bash
for t in v1.1 v1.2 v1.3; do
  echo &#34;$t: $(docker inspect -f &#39;{{range .Config.Env}}{{println .}}{{end}}&#39; 192.168.1.162:5000/airflow:$t \
    | grep -cE &#39;SQL_ALCHEMY_CONN=mysql|FERNET_KEY=|WEBSERVER__SECRET_KEY=&#39;) secret env vars&#34;
done
```

```text
v1.1: 0 secret env vars
v1.2: 3 secret env vars
v1.3: 3 secret env vars
```

`v1.2` was itself a commit, so since last night anyone who could pull the image could read the DB password with `docker inspect`. I also checked `docker history --no-trunc` for the password and found 0 hits, so the secrets are only in the image config, not in a layer. That matters: a new image can override them.

A fair question while writing this: shouldn&#39;t the snapshot skip `/app/logs`, since it&#39;s large and irrelevant? It already does. `/app/logs` is a bind mount, and **Docker never puts a mounted path into an image**, whether by `commit` or `build`. The same goes for `/app/dags`, `/shared`, `/data` and the socket.

## build.airflow.sh: keep what changed, drop the rest

Instead of committing, the script builds a normal image on top of the container&#39;s own image, adding only the files the container really changed.

### Which files

The script reads `docker diff`, then removes every mounted path (taken from `.Mounts[].Destination`) and a fixed list of noise. What survives goes into a tar, copied out of the container with `docker exec tar`:

```bash
docker exec -i &#34;$CONTAINER&#34; tar -C / --no-recursion --ignore-failed-read -cf - -T - \
    &lt; &#34;$DIR/changed.txt&#34; &gt; &#34;$DIR/changes.tar&#34;
```

A few details that matter:

- **`-i` on `docker exec`.** Without it the file list never reaches tar&#39;s stdin. The same mistake gave a RabbitMQ user an empty password that morning.
- **`--no-recursion`.** `docker diff` lists `C /usr`, `C /usr/local` and so on for every changed parent directory. With recursion, a `C /usr` entry would tar the whole of `/usr`.
- **`--ignore-failed-read`.** A file can vanish between `diff` and `tar`, for example a rotated log. That shouldn&#39;t fail the build.
- **Deleted files** (`D` entries) go into `deleted.txt`, and the image runs `xargs rm -rf` on them.

On the live container this kept 13 entries, and the only real file changes were in `/app/airflow.cfg`. One was `parallelism = 128`. The other was an edit someone had made in vim at 10:59 that day, adding `basic_auth` to the API `auth_backends`. That one would have been lost on the next rebuild, because it existed nowhere else. **This is the point of building from the container: hand edits made under pressure get carried forward instead of silently dropped.**

### The generated Dockerfile

```dockerfile
FROM 192.168.1.162:5000/airflow:v1.3
## files changed in container airflow (see changed.txt / deleted.txt)
ADD changes.tar /
COPY deleted.txt /tmp/airflow-deleted.txt
RUN xargs -r -d &#39;\n&#39; rm -rf &lt; /tmp/airflow-deleted.txt; rm -f /tmp/airflow-deleted.txt
COPY restart.sh /app/restart.sh
RUN chmod 755 /app/restart.sh
## runtime settings of the running container
ENV AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG=&#34;128&#34;
ENV AIRFLOW__CORE__PARALLELISM=&#34;128&#34;
## secrets come from run.sh&#39;s --env-file, never from the image
ENV AIRFLOW__CORE__FERNET_KEY=&#34;&#34;
ENV AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=&#34;&#34;
ENV AIRFLOW__WEBSERVER__SECRET_KEY=&#34;&#34;
ENTRYPOINT [&#34;/app/restart.sh&#34;, &#34;run&#34;]
```

- **Non-secret runtime settings get baked in.** These are `AIRFLOW__*` variables the container had but its image didn&#39;t. That&#39;s how the two concurrency settings, lost twice the night before, become part of the image.
- **Secrets get blanked.** Docker can&#39;t unset an inherited `ENV`, but it can override it with an empty value. `run.sh` passes the real values with `--env-file` at runtime. After building, the script checks the new image&#39;s env and fails if any secret variable still has a value.
- **The base is pinned.** If the container&#39;s tag has since moved to another image, the script tags the exact image the container runs as `base-TAG`, so the snapshot is of what&#39;s actually running.

### Checks before anything leaves the host

The requirement is that whatever the build produces must work, because the next rebuild starts from it. So there are three gates, and nothing is pushed or saved unless all three pass:

1. **Source health.** It refuses to build if the running container&#39;s own `/health` doesn&#39;t report a healthy metadatabase and scheduler. A broken container never becomes the next base.
2. **Static checks** in a throwaway container. It mounts the real binds read-only, with no docker socket, and checks the airflow version, the concurrency values, that `restart.sh` is present, and that no registry login is in the image. It imports wepy&#39;s `CleanStartDockerOperator` and **parses every DAG with `DagBag`: 66 DAGs, 0 import errors.**
3. **Boot test** in a sandbox. It starts the image through its real entrypoint, `/app/restart.sh run`, with sqlite, SequentialExecutor, an empty DAG folder, no mounts and no published ports, and requires `restart.sh status` to pass. This can&#39;t touch production.

![build.airflow.sh output](shot-build.png &#34;The build (then still named build.sh): 170 diff entries down to 13, DAGs parsed, boot test, push, tarball&#34;)

One thing in the DagBag output made me stop and check: a CRITICAL line from a DAG&#39;s `check_cmd` saying a model update had &#34;failed&#34;. DAG files run their top-level code at parse time, and this one is part of an alerting path. I read the source. `check_cmd` only logs and returns a shell string; the WeChat send is inside that string and only runs if the task runs. The production scheduler parses the same file every 30 seconds. Still, **&#34;parse all DAGs&#34; is not free of side effects, and it&#39;s worth checking what yours do at import.**

Then it pushes to the registry and saves `docker save | gzip` to `/data/docker-images/airflow/airflow-20261111.tar.gz`, with a `.sha256` next to it and mode 600. The newest 7 are kept.

## restart.sh: a supervisor instead of `&amp; exec`

The old entrypoint was:

```bash
rm -f /app/airflow-*.pid; airflow scheduler &gt;&gt; /app/airflow-scheduler.out 2&gt;&amp;1 &amp; exec airflow webserver --port 8080
```

The webserver is PID 1, so if it dies the container restarts. **If the scheduler dies, nothing notices.** The UI keeps working, and nothing gets scheduled. The 2023 version in [airflow 运维]({{&lt; relref &#34;2023-04-25-airflow-运维&#34; &gt;}}) used `airflow scheduler -D`, which has its own trap when used in an entrypoint: python-daemon won&#39;t detach when its parent is PID 1, so the command never gets past the first `-D`.

The new `/app/restart.sh` has three modes:

```text
/app/restart.sh run       # entrypoint: start scheduler &#43; webserver, restart either if it exits
/app/restart.sh status    # exit 0 if the scheduler has a live SchedulerJob and /health is healthy
/app/restart.sh           # restart both under the running supervisor (refuses while tasks run)
```

- **The container runs with `--init`.** `docker-init` is PID 1, so zombies get reaped and signals reach the script.
- **The container&#39;s bash is 4.2, which has no `wait -n`.** So the loop polls every 5 s with `sleep 5 &amp; wait $!` rather than a plain `sleep`, so a `SIGTERM` or `SIGHUP` trap fires immediately instead of after the sleep.
- **A service that dies within 60 s of starting** gets a 30 s pause before the next start, so a broken config can&#39;t spin.
- **`docker exec airflow /app/restart.sh` with no argument** is how people restarted Airflow before, so I kept that meaning. It finds the supervisor (pid file plus a `/proc/&lt;pid&gt;/cmdline` check, because the pid file survives container restarts) and sends it `SIGHUP`. It refuses while task instances are running or queued, because LocalExecutor task runners are children of the scheduler.

I tested it in a sandbox container: killed the scheduler with `SIGKILL`, restarted through `docker exec`, tried to start a second supervisor, and stopped the container.

![restart.sh tests](shot-supervisor.png &#34;Scheduler killed and restarted in the same second; the in-container restart; a second supervisor refused; docker stop in 3.3 s&#34;)

## run.sh: recreate from local, registry or tarball

```text
./run.sh TAG [--from local|tarball|registry] [--force] [--dry-run] [--no-rollback]
```

1. **Get the image.** By default it uses the local image if there is one, then the tarball (after checking its sha256), then the registry.
2. **Copy the current container&#39;s settings.** It reads binds, ports, hostname, restart policy, privileged, shm-size, network and extra hosts with `jq` from `docker inspect`. The `AIRFLOW*`/`TZ`/`LANG` env goes into a mode-600 env file under `~/airflow-deploy/&lt;time&gt;/`. If the container is gone, it uses the last saved copy. **It refuses if any of the five required mounts is missing.**
3. **Refuse while tasks run.** It lists running and queued task instances. A `--dry-run` against production at 17:01 showed two of them, so a real run would have stopped there. With `--force` it uses `docker kill` rather than `docker stop`: a graceful stop sends `SIGTERM` to the task runners, and their `on_kill` stops the live trading containers. That was the [10:03 outage]({{&lt; relref &#34;2026-11-11-airflow-outage-postmortem&#34; &gt;}}) in the postmortem.
4. **Swap.** The old container becomes `airflow-prev-&lt;time&gt;` with `restart=no`, and the new one starts with `--init` and `/app/restart.sh run`.
5. **Check health.** The new container passes only if all of these hold: `restart.sh status`, a SchedulerJob that started *after* the new container, the trading calendar, `/data`, DAG files present, the docker socket, the registry login, both concurrency values at 128 or more, the `MultiCronTimetable` plugin, and the UI&#39;s `/health` on the host port.
6. **Roll back** on any failure.

To test it without touching production, I made a stand-in: a container called `airflow-rt` started exactly the way the current one was, but with a sqlite DB, one placeholder DAG and UI port 18081. Then I ran `run.sh` against it with `CONTAINER=airflow-rt`. The featured image at the top is one of those runs.

## Three things the tests caught

**1. `airflow jobs check --allow-multiple` fails on its own.** `status` reported the scheduler as down while `/health` said it was healthy. Running the command by hand:

```text
To use option --allow-multiple, you must set the limit to a value greater than 1.
```

The fix is `airflow jobs check --job-type SchedulerJob --local --limit 5 --allow-multiple`.

**2. `set -e` skipped the rollback.** To test the rollback I forced a failed health check with `HEALTH_TIMEOUT=0`. The script exited 1, and the new, unchecked container stayed in place. With zero loop iterations, `status.txt` never existed, so `cat status.txt | sed` failed under `set -euo pipefail` and the script ended before reaching the rollback code. Fixing that one line isn&#39;t enough, because the next unexpected failure would do the same. **The real fix is an `EXIT` trap: once the old container is stopped, any non-zero exit rolls back.**

```bash
on_exit() {
    local rc=$?
    if [ $rc -ne 0 ] &amp;&amp; [ $SWAPPED = 1 ] &amp;&amp; [ $DONE = 0 ]; then
        if [ $ROLLBACK = 1 ]; then rollback; else log &#34;--no-rollback: leaving $CONTAINER as it is&#34;; fi
    fi
    exit $rc
}
trap on_exit EXIT
```

![rollback before and after](shot-rollback.png &#34;The same forced failure, before and after the EXIT trap&#34;)

**3. `/health` can vouch for a dead scheduler.** The tests didn&#39;t hit this one; I found it reading the first successful run&#39;s output. `/health` calls the scheduler healthy if *any* SchedulerJob heartbeat is less than 30 s old. After a `docker kill`, the old scheduler&#39;s last heartbeat stays fresh for up to 30 s, and the first health probe runs 10 s after the start. So `run.sh` also requires a running SchedulerJob whose `start_date` is after the new container&#39;s `StartedAt`, and prints its id. You need that id anyway if any `queued_by_job_id` has to be repointed.

## Results

All deploy times are against the stand-in. Production is still on `v1.3` and will move when nothing is running.

| Step | Time |
|---|---|
| build: diff, tar, image | 6 s |
| build: DagBag parse of 66 DAGs | 7 s |
| build: sandbox boot test | 27 s |
| build: push (new layers only) | 38 s |
| build: `docker save \| gzip`, 2.1G tarball | 5 min 33 s |
| deploy from local image, start to healthy | **16 s** |
| deploy from registry (already up to date), whole script | 22 s |
| deploy from tarball, checksum &#43; load &#43; healthy | 69 s |
| forced failure → old container running again | **1 s** |

## Takeaways

1. **Build from what&#39;s running, not from memory.** The `auth_backends` edit from 10:59 existed only in the container. A diff-based build keeps hand fixes like that; a clean rebuild from an old Dockerfile would have dropped it.
2. **Mounts are never in an image, so don&#39;t snapshot them, but check them on every deploy.** Logs and DAGs never needed excluding. What kept breaking was containers recreated *without* those mounts, which is why `run.sh` refuses when one is missing.
3. **`docker commit` copies the env, and the env is where secrets go.** Check `docker inspect -f &#39;{{.Config.Env}}&#39;` on any image you&#39;re about to push. Override secrets with empty values and pass the real ones at runtime.
4. **Test the rollback by forcing a failure.** My rollback looked right and didn&#39;t work. Under `set -e`, rollback belongs in an `EXIT` trap, not after the step that might fail.
5. **A health check must prove the *new* process is healthy.** A heartbeat in a shared database can belong to the process you just killed.
6. **Supervise both processes.** `cmd &amp; exec other` only watches `other`.

## References

- Postmortem this follows: [One night, one dead disk]({{&lt; relref &#34;2026-11-11-airflow-outage-postmortem&#34; &gt;}})
- [`airflow jobs check`](https://airflow.apache.org/docs/apache-airflow/2.7.3/cli-and-env-variables-ref.html#check) and the [`/health` endpoint](https://airflow.apache.org/docs/apache-airflow/2.7.3/administration-and-deployment/logging-monitoring/check-health.html)
- [`docker diff`](https://docs.docker.com/reference/cli/docker/container/diff/), [`docker run --init`](https://docs.docker.com/reference/cli/docker/container/run/#init)
- Scripts: [build.airflow.sh](build.airflow.sh), [run.sh](run.sh), [restart.sh](restart.sh)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-11-airflow-image-snapshot-and-redeploy/  

