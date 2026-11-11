# One night, one dead disk: an Airflow trading-host outage and what it taught me


&gt; **Update 2026-11-11:** the &#34;a restart is a procedure, not a command&#34; advice below is now three scripts: a dated image built from the running container, a redeploy that refuses while tasks run and rolls back on failure, and a supervisor inside the container. See [Rebuildable Airflow]({{&lt; relref &#34;2026-11-11-airflow-image-snapshot-and-redeploy&#34; &gt;}}).

At 19:56 one evening, a 21.8 TB data disk on our Airflow host started throwing I/O errors. By 21:37 someone had pointed Docker at a fresh, empty data directory to get things running again. That one change, made under pressure and never written down, turned into **five separate incidents by 09:30 the next morning**: a message broker that vanished, a missing mount, concurrency limits back at their defaults, live-trading processes Airflow no longer knew about, and two restarts that orphaned every live trade.

Everything was back by 10:08. This post is the timeline, the root cause of each problem, how each was fixed (including the 1.5-minute outage I caused myself while fixing it), and what I would change so this can&#39;t happen the same way again.

&lt;!--more--&gt;

## The setup

- One host runs **Airflow 2.7.3** in a Docker container, using `LocalExecutor` and a MySQL metadata DB.
- Almost every task is a `DockerOperator`. Through the host&#39;s docker socket, Airflow starts a sibling container named `task_&lt;task_id&gt;`. Our in-house subclass, `CleanStartDockerOperator`, removes a *stopped* leftover container with that name before starting, and **refuses to start if one is still running**.
- The trading DAG starts one **live-trade task per account**: 34 stock accounts plus 9 futures accounts. Each task holds its Airflow slot for the whole session, **about 330 minutes**.
- RabbitMQ also runs on the same host, as a container listening on 5672/15672.
- There is a `docker-compose.yaml` describing all of this. It is out of date; the Airflow container had been started by hand with `docker run`.

For older notes on this setup, see [airflow 运维]({{&lt; relref &#34;2023-04-25-airflow-运维&#34; &gt;}}), [docker 安装 RabbitMQ]({{&lt; relref &#34;2022-11-29-docker-安装-RabbitMQ&#34; &gt;}}) and [docker 更改存储目录]({{&lt; relref &#34;2025-11-20-docker-更改存储目录&#34; &gt;}}). The last one describes exactly the knob that started all this.

## What happened

![Timeline of the incident](timeline.svg &#34;Timeline, CST. Purple = trading impact, pink = caused by my own fix.&#34;)

In short:

| When (CST) | Event | Trading impact |
|---|---|---|
| Nov 10 19:56 | data disk I/O errors begin | none yet |
| Nov 10 21:37 | Docker switched to an empty data-root | old containers invisible |
| Nov 10 night | Airflow container rebuilt by hand, several times | config drift starts |
| Nov 11 00:25 | a manual DAG run starts 16 live-trade containers, then Airflow loses track of them | 16 accounts trading from a midnight process |
| 08:06–08:51 | yaml relink and pre-trading checks fail: no `/data` | yaml symlinks still on yesterday&#39;s files |
| 09:29 | RabbitMQ found missing | message clients can&#39;t connect |
| 09:33 | only 16 of 34 live stock trades can start | **18 accounts not trading** |
| 09:54 | someone runs `docker restart airflow` | **every trade orphaned** |
| 10:03 | my re-adopted trades are killed by the scheduler | **43 accounts down ~1.5 min** |
| 10:08 | stable | none |

## Why it happened

![Cause chain](cause-chain.svg &#34;Every problem traces back to the data-root switch plus a container rebuilt from memory.&#34;)

The root cause is not &#34;a disk failed&#34;. Disks fail. The failure became an outage because **the running system existed only as state inside Docker**, not as a description anywhere:

1. The Docker data-root held everything: container definitions, images, RabbitMQ&#39;s data (no volume), and Airflow&#39;s tuned `airflow.cfg`, which lived in the container&#39;s writable layer. Switching to an empty data-root deleted all of it in one move.
2. Airflow was rebuilt **from memory** with `docker run`. Each rebuild dropped something: first the `/shared` mount and a plugin (fixed the night before), then `/data`, then the concurrency settings, which nobody knew had been tuned.
3. Live-trading processes are Airflow tasks, and with `LocalExecutor` every task runner is a child of the scheduler. **Any restart orphans every running trade.** The duplicate guard in `CleanStartDockerOperator` then turns each orphan into a `failed` task.
4. Several people were working on the same box at the same time, with no lock and no announcements.

The sections below take each problem in turn.

## Problem 1: the yaml relink task couldn&#39;t see /data

**Symptom.** The morning task that points the `*.yaml` symlinks at today&#39;s model files failed at 08:06 and again at 08:51. The colos were still on yesterday&#39;s files, 40 minutes before the open.

![/data is empty inside the container](shot-data-missing.png &#34;The task ran inside the Airflow container, where /data is an empty directory.&#34;)

**Cause.** This task is a `BashOperator`, so unlike the `DockerOperator` tasks it runs *inside* the Airflow container. The old compose file mounts `/data:/data`. None of the containers rebuilt overnight did, so `/data` inside the container was the empty directory baked into the image.

**Fix.**

- **Unblock trading first:** I ran the task&#39;s exact relinking logic on the host, where `/data` is real. Then I marked the task `success` and cleared everything after it, so Airflow itself ran the rsync to the trading servers. All 73 tasks were green by 09:02.
- **Fix properly later:** I added the mount when recreating the container at 09:58. The same missing mount had also failed three read-only `pretrading.*` check DAGs, which passed once rerun at 10:12.

## Problem 2: RabbitMQ &#34;disappeared&#34;

**Symptom.** `docker ps -a` showed no `rabbitmq` container at all, not even a stopped one, and no image either. Clients kept retrying against port 5672.

![Docker data-root moved to an empty directory](shot-docker-root.png &#34;The daemon was restarted at 21:37 with a new data-root; the old one is gone and the disk behind /Clickhouse is unreadable.&#34;)

**Cause.** Nothing deleted it. At 21:37, `/etc/docker/daemon.json` gained `&#34;data-root&#34;: &#34;/var/lib/docker-recovery&#34;` and dockerd was restarted. **Every container and image created before that lives in the old root**, so to the running daemon they don&#39;t exist. I couldn&#39;t prove where the old root lived without root access, but `/var/lib/docker` no longer exists and the failing disk is unreadable. Six `br-*` bridges left from the old daemon&#39;s networks, all `down`, were the other clue.

**Fix.** I recreated the container with the same settings as the compose file, plus the thing it never had: a named volume for `/var/lib/rabbitmq`. Then I added the user that clients log in as.

![RabbitMQ before and after](shot-rabbitmq.png &#34;Including my own mistake: the first add_user set an empty password.&#34;)

**My mistake:** I passed the password through stdin, `rabbitmqctl add_user u &#34;$(cat)&#34;`, but ran `docker exec` without `-i`. Stdin never reached the container, so **the password was silently set to empty**, and every login was refused for about a minute until I used `change_password`. Pass secrets as arguments or with `-i`, then check with a real login, as `mqtest.py` does above.

Everything the old instance held that clients don&#39;t declare themselves is gone for good: queues, exchanges, bindings and extra users.

## Problem 3: only 16 of 34 live trades could start

**Symptom.** At 09:40, a short pre-trade task had been sitting in `scheduled` since 09:38. On normal days it starts at about 09:33. Nothing was failing; it was just never picked up.

![Concurrency limits back at defaults](shot-concurrency.png &#34;The rebuilt image has Airflow&#39;s defaults; yesterday this DAG ran 61 tasks at once.&#34;)

**Cause.** The original `airflow.cfg` raised `parallelism` (global) and `max_active_tasks_per_dag` well above the defaults. It lived in the container layer, so it was lost with the old data-root, and every rebuilt image shipped the defaults, **32 and 16**. At 09:33 the first 16 live-trade tasks grabbed all 16 slots and held them, and each one runs for 5.5 hours. The other 18 accounts, and everything else in the DAG, would have waited until about 15:00.

**Fix**, in two steps because the second needs a restart:

1. Without a restart: add `max_active_tasks = 128,` to the `DAG(...)` call. The scheduler picked it up on its next parse at 09:47, and 11 more accounts started trading. The global limit of 32 then capped it at 27/34. The pre-trade task I was originally asked about I simply ran by hand with `airflow tasks run ... --local -A`, which bypasses the slot limit.
2. With a restart (09:58): `AIRFLOW__CORE__PARALLELISM=128` and `AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG=128` as environment variables, so the settings now live in the container definition instead of a file inside the image.

## Problem 4: 16 accounts trading from a midnight process

**Symptom.** Some live-trade tasks kept failing with this, every time Airflow retried them:

![CleanStart refusing a duplicate](shot-cleanstart.png &#34;The duplicate guard doing its job, against a container Airflow had forgotten about.&#34;)

When I joined task states against `docker ps`, there were two kinds of rows:

![Airflow and docker disagree](shot-stale-containers.png &#34;Account names replaced. The failing ones all had containers created around 00:25.&#34;)

**Cause.** At 00:19 someone triggered the trading DAG by hand, probably to test the rebuilt Airflow. Its live-trade containers started at 00:25–00:28. The run then failed, Airflow stopped tracking them, and **they kept trading**: 7 stock and 9 futures accounts, on a process started nine hours before the open, possibly with targets from before that morning&#39;s pre-trade step. Today&#39;s tasks for those accounts couldn&#39;t start because `task_&lt;id&gt;` was already taken.

**Fix.** Account by account: `docker stop` the old container, then start the task under today&#39;s run:

```bash
docker stop task_&lt;task_id&gt;   # graceful, ~10 s
docker exec -d airflow bash -c \
  &#34;airflow tasks run &lt;dag_id&gt; &lt;task_id&gt; &lt;run_id&gt; --local -A &gt;&gt; /tmp/manual_&lt;task_id&gt;.log 2&gt;&amp;1&#34;
```

Each account was offline for about 20 seconds; the new container logged today&#39;s `init_time`. `--local -A` runs the task outside the executor, so it doesn&#39;t need a free slot, yet Airflow still records it as `running` and keeps a heartbeat. Remember that last part, because problem 5 is about exactly that.

## Problem 5: two restarts, and the kill I caused

**09:54, a restart by someone else.** While I was waiting for an answer about when to restart, someone opened a shell in the container and restarted it:

![docker events around the restart](shot-restart-events.png &#34;An interactive zsh at 09:54:36, a restart at 09:54:40. Not a crash: exit 0, no OOM.&#34;)

With `LocalExecutor`, the task runners died with the scheduler, but their trade containers kept running. The new scheduler retried the tasks, `CleanStartDockerOperator` refused each one, and **all 34 stock trades were marked `failed` while still trading.**

**09:58, my recreate.** Every trade was orphaned already, so I recreated the container right away with `/data` and the new limits. I stopped the old one with `docker kill` (SIGKILL), not `docker stop`. A graceful stop gives the task runners time to run `DockerOperator.on_kill()`, which stops the very containers I wanted to keep alive. At 10:01 I re-adopted all 46 orphans (34 stock, 9 futures, one fund task, two pulse tasks) using the problem 4 method.

**10:03, my re-adopt blew up.** Five minutes later, every live-trade container got SIGTERM and was removed:

![The scheduler reset 43 tasks and their runners killed the containers](featured-image.png &#34;Reset by the orphan check, then each runner saw its state change and terminated.&#34;)

![Sequence of the 10:03 kill](orphan-kill.svg &#34;The manual runs were invisible to the new scheduler&#39;s orphan check.&#34;)

Here&#39;s why. Every 5 minutes, the scheduler runs `adopt_or_reset_orphaned_tasks`, which selects running and queued task instances like this (Airflow 2.7, `scheduler_job_runner.py`):

```python
.where(TI.state.in_(State.adoptable_states))
.outerjoin(TI.queued_by_job)
.where(or_(TI.queued_by_job_id.is_(None), Job.state != JobState.RUNNING))
```

`airflow tasks run --local` **does not update `queued_by_job_id`**. My 43 re-adopted tasks still pointed at the old container&#39;s scheduler job, which the new scheduler had just marked `failed`. So at 10:03:25 (scheduler start 09:58:25 plus 300 s), the orphan check reset all 43 and queued new attempts. Each new attempt hit `CleanStartDockerOperator`, refused, and marked the task `failed`. My original attempt&#39;s heartbeat saw &#34;state externally set to failed&#34;, sent itself SIGTERM, and `on_kill()` stopped the trade container. **43 accounts stopped trading at 10:03:40.**

**Fix.**

1. **Restart all 43 at once:** the same command as above. Everything was trading again at 10:05.
2. **Point the stragglers at the live scheduler:** the re-queue at 10:03 had pointed those 43 at the live scheduler, which made them safe. The 3 tasks that were never reset still pointed at the dead one and would have been killed at 10:08:25, so I fixed them by hand:

```python
from airflow.utils.session import create_session
from airflow.models import TaskInstance as TI
from airflow.jobs.job import Job

with create_session() as s:
    live = [j.id for j in s.query(Job).filter(Job.job_type == &#34;SchedulerJob&#34;, Job.state == &#34;running&#34;)]
    assert len(live) == 1, live
    bad = (s.query(TI).outerjoin(TI.queued_by_job)
             .filter(TI.state.in_([&#34;running&#34;, &#34;queued&#34;]),
                     TI.queued_by_job_id.is_(None) | (Job.state != &#34;running&#34;)))
    for t in bad:
        t.queued_by_job_id = live[0]
```

![queued_by_job_id fix and the clean 10:08 check](shot-queued-by.png &#34;After the fix, the 10:08:25 orphan check reset nothing.&#34;)

The 10:08:25 check reset nothing, and all 34 stock and 9 futures trades stayed up. The trading DAG&#39;s final task, which runs after all the live trades, had been knocked to `upstream_failed` twice; I cleared it again so it runs at the close.

## What I fixed, in one table

| Problem | Root cause | Fix | Time |
|---|---|---|---|
| yaml relink fails | no `/data` mount after hand rebuild | ran relink on host, cleared downstream; mount added at recreate | 08:57 / 09:58 |
| RabbitMQ missing | lived in the abandoned docker data-root | recreated with a named data volume &#43; client user | 09:35 |
| 18 live trades queued | tuned `airflow.cfg` lost, defaults 16/32 | `max_active_tasks=128` in DAG, then env vars 128/128 | 09:47 / 09:58 |
| 16 stale live trades | midnight manual run, containers outlived Airflow&#39;s tracking | stop &#43; `tasks run --local -A` under today&#39;s run | 09:50–10:01 |
| everything orphaned | `docker restart` mid-session; LocalExecutor | recreate, re-adopt 46 tasks | 10:01 |
| 43 trades killed (mine) | manual runs keep a dead `queued_by_job_id` | restart all, repoint stragglers to live scheduler | 10:05 / 10:06 |

## How to improve: the cheap things first

### 1. One file describes the host, and CI checks it

The fastest fix to every &#34;the rebuilt container is missing X&#34; problem is to stop rebuilding from memory. Put the real Airflow service in the compose file, with every setting as an environment variable instead of in a file inside the image:

```yaml
  airflow:
    image: &lt;registry&gt;/airflow:v1.3
    container_name: airflow
    restart: unless-stopped
    entrypoint: [&#34;/bin/bash&#34;, &#34;-c&#34;,
      &#34;rm -f /app/airflow-*.pid; airflow scheduler &gt;&gt; /app/airflow-scheduler.out 2&gt;&amp;1 &amp; exec airflow webserver --port 8080&#34;]
    env_file: /etc/airflow/airflow.env        # secrets, root-only, NOT in git
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__CORE__PARALLELISM: &#34;128&#34;
      AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG: &#34;128&#34;
    volumes:
      - ~/git/jobs/dags:/app/dags:ro
      - /data/airflow/logs:/app/logs
      - /shared:/shared:ro
      - /data:/data
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/.docker/config.json:/root/.docker/config.json:ro
    ports: [&#34;18080:8080&#34;]
```

Then add a drift check, run from cron or CI, that fails loudly when the live container stops matching:

```bash
#!/usr/bin/env bash
# check-airflow-drift.sh: exit 1 if the live container lacks a required mount or setting
set -euo pipefail
want_mounts=(/app/dags /app/logs /shared /data /var/run/docker.sock)
have=$(docker inspect -f &#39;{{range .Mounts}}{{.Destination}} {{end}}&#39; airflow)
for m in &#34;${want_mounts[@]}&#34;; do
  [[ &#34; $have &#34; == *&#34; $m &#34;* ]] || { echo &#34;MISSING mount $m&#34;; exit 1; }
done
for k in PARALLELISM MAX_ACTIVE_TASKS_PER_DAG; do
  v=$(docker exec airflow airflow config get-value core &#34;${k,,}&#34; 2&gt;/dev/null | tail -1)
  [[ &#34;$v&#34; -ge 64 ]] || { echo &#34;LOW core.${k,,} = $v&#34;; exit 1; }
done
echo ok
```

The compose file also held plaintext passwords, and the base image keeps a registry password in its shell history. Both belong in a root-only env file.

### 2. Stateful services get volumes, and their config gets exported

RabbitMQ is easy: use a named volume, and keep a definitions export in git so a fresh broker comes back with its users, vhosts and queues:

```bash
docker exec rabbitmq rabbitmqctl export_definitions /var/lib/rabbitmq/definitions.json
# and in rabbitmq.conf:  load_definitions = /etc/rabbitmq/definitions.json
```

### 3. Watch the disk, and keep docker&#39;s root off it

`dmesg` had I/O errors from 19:56, ninety minutes before anyone touched Docker. A tiny check like `dmesg -T --level=err | grep -c &#39;I/O error&#39;` feeding the existing WeChat alert would have turned a midnight scramble into a planned move. Keep the docker data-root on the SSD with the OS, not on a big data array. And whenever the data-root changes, write it down: a one-line note in the host&#39;s README would have saved me an hour.

### 4. A restart is a procedure, not a command

Most of the trading impact came from restarts, including mine. So:

- **Freeze 09:00–15:00.** Outside a real emergency, nobody restarts Airflow during the session. If you must, announce it in the ops channel first.
- **Use a pre-restart script that refuses** when live tasks are running, and lists them:

```bash
docker exec airflow airflow tasks states-for-dag-run &lt;dag_id&gt; &lt;run_id&gt; | grep -c running
```

- **Use a post-restart script** that does what took me two tries: for each running container without a running task, stop it and `tasks run --local -A`, then point every running or queued task at the live scheduler job (the snippet above). Run it immediately, not 5 minutes later.
- **Stop the old container with `docker kill`.** Graceful stops let `on_kill()` stop your trades.

### 5. Live trades must refuse to run from a manual run outside the session

The 00:25 containers came from a manual test of the trading DAG. A three-line guard in the live-trade operator would have stopped it:

```python
def execute(self, context):
    run = context[&#34;dag_run&#34;]
    if run.run_type != &#34;scheduled&#34; and not in_trading_window(pendulum.now(&#34;Asia/Shanghai&#34;)):
        raise AirflowSkipException(&#34;live trade only runs from scheduled runs, or inside the session&#34;)
    ...
```

## Better solutions to the current design

The cheap fixes stop the same thing happening twice. The real problem is architectural: **we use Airflow as a process supervisor for 43 five-hour trading processes.** Airflow is good at &#34;run this, then that, retry on failure&#34;. It is bad at &#34;keep this alive all day, across my own restarts&#34;.

![Today versus proposed](proposed.svg &#34;Move the long-running processes out of Airflow&#39;s task slots.&#34;)

### Option A: make the operator adopt its own container (smallest change)

`CleanStartDockerOperator` already finds the leftover container; it just gives up. Label each container with the run that owns it, and **reattach** when the label matches instead of refusing. Then any restart, and any orphan reset, becomes a non-event. An untested sketch:

```python
class AdoptingDockerOperator(DockerOperator):
    def execute(self, context):
        ti = context[&#34;ti&#34;]
        owner = f&#34;{ti.dag_id}/{ti.task_id}/{ti.run_id}&#34;
        self.labels = {**(self.labels or {}), &#34;airflow.owner&#34;: owner}
        c = self._get_existing(f&#34;task_{ti.task_id}&#34;)
        if c and c.status == &#34;running&#34;:
            if c.labels.get(&#34;airflow.owner&#34;) == owner:
                self.log.info(&#34;re-adopting %s&#34;, c.id[:12])
                return self._wait_and_stream(c)          # docker wait &#43; logs(follow=True)
            self.log.warning(&#34;stopping stale container from %s&#34;, c.labels.get(&#34;airflow.owner&#34;))
            c.stop(timeout=10)
        if c:
            c.remove(force=True)
        return super().execute(context)
```

With this, the stale 00:25 containers would have been stopped automatically (different owner label), and the 09:54 restart and the 10:03 reset would have simply reattached.

### Option B: trading processes become services, Airflow becomes the conductor

Run each account&#39;s trader as a long-lived service (compose with `restart: unless-stopped`, or systemd), started and stopped by short Airflow tasks, with a **sensor in `mode=&#34;reschedule&#34;`** to watch its health. A reschedule-mode sensor gives its slot back between pokes, so the DAG no longer needs 43 slots for 5.5 hours, and a scheduler restart does nothing to the traders at all. This is the shape I&#39;d go for.

### Option C: a different executor

`CeleryExecutor`, with workers in their own containers, decouples task runners from the scheduler, so restarting the scheduler no longer kills them. It&#39;s more moving parts (a broker, workers), and it doesn&#39;t fix the &#34;five-hour task in a slot&#34; problem. I&#39;d only do it alongside A or B.

## Takeaways

1. **If you can&#39;t rebuild it from a file, you don&#39;t have it.** Every lost setting here, including mounts, concurrency, RabbitMQ data and users, existed only inside Docker&#39;s data-root.
2. **Write down emergency changes as you make them.** &#34;Switched data-root to `/var/lib/docker-recovery` because sdb is dying&#34; in a README would have answered the RabbitMQ question in one minute.
3. **Duplicate guards need an adopt path.** Refusing to start a second copy is right; marking the task `failed` while the first copy is still trading is how a restart becomes an outage.
4. **Verify the side effects of your own fix, on the timescale of the system&#39;s background jobs.** My re-adopt looked perfect at 10:02 and blew up at 10:03:25 because a 5-minute housekeeping loop hadn&#39;t run yet. I now wait one full orphan-check interval before calling a restart done.
5. **One operator at a time during the session.** Two people restarting and repairing the same container ten minutes apart is how 09:54 happened.

&gt; All account names, usernames, internal hostnames and addresses in the screenshots were replaced with placeholders (`ACCT_01`, `&lt;team&gt;`, `&lt;user&gt;`, `&lt;client-1&gt;`). The values themselves are the real output.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-11-airflow-outage-postmortem/  

