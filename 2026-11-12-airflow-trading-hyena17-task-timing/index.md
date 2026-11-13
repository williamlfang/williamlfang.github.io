# Why trading.hyena17 runs past 09:30: request timeouts and slow service readiness


I wanted to know which tasks in `trading.hyena17` make the morning setup run past 09:30. Sorting by duration was misleading. Some tasks deliberately run until 15:00, while a task that takes only five seconds can still start ninety seconds late.

The Nov 12 run has two main problems. **Stock-weight preparation takes 352.6 seconds and leaves only 4.4 seconds before 09:30.** Downstream, the slowest shared-service startup takes another 167.3 seconds and finishes at 09:35:15. Redis itself takes 4.8 seconds. Its late start comes from its dependencies.

&lt;!--more--&gt;

![Full morning timeline for every fund, account, and colo, with 09:30 marked in red](morning-timeline.png &#34;Nov 12, UTC&#43;8. All fund targets, zfu_param generation, R7 and colo transfers, zfu_check validation, account launches, and shared-service startups. Amber is queue time; blue is runtime.&#34;)

[Open the full-size timeline](morning-timeline.png) to read all 252 task rows. The eight sections contain all 26 fund targets, 34 `zfu_param` generation tasks, 34 transfers to R7, 22 transfers to colos, 34 `zfu_check` validation tasks, 68 stock account/colo launch tasks for 34 accounts, 22 shared-service startups, and nine futures account launches, plus stock weight, Redis, and futures risk. This chart uses the first recorded morning attempts and includes both stock-market colos for each account.

## What I measured

I read the production Airflow metadata and selected task logs without running or clearing any tasks. The snapshot starts at 17:08 UTC&#43;8 on Nov 12, after the trading session.

- Airflow 2.7.3, `LocalExecutor`, MySQL metadata, `Asia/Shanghai` timezone.
- The latest 20 scheduled dates, Oct 16 through Nov 12, 2026. The DAG is scheduled at 09:05 on weekdays.
- 7,301 current task-instance rows and 15,113 task-state audit events. Manual DAG runs are outside the sample.
- Historical duration comparisons use the 17 dates with an observed successful stock-weight run, excluding the known Nov 11 incident. Each task has its own sample count.

All displayed times are **UTC&#43;8**. The naive timestamps read from MySQL represent UTC. I checked that conversion against task logs, where the 01:05 UTC scheduled run appears at 09:05 local time.

The report uses the original Airflow task IDs, fund codes, account names, and colocation names. `Stock target position: ZX7` is `zsun_pre_trade_stock_target_pos_ZX7`: it requests pre-trade stock target positions for fund ZX7 and waits for completion. `Shared services: Colo153` is `h17.trading.shared_Colo153`, the shared-service startup task on Colo153. Charts abbreviate the task family for readability; tables and CSV downloads retain the Airflow identifiers.

### Reruns make the current task table an incomplete history

The current `dag_run.start_date` for Nov 12 says 16:44 local time. The same run contains tasks that started at 09:05. Someone reran part of the DAG in the afternoon, so the run-level timestamps do not describe the original morning execution.

I reconstructed attempts by pairing each task&#39;s `running` audit event with its next `success` or `failed` event. A second `running` event without a terminal event leaves the earlier attempt unresolved. When a current task-instance or failure record matches an attempt, its more precise timestamps replace the audit timestamps. Original queue timestamps are used only when that matching task-instance record survives.

For morning duration comparisons, I select the first observed attempt per task between 09:00 and noon on the scheduled date. Failed and unresolved attempts stay in the data, but do not enter successful-runtime percentiles. Empty operators can have metadata-only records. Other metadata-only successes without evidence of a running attempt are excluded, because marking a task successful does not prove that its work ran.

Across the 20 dates, those first morning attempts contain 5,759 successes, 107 failures, and 93 unresolved outcomes. For Nov 12, all 361 observed first morning task or gate instances succeed. That does not mean the application made no retries inside those tasks.

The history chart uses the first successful morning completion per task, including a recovery attempt when necessary. Oct 16 and Oct 19 lack successful stock-weight records in this reconstruction. Gray cells mean missing evidence, not an on-time completion.

## The delay begins before 09:30

![Historical readiness times over 20 scheduled dates](readiness-history.png &#34;Printed timestamps retain the full delay. Colors clip at ten minutes on either side of 09:30.&#34;)

Stock-weight runtime changes visibly after Oct 23. Its median is 108.8 seconds across Oct 20–23, then 341.2 seconds across the 13 later non-incident dates. This is an observational change, not a controlled benchmark. The sample contains 14 different DAG hashes, and I have not isolated a backend release, input-size change, or configuration change that explains it.

![Stock-weight runtime by scheduled date](stock-weight-history.png &#34;The dashed line is the 300-second request timeout seen in the surviving Nov 11–12 logs, not an Airflow task timeout.&#34;)

The Nov 12 task starts at 09:24:02.972 and succeeds at 09:29:55.607. The application log shows an accepted request, a timeout, a second request, and eventually completion:

```text
09:24:04.033  sending request: stock_daily {&#39;api&#39;: &#39;pre_trade&#39;, &#39;mode&#39;: &#39;stock_weight&#39;}
09:24:04.056  response received: ... &#34;status&#34;: &#34;received&#34; ...
09:29:04.065  retrying after request timeout: stock_daily {&#39;api&#39;: &#39;pre_trade&#39;, &#39;mode&#39;: &#39;stock_weight&#39;}
09:29:04.104  sending request: stock_daily {&#39;api&#39;: &#39;pre_trade&#39;, &#39;mode&#39;: &#39;stock_weight&#39;}
09:29:55.385  response received: ... &#34;status&#34;: &#34;completed&#34; ...
```

These are shortened excerpts. The [sanitized original lines](log-evidence.txt) preserve the timestamps and messages.

The first request is accepted promptly. Most of the task&#39;s elapsed time is then spent awaiting application completion. The log does not establish whether the backend is computing, queued behind other requests, or failing to deliver a completion response. **The 300-second timeout is an observed symptom, not 300 seconds of proven avoidable work.**

The selected stock-weight task logs survive only for Nov 11 and Nov 12. Both contain this retry pattern. I cannot use those two logs to claim that the earlier slow dates had the same cause.

## Which tasks are slow after the open

Today, 253 of 316 first-attempt setup or gate instances finish after 09:30. This excludes intentional wait tasks and the long-lived trading sessions. That is a deadline-miss count, not 253 separate root causes. Many short tasks simply inherit a late upstream completion.

The following times are from the original morning attempts, even where the current metadata was overwritten by a later rerun.

| Task or family | Starts | Finishes | Runtime |
|---|---|---|---|
| `zsun_pre_trade_stock_weight` | 09:24:02.972 | 09:29:55.607 | 352.6 s |
| First successful stock target, `zsun_pre_trade_stock_target_pos_ZX7` | 09:29:58.460 | 09:30:02.918 | 4.5 s |
| Last successful stock target, `zsun_pre_trade_stock_target_pos_ZX14` | 09:29:58.721 | 09:31:31.982 | 93.3 s |
| `redis_tpc` | 09:31:34.769 | 09:31:39.523 | 4.8 s |
| `h17.trading.shared_Colo153` | 09:32:27.945 | 09:35:15.291 | 167.3 s |
| `h17.trading.shared_Colo152` | 09:32:27.890 | 09:35:10.548 | 162.7 s |
| `h17.trading.shared_Colo181` | 09:32:17.767 | 09:34:47.845 | 150.1 s |

The 26 stock-target tasks all start within 0.6 seconds of one another, after stock weight finishes. All 26 finish after 09:30. Their median runtime is 34.3 seconds, with a maximum of 93.3 seconds.

Four stock-target tasks, `DC5`, `ZX14`, `ZX8`, and `ZZ1`, retry after a 60-second request timeout. Their runtimes range from 80.5 to 93.3 seconds. Airflow records one attempt for each because these are retries inside the application client.

![Tasks ranked by their own running time after 09:30](late-task-ranking.png &#34;Blue bars exclude time before 09:30, executor queue time, and upstream waits. Red diamonds show historical p90 values for successful first attempts.&#34;)

A stock target that runs from 09:29:58 to 09:31:32 contributes about 92 seconds to this chart. Its full runtime is about 93 seconds. These quantities differ from its completion delay relative to 09:30, and none measures CPU consumption.

### Shared services spend most of their runtime waiting for readiness

For the three slowest shared-service tasks, I matched the log line where the readiness poll identifies the process log with the first Airflow log line that reports a worker thread:

| Shared-service task | Observed readiness interval | Interval | Whole task |
|---|---|---|---|
| `Colo153` | 09:32:33.797 → 09:35:12.466 | 158.7 s | 167.3 s |
| `Colo152` | 09:32:34.089 → 09:35:07.734 | 153.6 s | 162.7 s |
| `Colo181` | 09:32:26.763 → 09:34:44.486 | 137.7 s | 150.1 s |

The worker-readiness interval dominates these task durations. That narrows the next investigation to service initialization and its inputs. It does not identify the cause inside the remote process. I did not profile CPU, storage, model loading, or network activity on those hosts. The [readiness intervals](readiness-phases.csv) use Airflow&#39;s log timestamps, so they also include polling and log-delivery delay.

For `Colo153`, the observed downstream sequence is:

| Step on the path | Completed | Task runtime |
|---|---|---|
| Stock weight | 09:29:55.607 | 352.6 s |
| Stock target, `ZX13` | 09:30:51.194 | 52.3 s |
| Parameters, `HuaTai_ZX13` | 09:31:17.144 | 22.7 s |
| Transfer to `R7`, `HuaTai_ZX13` | 09:31:22.200 | 1.7 s |
| Transfer to `Colo153` | 09:32:04.378 | 39.0 s |
| Last prerequisite account check | 09:32:24.517 | 16.6 s |
| Shared service ready | 09:35:15.291 | 167.3 s |

The transfer and shared-service tasks have multiple upstream accounts. The table follows the latest prerequisite completion at each step, so the account identifier can change between rows. The corresponding stock dependencies are unchanged by the Redis edit in this session.

Stock algo launch and shared-service startup are sibling tasks after the parameter checks. A successful algo-launch task therefore does not establish that the shared worker is ready. Today all 68 stock algo-launch tasks finish by 09:32:47.583, but the last shared-service task finishes at 09:35:15.291. Actual trading readiness needs both, plus the application&#39;s own health signals.

## Redis is waiting, rather than running slowly

The nine futures hedge checks finish by 09:10:40.896. The first stock target succeeds at 09:30:02.918, and the last at 09:31:31.982. Redis starts at 09:31:34.769 and runs for 4.8 seconds.

The morning graph waits for every stock target before Redis can run. The revised graph now expresses two separate conditions:

```text
stock targets ── ONE_SUCCESS ── stock_target_pos.first_ready ──┐
                                                            ├── ALL_SUCCESS ── redis_tpc
hedge checks ─── ALL_DONE ───── futures_hedge.checks_done ──────┘
```

This preserves the existing hedge-check policy: every hedge check must finish, even if one fails. Each futures trading task separately requires its own hedge check and Redis to succeed. Airflow&#39;s [trigger-rule documentation](https://airflow.apache.org/docs/apache-airflow/2.7.3/core-concepts/dags.html#trigger-rules) explains why `ONE_SUCCESS` needs its own gate when combined with another condition.

Using today&#39;s timings, the first stock success would satisfy the remaining data condition at 09:30:02.918, since the hedge checks were already finished. Waiting for the last stock target adds **89.1 seconds of dependency delay**.

That is an estimate of the dependency wait the new graph can remove. It is not a measured 89.1-second improvement in Redis completion, and it would not make Redis start before 09:30. The two new gate tasks have no execution timestamps in today&#39;s run. Their scheduling overhead and the next run&#39;s completion time still need measurement.

## The observed executor queue is a smaller part of today&#39;s delay

![Runtime and executor queue delay by task family](runtime-and-queue.png &#34;Queue delay means queued_dttm to start_date. It does not include time spent waiting for dependencies or waiting to enter the queue.&#34;)

Among 308 setup or gate instances with surviving queue timestamps, median queued-to-running delay is 2.7 seconds, p90 is 3.2 seconds, and the maximum is 3.5 seconds. Those values are much smaller than the 353-second stock-weight run or the 150–167-second shared-service startups.

| Family | Today&#39;s tasks | Median runtime | Maximum runtime | Finish after 09:30 |
|---|---|---|---|---|
| Stock targets | 26 | 34.3 s | 93.3 s | 26 |
| Parameter generation | 34 | 22.0 s | 22.8 s | 34 |
| Host transfer | 22 | 6.4 s | 46.2 s | 22 |
| Parameter checks | 34 | 10.9 s | 22.5 s | 34 |
| Shared service startup | 22 | 46.5 s | 167.3 s | 22 |
| Stock algo launch | 68 | 12.4 s | 31.0 s | 68 |
| Futures algo launch | 9 | 5.3 s | 5.7 s | 9 |
| Hedge checks | 9 | 6.7 s | 7.0 s | 0 |

Queue time only starts when `queued_dttm` is set. A task may have waited for a dependency, a scheduler decision, or capacity before that timestamp. These measurements do not rule out every scheduling delay or historical capacity problem.

The current global parallelism and per-DAG active-task limit are both 128. Today&#39;s numbers do not make another limit increase the first optimization. The [Nov 11 outage]({{&lt; relref &#34;2026-11-11-airflow-outage-postmortem&#34; &gt;}}) was different: configuration drift and restarts disrupted the session. Its 127 recorded failed morning attempts are shown separately from the duration baseline.

## Session-long tasks need a start-time measure

The live stock and futures target-position services intentionally stay alive until about 15:00. Their roughly 330-minute durations are expected behavior, not the slow setup work identified above.

![Cumulative starts of live stock and futures session tasks](live-session-starts.png &#34;A task start is an orchestration milestone. It does not prove that an order was submitted or that all downstream processes were ready.&#34;)

On Nov 12:

- The 34 live stock-session tasks start between 09:30:05.374 and 09:31:34.781.
- The nine live futures-session tasks start between 09:30:10.114 and 09:31:35.351.

For these services, I would track launch time, application readiness, heartbeat coverage, and unexpected exits. A short runtime could actually indicate a failure.

## What I would optimize next

### 1. Explain the stock-weight delay in the backend

This task delays every stock target and both downstream setup branches. I would start by comparing backend changes and input sizes around Oct 23–26, when the recorded runtime rises from about 109 seconds to about 341 seconds.

Add or inspect timestamps for request acceptance, backend work start, work completion, and response delivery, using the same request identifier. Those four timestamps distinguish queue delay, computation, and a lost completion response. Profile the component that occupies the time, rather than increasing Airflow parallelism.

The next change depends on that evidence. Reuse stable intermediate results if repeated computation dominates. Reduce storage or network work if reads dominate. If a completion response is lost, fix response delivery and retry handling.

Shortening the client timeout is not a demonstrated speedup. It may send more duplicate requests while the backend is still working. Before changing retry behavior, verify that the same logical request cannot execute its effects twice.

### 2. Overlap shared-service preparation with account setup where its inputs allow it

The slowest shared task spends 158.7 seconds between readiness polling and its first observed worker message. I would profile startup on `Colo153` and `Colo152`, separating model reads, initialization, external waits, and thread startup.

Then inspect which inputs actually require completed account parameters. If some startup work uses only stable model files, prepare that work earlier and keep a final validation gate before trading uses it. Keep the existing freshness checks and worker-readiness check. A process merely existing is not sufficient readiness.

The potential overlap is bounded by the work that is truly independent. The observed 158.7 seconds is time to investigate, not a promise that all of it can disappear.

This matters for the schedule budget. Today, 319.7 seconds pass between stock-weight completion and the last shared-service success. Keeping that downstream delay unchanged would require stock weight ready around 09:24:40 to finish setup by 09:30. A task that starts after the 09:24 gate and then takes 352.6 seconds leaves too little time. Meeting the deadline needs faster work, safe overlap, or a justified change in input availability, not just a different Redis trigger.

### 3. Validate the Redis gate on the next scheduled run

The graph change is already in the DAG. Check that Redis starts only after both the first successful stock target and all finished hedge checks, then verify that each futures trading task still waits for its own successful hedge check.

Record gate completion, Redis queue time, Redis start, and futures startup completion. Compare dependency wait separately from runtime. Today&#39;s 89.1-second gap is the estimate to test, not a result to publish as a measured speedup.

### 4. Investigate the four slow stock targets and the longest transfers

For `DC5`, `ZX14`, `ZX8`, and `ZZ1`, correlate the 60-second client retries with backend request records. The nearly simultaneous task starts and staggered completions justify checking backend serialization or contention, but do not prove either.

The path to `Colo153` also includes 22.7 seconds of parameter generation and 39.0 seconds of host transfer. Measure bytes transferred, remote command time, and repeated work for that path. Reuse unchanged files or intermediate results where freshness and validation remain intact. Do not remove account checks just to make the graph shorter.

The inspected image-pull log lines report already-current images within fractions of a second. Those selected pulls are a lower priority than the application waits. There is no evidence here for a large gain from changing image-pull policy.

### 5. Measure joint readiness and retain attempt history

Record a readiness timestamp per account and host that requires both the algo launch and its shared service. Alert on missed readiness at 09:30, and distinguish an unresolved task from a successful task that ran late. Add application-level first-use and heartbeat signals so task state is not the only evidence of a working service.

Retain attempt history and task logs outside the container&#39;s writable layer. Today&#39;s reconstruction recovered earlier attempts, but 93 first morning outcomes remain unresolved across the historical sample. Better records would make the next comparison more reliable.

Keep startup capacity visible while the 43 session tasks occupy slots. [Airflow pools](https://airflow.apache.org/docs/apache-airflow/2.7.3/administration-and-deployment/pools.html) can cap related tasks, but a pool alone does not reserve global executor capacity. Change limits only after measuring runnable work waiting for capacity. With [LocalExecutor](https://airflow.apache.org/docs/apache-airflow/2.7.3/core-concepts/executor/local.html), restarting the scheduler can also orphan running tasks, so a restart is not a harmless way to test an optimization during the session.

For each proposed change, collect several comparable scheduled runs with the same input-freshness requirements. Report per-stage readiness and failures together. The next observation I want is whether stock weight still consumes almost the entire six-minute interval from 09:24 to 09:30, and whether shared workers become ready earlier without weakening validation.

## Reproduce the figures

The bundle includes [analyze.py](analyze.py), [attempts.csv](attempts.csv), and [metadata.json](metadata.json). Download them into the same directory and run:

```bash
python analyze.py
```

The script needs `pandas`, `numpy`, and `matplotlib`. It reads the recorded snapshot locally and does not connect to production. It regenerates all six figures and the following tables:

- [Daily readiness](daily-readiness.csv), in seconds relative to 09:30.
- [Family summary](family-summary.csv), with historical sample counts and queue coverage.
- [Every observed first morning setup task on Nov 12](latest-morning-tasks.csv).
- [Headline numbers](summary.json).

The supporting evidence includes [request phases](request-phases.csv), [readiness-poll intervals](readiness-phases.csv), [selected original log lines](log-evidence.txt), and [current run-level timestamps](runs.csv). The last file deliberately retains the misleading afternoon run timestamps so the rerun limitation is visible.

The production inspection was read-only. I did not profile the backend or remote trading hosts, rerun production tasks to benchmark them, or measure a before-and-after improvement from the new Redis gates. Those are the remaining checks behind the optimization suggestions.

## Complete reproduction code and guide

Download the [complete reproduction bundle](reproduce.zip), which contains the scripts, `README.md`, the original timing snapshot, and log evidence. The runner reproduces the saved results without credentials. Its optional `--refresh` mode reads Airflow over SSH; a password, when needed, comes only from `AIRFLOW_SSH_PASSWORD` in the environment.

```bash
unzip reproduce.zip -d hyena17-report
cd hyena17-report
bash run.sh
```

The [analysis script](analyze.py), [read-only exporter](export_airflow.py), and [Bash runner](run.sh) are also available separately. Install the recorded dependencies as described in `README.md` before running. All source files follow below.

### analyze.py

```python
&#34;&#34;&#34;Regenerate this post&#39;s figures and tables from its snapshot with original Airflow identifiers.

Run: python analyze.py
Requires pandas, numpy, and matplotlib. Does not connect to Airflow.
&#34;&#34;&#34;
import json
from pathlib import Path

import matplotlib
matplotlib.use(&#39;Agg&#39;)
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent
TZ = &#39;Asia/Shanghai&#39;
INCIDENT = &#39;2026-11-11&#39;
META = json.loads((ROOT / &#39;metadata.json&#39;).read_text())
LATEST = max(META[&#39;scheduled_dates&#39;])
BLUE, RED, GOLD, GREEN = &#39;#2563a6&#39;, &#39;#c2413b&#39;, &#39;#d49b32&#39;, &#39;#138575&#39;
plt.rcParams.update({&#39;font.family&#39;: &#39;DejaVu Sans&#39;, &#39;font.size&#39;: 10, &#39;axes.spines.top&#39;: False,
                     &#39;axes.spines.right&#39;: False, &#39;axes.titleweight&#39;: &#39;bold&#39;, &#39;savefig.facecolor&#39;: &#39;white&#39;})


def family(task):
    for prefix, label in [
        (&#39;zsun_live_trade_stock_target_pos_&#39;, &#39;Live stock session&#39;),
        (&#39;zsun_live_trade_futures_target_pos_&#39;, &#39;Live futures session&#39;),
        (&#39;zsun_pre_trade_stock_target_pos_&#39;, &#39;Stock targets&#39;),
        (&#39;zsun_pre_trade_futures_target_pos_&#39;, &#39;Futures targets&#39;),
        (&#39;zfu_param_to_R7.&#39;, &#39;Relay transfer&#39;),
        (&#39;zfu_param_to_&#39;, &#39;Host transfer&#39;),
        (&#39;zfu_param_&#39;, &#39;Parameter generation&#39;),
        (&#39;zfu_check_&#39;, &#39;Parameter checks&#39;),
        (&#39;h17.trading.shared_&#39;, &#39;Shared service startup&#39;),
        (&#39;h17.trading.raven_snap_&#39;, &#39;Snapshot service startup&#39;),
        (&#39;h17.trading.&#39;, &#39;Stock algo launch&#39;),
        (&#39;futures_hedge.check.&#39;, &#39;Hedge checks&#39;),
        (&#39;futures_hedge.trading.&#39;, &#39;Futures algo launch&#39;),
        (&#39;wait_until_&#39;, &#39;Intentional wait&#39;),
    ]:
        if task.startswith(prefix):
            return label
    return {&#39;zsun_pre_trade_stock_weight&#39;: &#39;Stock weight&#39;, &#39;redis_tpc&#39;: &#39;Redis startup&#39;,
            &#39;futures_hedge.risk&#39;: &#39;Futures risk&#39;, &#39;futures_hedge.param&#39;: &#39;Futures parameters&#39;}.get(task, &#39;Other setup&#39;)


def save(fig, name):
    fig.savefig(ROOT / name, dpi=165, bbox_inches=&#39;tight&#39;)
    plt.close(fig)


def clock(seconds):
    return (pd.Timestamp(&#39;2000-01-01 09:30&#39;) &#43; pd.Timedelta(seconds=float(seconds))).strftime(&#39;%H:%M:%S&#39;)


def short(task):
    for prefix, label in [
        (&#39;zsun_pre_trade_stock_target_pos_&#39;, &#39;Stock target position&#39;),
        (&#39;h17.trading.shared_&#39;, &#39;Shared services&#39;),
        (&#39;h17.trading.&#39;, &#39;Stock algo launch&#39;),
        (&#39;zfu_param_to_R7.&#39;, &#39;zfu_param_to_R7&#39;),
        (&#39;zfu_param_to_&#39;, &#39;zfu_param_to&#39;),
        (&#39;zfu_param_&#39;, &#39;zfu_param&#39;),
        (&#39;zfu_check_&#39;, &#39;zfu_check&#39;),
        (&#39;futures_hedge.trading.&#39;, &#39;Futures launch&#39;),
    ]:
        if task.startswith(prefix):
            name = task[len(prefix):]
            return f&#39;{label}: {name}&#39;
    return task


def running_seconds_after_deadline(started, ended):
    cutoff = started.dt.normalize() &#43; pd.Timedelta(hours=9, minutes=30)
    runtime = (ended - started).dt.total_seconds()
    late = (ended - cutoff).dt.total_seconds().clip(lower=0)
    return np.minimum(runtime, late)


def load_attempts():
    df = pd.read_csv(ROOT / &#39;attempts.csv&#39;)
    for col in [&#39;started_at&#39;, &#39;ended_at&#39;]:
        df[col] = pd.to_datetime(df[col], utc=True).dt.tz_convert(TZ)
    df[&#39;family&#39;] = df.task_id.map(family)
    cutoff = df.started_at.dt.normalize() &#43; pd.Timedelta(hours=9, minutes=30)
    df[&#39;runtime_s&#39;] = (df.ended_at - df.started_at).dt.total_seconds()
    df[&#39;finish_offset_s&#39;] = (df.ended_at - cutoff).dt.total_seconds()
    df[&#39;start_offset_s&#39;] = (df.started_at - cutoff).dt.total_seconds()
    df[&#39;running_after_s&#39;] = running_seconds_after_deadline(df.started_at, df.ended_at)
    assert df.loc[df.ended_at.notna(), &#39;runtime_s&#39;].ge(0).all(), &#39;Negative duration&#39;
    assert df.queue_seconds.dropna().ge(0).all(), &#39;Negative queue delay&#39;
    assert df.running_after_s.dropna().ge(0).all()
    assert (df.running_after_s.dropna() &lt;= df.runtime_s.dropna() &#43; 0.001).all()
    return df


def run():
    df = load_attempts()
    morning = df[df.started_at.dt.strftime(&#39;%Y-%m-%d&#39;).eq(df.date)
                 &amp; df.started_at.dt.hour.ge(9) &amp; df.started_at.dt.hour.lt(12)].copy()
    first = morning.sort_values(&#39;started_at&#39;).drop_duplicates([&#39;date&#39;, &#39;task_id&#39;])
    success = first[first.state.eq(&#39;success&#39;)].copy()
    latest = success[success.date.eq(LATEST)].copy()
    session = latest.family.str.startswith(&#39;Live &#39;)
    setup = latest[~session &amp; ~latest.family.eq(&#39;Intentional wait&#39;)].copy()
    available_dates = sorted(success.loc[success.family.eq(&#39;Stock weight&#39;), &#39;date&#39;].unique())
    baseline = success[success.date.isin(set(available_dates) - {INCIDENT})]

    # Readiness uses the first successful morning attempt, including recovery attempts.
    recovered = morning[morning.state.eq(&#39;success&#39;)].sort_values(&#39;ended_at&#39;).drop_duplicates([&#39;date&#39;, &#39;task_id&#39;])
    history = []
    for day in META[&#39;scheduled_dates&#39;]:
        g = recovered[recovered.date.eq(day)]
        def offset(label, agg=&#39;max&#39;):
            v = g.loc[g.family.eq(label), &#39;finish_offset_s&#39;]
            return getattr(v, agg)() if len(v) else np.nan
        history.append({&#39;date&#39;: day, &#39;Stock weight done&#39;: offset(&#39;Stock weight&#39;),
                        &#39;First stock target&#39;: offset(&#39;Stock targets&#39;, &#39;min&#39;),
                        &#39;Last stock target&#39;: offset(&#39;Stock targets&#39;), &#39;Redis done&#39;: offset(&#39;Redis startup&#39;),
                        &#39;Last algo launch&#39;: offset(&#39;Stock algo launch&#39;), &#39;Last shared ready&#39;: offset(&#39;Shared service startup&#39;)})
    history = pd.DataFrame(history).set_index(&#39;date&#39;)
    history.to_csv(ROOT / &#39;daily-readiness.csv&#39;, float_format=&#39;%.3f&#39;)

    # Latest morning timeline, with queues shown only when the original queue timestamp survived.
    stock = latest[latest.family.eq(&#39;Stock targets&#39;)].sort_values(&#39;ended_at&#39;)
    slow_shared = latest[latest.family.eq(&#39;Shared service startup&#39;)].nlargest(4, &#39;runtime_s&#39;)
    algo = latest[latest.family.eq(&#39;Stock algo launch&#39;)].sort_values(&#39;task_id&#39;)
    shared = latest[latest.family.eq(&#39;Shared service startup&#39;)].sort_values(&#39;task_id&#39;)
    futures = latest[latest.family.eq(&#39;Futures algo launch&#39;)].sort_values(&#39;task_id&#39;)
    params = latest[latest.family.eq(&#39;Parameter generation&#39;)].sort_values(&#39;task_id&#39;)
    relay = latest[latest.family.eq(&#39;Relay transfer&#39;)].sort_values(&#39;task_id&#39;)
    transfers = latest[latest.family.eq(&#39;Host transfer&#39;)].sort_values(&#39;task_id&#39;)
    checks = latest[latest.family.eq(&#39;Parameter checks&#39;)].sort_values(&#39;task_id&#39;)
    account_colos = algo.task_id.str.removeprefix(&#39;h17.trading.&#39;).str.split(&#39;_&#39;, n=1)
    accounts = {parts[1] for parts in account_colos}
    colos = {parts[0] for parts in account_colos}
    assert accounts == set(latest.loc[latest.family.eq(&#39;Live stock session&#39;), &#39;task_id&#39;].str.removeprefix(&#39;zsun_live_trade_stock_target_pos_&#39;))
    assert colos == set(shared.task_id.str.removeprefix(&#39;h17.trading.shared_&#39;))
    assert set(futures.task_id.str.removeprefix(&#39;futures_hedge.trading.&#39;)) == set(latest.loc[latest.family.eq(&#39;Live futures session&#39;), &#39;task_id&#39;].str.removeprefix(&#39;zsun_live_trade_futures_target_pos_&#39;))
    assert accounts == set(params.task_id.str.removeprefix(&#39;zfu_param_&#39;))
    assert accounts == set(relay.task_id.str.removeprefix(&#39;zfu_param_to_R7.&#39;))
    assert accounts == set(checks.task_id.str.removeprefix(&#39;zfu_check_&#39;))
    assert colos == set(transfers.task_id.str.removeprefix(&#39;zfu_param_to_&#39;))
    panels = [
        (f&#39;{LATEST}: stock weight and all {len(stock)} fund targets&#39;, pd.concat([latest[latest.family.eq(&#39;Stock weight&#39;)], stock])),
        (f&#39;zfu_param generation: all {len(params)} accounts&#39;, params),
        (f&#39;zfu_param_to_R7 transfers: all {len(relay)} accounts&#39;, relay),
        (f&#39;zfu_param_to_Colo transfers: all {len(transfers)} colos&#39;, transfers),
        (f&#39;zfu_check validation: all {len(checks)} accounts&#39;, checks),
        (f&#39;Stock algo launches: {len(accounts)} accounts, {len(colos)} colos, {len(algo)} account/colo tasks&#39;, algo),
        (f&#39;Shared services: all {len(shared)} colos&#39;, shared),
        (f&#39;Redis, all {len(futures)} futures account launches, and risk&#39;, pd.concat([latest[latest.family.eq(&#39;Redis startup&#39;)], futures, latest[latest.family.eq(&#39;Futures risk&#39;)]])),
    ]
    timeline_families = [&#39;Stock weight&#39;, &#39;Stock targets&#39;, &#39;Parameter generation&#39;, &#39;Relay transfer&#39;,
                         &#39;Host transfer&#39;, &#39;Parameter checks&#39;, &#39;Stock algo launch&#39;,
                         &#39;Shared service startup&#39;, &#39;Redis startup&#39;, &#39;Futures algo launch&#39;, &#39;Futures risk&#39;]
    expected_tasks = set(latest.loc[latest.family.isin(timeline_families), &#39;task_id&#39;])
    drawn_tasks = [task for _, rows in panels for task in rows.task_id]
    assert len(drawn_tasks) == len(set(drawn_tasks)) and set(drawn_tasks) == expected_tasks
    fig, axes = plt.subplots(len(panels), 1, figsize=(16, sum(len(rows) for _, rows in panels)*.24&#43;5),
                             gridspec_kw={&#39;height_ratios&#39;: [len(rows)&#43;3 for _, rows in panels]})
    for ax, (title, rows) in zip(axes, panels):
        ax.axvspan(0, 6.1, color=RED, alpha=.045)
        for y, row in enumerate(rows.itertuples()):
            start = row.start_offset_s / 60
            width = row.runtime_s / 60
            if pd.notna(row.queue_seconds):
                ax.barh(y, row.queue_seconds / 60, left=start-row.queue_seconds/60, height=.55, color=GOLD)
            ax.barh(y, width, left=start, height=.55, color=BLUE)
            ax.text(start&#43;width&#43;.04, y, f&#39;{row.runtime_s:.1f}s&#39;, va=&#39;center&#39;, fontsize=8.5)
        ax.set_yticks(range(len(rows)), [short(s) for s in rows.task_id], fontsize=9)
        ax.invert_yaxis()
        ax.axvline(0, color=RED, lw=1.4)
        ax.set_xlim(-6.2, 6.05)
        ax.set_xticks(np.arange(-6, 7, 1), [clock(x*60)[:5] for x in range(-6, 7)])
        ax.set_title(title, loc=&#39;left&#39;, pad=14)
        ax.grid(axis=&#39;x&#39;, alpha=.18)
    axes[-1].set_xlabel(&#39;Local time, UTC&#43;8. Blue = task running; amber = queued to running, where available.&#39;)
    fig.tight_layout()
    save(fig, &#39;morning-timeline.png&#39;)

    # Historical completion times, not summed parallel task durations.
    values = history.to_numpy(dtype=float)/60
    fig, ax = plt.subplots(figsize=(12, 10.2))
    cmap = plt.get_cmap(&#39;RdYlBu_r&#39;).copy()
    cmap.set_bad(&#39;#e2e5e9&#39;)
    image = ax.imshow(np.ma.masked_invalid(values), aspect=&#39;auto&#39;, cmap=cmap,
                      norm=TwoSlopeNorm(vmin=-10, vcenter=0, vmax=10))
    for y in range(len(history)):
        for x in range(len(history.columns)):
            value = history.iloc[y, x]
            ax.text(x, y, clock(value) if np.isfinite(value) else &#39;no record&#39;, ha=&#39;center&#39;, va=&#39;center&#39;, fontsize=8.5,
                    color=&#39;white&#39; if np.isfinite(value) and abs(value)&gt;480 else &#39;#18212b&#39;)
    ax.set_xticks(range(len(history.columns)), [s.replace(&#39; &#39;, &#39;\n&#39;, 1) for s in history.columns])
    ax.set_yticks(range(len(history)), [d &#43; (&#39;  * incident&#39; if d == INCIDENT else &#39;&#39;) for d in history.index])
    ax.set_title(&#39;Twenty scheduled dates: when did each stage finish?&#39;, loc=&#39;left&#39;, pad=18)
    ax.text(0, -.11, &#39;UTC&#43;8. Gray = missing successful morning record, not an on-time completion.\n&#39;
            &#39;Color clips at &#43;/-10 minutes; printed timestamps retain the full delay. Incident day is separate from baseline.&#39;,
            transform=ax.transAxes, fontsize=9)
    fig.colorbar(image, ax=ax, shrink=.8, label=&#39;Minutes relative to 09:30&#39;)
    fig.tight_layout()
    save(fig, &#39;readiness-history.png&#39;)

    # Rank own runtime after the deadline. This is not end-to-end lateness or CPU time.
    ranking = setup[setup.running_after_s.gt(0)].nlargest(14, &#39;running_after_s&#39;).sort_values(&#39;running_after_s&#39;)
    historical = baseline.groupby(&#39;task_id&#39;).running_after_s.quantile(.9)
    fig, ax = plt.subplots(figsize=(12, 7.8))
    ax.barh(range(len(ranking)), ranking.running_after_s, color=BLUE, height=.6, label=f&#39;{LATEST} first attempt&#39;)
    p90 = [historical.get(t, np.nan) for t in ranking.task_id]
    ax.scatter(p90, np.arange(len(ranking))-.23, color=RED, marker=&#39;D&#39;, s=27, label=&#39;Historical p90, successful first attempts&#39;)
    for y, row in enumerate(ranking.itertuples()):
        ax.text(row.running_after_s&#43;3, y, f&#39;{row.running_after_s:.1f}s; done {row.ended_at:%H:%M:%S}&#39;, va=&#39;center&#39;, fontsize=8)
    ax.set_yticks(range(len(ranking)), [short(t) for t in ranking.task_id], fontsize=9)
    ax.set_xlim(0, max(ranking.running_after_s.max(), np.nanmax(p90))*1.34)
    ax.set_xlabel(&#39;Seconds this task was running after 09:30, excluding queue and upstream waits&#39;)
    ax.set_title(&#39;The longest setup tasks after the open are shared-service startups&#39;, loc=&#39;left&#39;, pad=18)
    ax.legend(loc=&#39;lower right&#39;, fontsize=8)
    ax.grid(axis=&#39;x&#39;, alpha=.18)
    fig.tight_layout()
    save(fig, &#39;late-task-ranking.png&#39;)

    # Dependency readiness and queue delay are different intervals.
    families = [&#39;Stock weight&#39;, &#39;Stock targets&#39;, &#39;Parameter generation&#39;, &#39;Host transfer&#39;, &#39;Parameter checks&#39;,
                &#39;Shared service startup&#39;, &#39;Stock algo launch&#39;, &#39;Redis startup&#39;, &#39;Futures algo launch&#39;, &#39;Hedge checks&#39;]
    family_rows=[]
    for label in families:
        g=setup[setup.family.eq(label)]
        b=baseline[baseline.family.eq(label)]
        family_rows.append({&#39;family&#39;:label, &#39;latest_n&#39;:len(g), &#39;latest_runtime_p50_s&#39;:g.runtime_s.median(),
                            &#39;latest_runtime_max_s&#39;:g.runtime_s.max(), &#39;latest_late_n&#39;:int(g.finish_offset_s.gt(0).sum()),
                            &#39;latest_queue_n&#39;:int(g.queue_seconds.notna().sum()), &#39;latest_queue_p50_s&#39;:g.queue_seconds.median(),
                            &#39;latest_queue_max_s&#39;:g.queue_seconds.max(), &#39;historical_n&#39;:len(b),
                            &#39;historical_runtime_p50_s&#39;:b.runtime_s.median(), &#39;historical_runtime_p90_s&#39;:b.runtime_s.quantile(.9)})
    family_table=pd.DataFrame(family_rows)
    family_table.to_csv(ROOT/&#39;family-summary.csv&#39;,index=False,float_format=&#39;%.3f&#39;)
    fig, axes = plt.subplots(1, 2, figsize=(12, 6.6))
    for ax, column, title, color in [(axes[0],&#39;latest_runtime_p50_s&#39;,&#39;Median task runtime&#39;,BLUE),
                                    (axes[1],&#39;latest_queue_p50_s&#39;,&#39;Median queued-to-running delay&#39;,GOLD)]:
        ax.barh(family_table.family, family_table[column], color=color, height=.6)
        ax.invert_yaxis()
        ax.set_title(title,loc=&#39;left&#39;)
        ax.set_xlabel(&#39;Seconds&#39;)
        ax.grid(axis=&#39;x&#39;,alpha=.18)
        for y, value in enumerate(family_table[column]):
            if pd.notna(value):
                ax.text(value&#43;family_table[column].max()*.015,y,f&#39;{value:.1f}&#39;,va=&#39;center&#39;,fontsize=9)
        ax.margins(x=.15)
    axes[1].tick_params(labelleft=False)
    fig.suptitle(f&#39;{LATEST}: observed executor queue delays are much smaller than task runtime&#39;,x=.02,ha=&#39;left&#39;,fontweight=&#39;bold&#39;)
    fig.text(.02,.005,&#39;Queue timestamps survive only for matching current task instances. Time before queueing is not measured here.&#39;,fontsize=9)
    fig.tight_layout(rect=[0,.03,1,.95])
    save(fig,&#39;runtime-and-queue.png&#39;)

    # This is an observational change in recorded timings, not a controlled benchmark.
    weights = recovered[recovered.family.eq(&#39;Stock weight&#39;)].sort_values(&#39;date&#39;)
    fig, ax = plt.subplots(figsize=(11.5, 4.8))
    xpos = np.arange(len(weights))
    colors = [RED if d == INCIDENT else BLUE for d in weights.date]
    ax.bar(xpos, weights.runtime_s, color=colors, width=.65)
    ax.axhline(300, color=GOLD, ls=&#39;--&#39;, lw=1.4, label=&#39;300s request timeout seen in Nov 11-12 logs&#39;)
    ax.set_xticks(xpos, [d[5:] for d in weights.date], rotation=45, ha=&#39;right&#39;)
    ax.set_ylabel(&#39;Task runtime, seconds&#39;)
    ax.set_xlabel(&#39;Scheduled date, 2026. Earlier task logs are unavailable in the rebuilt container.&#39;)
    ax.set_title(&#39;Stock-weight time rises from about 109s to about 341s after Oct 23&#39;, loc=&#39;left&#39;, pad=15)
    ax.legend(loc=&#39;upper left&#39;, fontsize=8)
    ax.grid(axis=&#39;y&#39;, alpha=.18)
    fig.tight_layout()
    save(fig, &#39;stock-weight-history.png&#39;)

    # Long-lived tasks get a launch-time measure instead of a five-hour &#34;slow&#34; flag.
    live = first[first.date.eq(LATEST) &amp; first.family.str.startswith(&#39;Live &#39;)].copy()
    fig, axes=plt.subplots(2,1,figsize=(11,5.8),sharex=True)
    for ax,label in zip(axes,[&#39;Live stock session&#39;,&#39;Live futures session&#39;]):
        g=live[live.family.eq(label)].sort_values(&#39;start_offset_s&#39;)
        x=np.sort(np.r_[0,g.start_offset_s.to_numpy()/60])
        ax.step(x,np.arange(len(x)),where=&#39;post&#39;,color=GREEN,lw=2)
        ax.scatter(g.start_offset_s/60,np.arange(1,len(g)&#43;1),s=14,color=GREEN)
        ax.set_ylabel(&#39;Tasks started&#39;)
        ax.set_title(f&#39;{label}: {len(g)} starts, {clock(g.start_offset_s.min())} to {clock(g.start_offset_s.max())}&#39;,loc=&#39;left&#39;)
        ax.grid(alpha=.18)
    axes[-1].set_xlabel(&#39;Minutes after 09:30. A task start does not prove the first order or downstream service readiness.&#39;)
    axes[-1].set_xlim(0,max(live.start_offset_s)/60*1.08)
    fig.tight_layout()
    save(fig,&#39;live-session-starts.png&#39;)

    setup.sort_values(&#39;finish_offset_s&#39;,ascending=False)[[&#39;task_id&#39;,&#39;family&#39;,&#39;started_at&#39;,&#39;ended_at&#39;,&#39;runtime_s&#39;,&#39;running_after_s&#39;,&#39;queue_seconds&#39;,&#39;source&#39;]].to_csv(ROOT/&#39;latest-morning-tasks.csv&#39;,index=False,float_format=&#39;%.3f&#39;)
    stock_weight=latest[latest.family.eq(&#39;Stock weight&#39;)].iloc[0]
    redis=latest[latest.family.eq(&#39;Redis startup&#39;)].iloc[0]
    checks=latest[latest.family.eq(&#39;Hedge checks&#39;)]
    first_stock=stock.ended_at.min()
    last_stock=stock.ended_at.max()
    eligible=max(first_stock,checks.ended_at.max())
    summary={&#39;date_range&#39;:[min(META[&#39;scheduled_dates&#39;]),LATEST], &#39;scheduled_dates&#39;:len(META[&#39;scheduled_dates&#39;]),
             &#39;baseline_dates&#39;:len(set(available_dates)-{INCIDENT}), &#39;first_attempt_states&#39;:first.state.value_counts().to_dict(),
             &#39;latest_first_attempt_states&#39;:first[first.date.eq(LATEST)].state.value_counts().to_dict(),
             &#39;stock_weight_runtime_s&#39;:stock_weight.runtime_s,&#39;stock_weight_finish&#39;:str(stock_weight.ended_at),
             &#39;stock_weight_headroom_s&#39;:-stock_weight.finish_offset_s,&#39;stock_targets&#39;:len(stock),
             &#39;first_stock_done&#39;:str(first_stock),&#39;last_stock_done&#39;:str(last_stock),
             &#39;stock_target_barrier_s&#39;:(last_stock-first_stock).total_seconds(), &#39;redis_started&#39;:str(redis.started_at),
             &#39;redis_runtime_s&#39;:redis.runtime_s, &#39;last_hedge_check_done&#39;:str(checks.ended_at.max()),
             &#39;new_redis_eligibility_lower_bound&#39;:str(eligible), &#39;latest_setup_tasks&#39;:len(setup),
             &#39;latest_late_setup_tasks&#39;:int(setup.finish_offset_s.gt(0).sum()),
             &#39;latest_setup_queue_p50_s&#39;:setup.queue_seconds.median(), &#39;latest_setup_queue_p90_s&#39;:setup.queue_seconds.quantile(.9),
             &#39;latest_setup_queue_max_s&#39;:setup.queue_seconds.max(),&#39;latest_queue_samples&#39;:int(setup.queue_seconds.notna().sum()),
             &#39;latest_running_session_tasks&#39;:len(live),
             &#39;live_session_launches&#39;:{label:{&#39;count&#39;:len(g),&#39;first&#39;:str(g.started_at.min()),&#39;last&#39;:str(g.started_at.max())} for label,g in live.groupby(&#39;family&#39;)},
             &#39;latest_slowest_shared&#39;:slow_shared[[&#39;task_id&#39;,&#39;runtime_s&#39;,&#39;ended_at&#39;]].astype({&#39;ended_at&#39;:str}).to_dict(&#39;records&#39;),
             &#39;missing_stock_weight_dates&#39;:sorted(set(META[&#39;scheduled_dates&#39;])-set(available_dates)),
             &#39;incident_morning_failures&#39;:int(morning[morning.date.eq(INCIDENT)].state.eq(&#39;failed&#39;).sum())}
    (ROOT/&#39;summary.json&#39;).write_text(json.dumps(summary,indent=2,default=str)&#43;&#39;\n&#39;)
    print(json.dumps(summary,indent=2,default=str))
    print(&#39;\nFAMILY SUMMARY\n&#39;&#43;family_table.round(2).to_string(index=False))


if __name__==&#39;__main__&#39;:
    assert short(&#39;zsun_pre_trade_stock_target_pos_ZX7&#39;) == &#39;Stock target position: ZX7&#39;
    assert short(&#39;h17.trading.shared_Colo153&#39;) == &#39;Shared services: Colo153&#39;
    assert family(&#39;h17.trading.Colo153_Broker_Account&#39;) == &#39;Stock algo launch&#39;
    assert family(&#39;zfu_param_to_Colo153&#39;) == &#39;Host transfer&#39;
    assert family(&#39;zfu_param_to_R7.Broker_Account&#39;) == &#39;Relay transfer&#39;
    starts = pd.Series(pd.to_datetime([&#39;2026-11-12T01:28Z&#39;, &#39;2026-11-12T01:29Z&#39;,
                                      &#39;2026-11-12T01:31Z&#39;, &#39;2026-11-12T01:31Z&#39;])).dt.tz_convert(TZ)
    ends = pd.Series(pd.to_datetime([&#39;2026-11-12T01:29Z&#39;, &#39;2026-11-12T01:31Z&#39;,
                                    &#39;2026-11-12T01:33Z&#39;, None])).dt.tz_convert(TZ)
    overlap = running_seconds_after_deadline(starts, ends)
    assert overlap.iloc[:3].tolist() == [0, 60, 120]
    assert pd.isna(overlap.iloc[3]), &#39;An unfinished task must not become a zero-duration success&#39;
    run()
```

### export_airflow.py

```python
&#34;&#34;&#34;Read-only export of the latest 20 completed trading.hyena17 scheduled runs.

Run inside the existing Airflow container: python export_airflow.py
Save that output locally, then run: python export_airflow.py --write-snapshot OUTPUT
Only task timing and non-secret configuration fields are exported.
&#34;&#34;&#34;
import csv
from datetime import datetime, timezone
import io
import json
import os
from pathlib import Path
import sys
import tempfile

DAG_ID = &#39;trading.hyena17&#39;
PREFIX = &#39;AIRFLOW_TIMING_JSON=&#39;
FIELDS = [&#39;date&#39;, &#39;task_id&#39;, &#39;attempt&#39;, &#39;started_at&#39;, &#39;ended_at&#39;, &#39;state&#39;, &#39;queue_seconds&#39;, &#39;source&#39;]


def utc(value):
    if value is None:
        return None
    if isinstance(value, str):
        value = datetime.fromisoformat(value)
    return value.replace(tzinfo=timezone.utc) if value.tzinfo is None else value.astimezone(timezone.utc)


def reconstruct(events, tasks, failures):
    rows, pending, unmatched = [], {}, 0
    for event in events:
        key = event[&#39;execution_date&#39;], event[&#39;task_id&#39;]
        if event[&#39;event&#39;] == &#39;running&#39;:
            if key in pending:
                rows.append(pending.pop(key))
            pending[key] = {&#39;date&#39;: str(event[&#39;execution_date&#39;])[:10], &#39;task_id&#39;: event[&#39;task_id&#39;],
                            &#39;started_at&#39;: utc(event[&#39;dttm&#39;]), &#39;ended_at&#39;: None, &#39;state&#39;: &#39;unknown&#39;,
                            &#39;queue_seconds&#39;: None, &#39;source&#39;: &#39;audit_log_unfinished&#39;}
        elif key in pending:
            row = pending.pop(key)
            row.update(ended_at=utc(event[&#39;dttm&#39;]), state=event[&#39;event&#39;], source=&#39;audit_log&#39;)
            rows.append(row)
        else:
            unmatched &#43;= 1
    rows.extend(pending.values())
    lookup = {}
    for row in rows:
        lookup.setdefault((row[&#39;date&#39;], row[&#39;task_id&#39;]), []).append(row)
    for records, source in [(tasks, &#39;task_instance&#39;), (failures, &#39;task_fail&#39;)]:
        for task in records:
            start, end = utc(task[&#39;start_date&#39;]), utc(task[&#39;end_date&#39;])
            if start is None:
                continue
            day = task[&#39;run_id&#39;][len(&#39;scheduled__&#39;):len(&#39;scheduled__&#39;) &#43; 10]
            state = task.get(&#39;state&#39;, &#39;failed&#39;)
            candidates = lookup.get((day, task[&#39;task_id&#39;]), [])
            match = next((row for row in candidates if abs((row[&#39;started_at&#39;] - start).total_seconds()) &lt; 1
                          and ((row[&#39;state&#39;] == &#39;unknown&#39; and row[&#39;ended_at&#39;] is None)
                               or (row[&#39;state&#39;] == state and row[&#39;ended_at&#39;] and end
                                   and abs((row[&#39;ended_at&#39;] - end).total_seconds()) &lt; 1))), None)
            if match is None:
                if end is None or state not in [&#39;success&#39;, &#39;failed&#39;] or task.get(&#39;operator&#39;) != &#39;EmptyOperator&#39;:
                    continue
                match = {&#39;date&#39;: day, &#39;task_id&#39;: task[&#39;task_id&#39;], &#39;queue_seconds&#39;: None}
                rows.append(match)
                lookup.setdefault((day, task[&#39;task_id&#39;]), []).append(match)
            match.update(started_at=start, ended_at=end, state=state, source=source)
            queued = utc(task.get(&#39;queued_dttm&#39;))
            if queued and queued &lt;= start:
                match[&#39;queue_seconds&#39;] = (start - queued).total_seconds()
    rows.sort(key=lambda row: (row[&#39;date&#39;], row[&#39;task_id&#39;], row[&#39;started_at&#39;]))
    counts = {}
    for row in rows:
        key = row[&#39;date&#39;], row[&#39;task_id&#39;]
        counts[key] = counts.get(key, 0) &#43; 1
        row[&#39;attempt&#39;] = counts[key]
        row[&#39;started_at&#39;] = row[&#39;started_at&#39;].isoformat()
        row[&#39;ended_at&#39;] = row[&#39;ended_at&#39;].isoformat() if row[&#39;ended_at&#39;] else &#39;&#39;
    return rows, unmatched


def capture():
    import airflow
    from airflow import settings
    from airflow.configuration import conf
    from sqlalchemy import bindparam, text

    engine = settings.engine
    with engine.connect() as conn:
        if engine.dialect.name == &#39;mysql&#39;:
            conn.execute(text(&#39;SET SESSION TRANSACTION READ ONLY&#39;))
        def read(query, values):
            return [dict(row._mapping) for row in conn.execute(query, values)]
        runs = read(text(&#34;SELECT run_id,execution_date,start_date,end_date,state,dag_hash FROM dag_run &#34;
                         &#34;WHERE dag_id=:dag AND run_type=&#39;scheduled&#39; AND state IN (&#39;success&#39;,&#39;failed&#39;) &#34;
                         &#34;ORDER BY execution_date DESC LIMIT 20&#34;), {&#39;dag&#39;: DAG_ID})
        if not runs:
            raise ValueError(&#39;No completed scheduled runs found&#39;)
        params = {&#39;dag&#39;: DAG_ID, &#39;runs&#39;: [row[&#39;run_id&#39;] for row in runs]}
        def task_rows(table, columns):
            query = text(&#39;SELECT &#39; &#43; columns &#43; &#39; FROM &#39; &#43; table
                         &#43; &#39; WHERE dag_id=:dag AND run_id IN :runs&#39;).bindparams(bindparam(&#39;runs&#39;, expanding=True))
            return read(query, params)
        tasks = task_rows(&#39;task_instance&#39;, &#39;run_id,task_id,state,start_date,end_date,queued_dttm,operator&#39;)
        failures = task_rows(&#39;task_fail&#39;, &#39;run_id,task_id,start_date,end_date&#39;)
        query = text(&#34;SELECT dttm,task_id,event,execution_date FROM log WHERE dag_id=:dag &#34;
                     &#34;AND execution_date IN :dates AND event IN (&#39;running&#39;,&#39;success&#39;,&#39;failed&#39;) &#34;
                     &#34;ORDER BY execution_date,task_id,dttm,id&#34;).bindparams(bindparam(&#39;dates&#39;, expanding=True))
        events = read(query, {&#39;dag&#39;: DAG_ID, &#39;dates&#39;: [row[&#39;execution_date&#39;] for row in runs]})
    attempts, unmatched = reconstruct(events, tasks, failures)
    metadata = {&#39;collected_at_utc&#39;: datetime.now(timezone.utc).isoformat(), &#39;dag_id&#39;: DAG_ID,
                &#39;airflow_version&#39;: airflow.__version__, &#39;timezone&#39;: conf.get(&#39;core&#39;, &#39;default_timezone&#39;),
                &#39;executor&#39;: conf.get(&#39;core&#39;, &#39;executor&#39;),
                &#39;config&#39;: {key: conf.get(section, key) for section, key in [
                    (&#39;core&#39;, &#39;parallelism&#39;), (&#39;core&#39;, &#39;max_active_tasks_per_dag&#39;),
                    (&#39;core&#39;, &#39;max_active_runs_per_dag&#39;), (&#39;scheduler&#39;, &#39;scheduler_heartbeat_sec&#39;)]},
                &#39;scheduled_dates&#39;: sorted(str(row[&#39;execution_date&#39;])[:10] for row in runs),
                &#39;dag_hashes&#39;: len({row[&#39;dag_hash&#39;] for row in runs}), &#39;current_task_rows&#39;: len(tasks),
                &#39;failure_rows&#39;: len(failures), &#39;audit_event_count&#39;: len(events),
                &#39;ignored_terminals_without_start&#39;: unmatched}
    run_rows = [{&#39;date&#39;: str(row[&#39;execution_date&#39;])[:10], &#39;state&#39;: row[&#39;state&#39;],
                 &#39;metadata_start_utc&#39;: utc(row[&#39;start_date&#39;]).isoformat() if row[&#39;start_date&#39;] else &#39;&#39;,
                 &#39;metadata_end_utc&#39;: utc(row[&#39;end_date&#39;]).isoformat() if row[&#39;end_date&#39;] else &#39;&#39;}
                for row in reversed(runs)]
    return {&#39;metadata&#39;: metadata, &#39;attempts&#39;: attempts, &#39;runs&#39;: run_rows}


def csv_text(rows, fields):
    buffer = io.StringIO(newline=&#39;&#39;)
    writer = csv.DictWriter(buffer, fieldnames=fields)
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue()


def write_snapshot(path):
    lines = [line[len(PREFIX):] for line in Path(path).read_text().splitlines() if line.startswith(PREFIX)]
    if len(lines) != 1:
        raise ValueError(&#39;Expected exactly one complete timing snapshot in the SSH output&#39;)
    snapshot = json.loads(lines[0])
    if snapshot[&#39;metadata&#39;][&#39;dag_id&#39;] != DAG_ID or not snapshot[&#39;attempts&#39;]:
        raise ValueError(&#39;Wrong DAG or empty task snapshot&#39;)
    contents = {
        &#39;attempts.csv&#39;: csv_text(snapshot[&#39;attempts&#39;], FIELDS),
        &#39;metadata.json&#39;: json.dumps(snapshot[&#39;metadata&#39;], indent=2) &#43; &#39;\n&#39;,
        &#39;runs.csv&#39;: csv_text(snapshot[&#39;runs&#39;], [&#39;date&#39;, &#39;state&#39;, &#39;metadata_start_utc&#39;, &#39;metadata_end_utc&#39;]),
    }
    root = Path(__file__).resolve().parent
    for name, content in contents.items():
        with tempfile.NamedTemporaryFile(mode=&#39;w&#39;, dir=root, prefix=&#39;.&#39; &#43; name, delete=False) as handle:
            handle.write(content)
            temporary = handle.name
        os.replace(temporary, root / name)
    print(&#39;Saved timing snapshot for &#39; &#43; snapshot[&#39;metadata&#39;][&#39;scheduled_dates&#39;][-1])


if __name__ == &#39;__main__&#39;:
    if len(sys.argv) == 3 and sys.argv[1] == &#39;--write-snapshot&#39;:
        write_snapshot(sys.argv[2])
    elif len(sys.argv) == 1:
        print(PREFIX &#43; json.dumps(capture()))
    else:
        raise SystemExit(&#39;Usage: export_airflow.py [--write-snapshot SSH_OUTPUT]&#39;)
```

### run.sh

```bash
#!/usr/bin/env bash
set &#43;x
set -euo pipefail
cd -- &#34;$(dirname -- &#34;${BASH_SOURCE[0]}&#34;)&#34;
python_bin=&#34;${PYTHON:-python3}&#34;
if [[ $# -gt 1 || ( $# -eq 1 &amp;&amp; &#34;$1&#34; != --refresh ) ]]; then
    echo &#39;Usage: ./run.sh [--refresh]&#39; &gt;&amp;2
    exit 2
fi
if [[ &#34;${1:-}&#34; == --refresh ]]; then
    ssh_user=&#34;${AIRFLOW_SSH_USER:-infra}&#34;
    ssh_host=&#34;${AIRFLOW_SSH_HOST:-infra.t1}&#34;
    snapshot_file=&#34;$(mktemp)&#34;
    trap &#39;rm -f -- &#34;$snapshot_file&#34;&#39; EXIT
    ssh_command=(ssh -o ConnectTimeout=15)
    if [[ -n &#34;${AIRFLOW_SSH_PASSWORD:-}&#34; ]]; then
        command -v sshpass &gt;/dev/null || { echo &#39;Password authentication needs sshpass.&#39; &gt;&amp;2; exit 1; }
        ssh_command=(sshpass -e ssh -o ConnectTimeout=15 -o NumberOfPasswordPrompts=1)
    else
        ssh_command&#43;=(-o BatchMode=yes)
    fi
    SSHPASS=&#34;${AIRFLOW_SSH_PASSWORD:-}&#34; &#34;${ssh_command[@]}&#34; &#34;$ssh_user@$ssh_host&#34; \
        &#39;docker exec -i airflow /usr/local/python3/bin/python3 -&#39; \
        &lt; export_airflow.py &gt; &#34;$snapshot_file&#34;
    unset AIRFLOW_SSH_PASSWORD
    &#34;$python_bin&#34; export_airflow.py --write-snapshot &#34;$snapshot_file&#34;
fi
&#34;$python_bin&#34; analyze.py
```

### README.md

````markdown
# Reproduce the trading.hyena17 timing report

`./run.sh` regenerates all six plots and summary tables from the included snapshot. It does not contact Airflow or need credentials. The first chart contains all 252 selected startup tasks, including parameter generation, transfers, and checks.

## Install and run

Use Python 3.11. The original environment used Python 3.11.4 with these package versions:

```bash
python3.11 -m venv .venv
.venv/bin/python -m pip install pandas==1.5.2 numpy==1.26.4 matplotlib==3.10.6
PYTHON=.venv/bin/python bash run.sh
```

Run from the directory containing `run.sh`, `analyze.py`, `attempts.csv`, and `metadata.json`. The script also works when invoked by its absolute path. If the dependencies are already installed, `bash run.sh` is sufficient.

The historical snapshot covers 20 scheduled dates from 2026-10-16 through 2026-11-12. Times are converted from UTC to Asia/Shanghai, UTC&#43;8. No tasks are rerun. The included task and account names are the original Airflow identifiers.

## Files and outputs

- `analyze.py`: the complete plotting and summary script, including deadline-overlap and coverage checks.
- `export_airflow.py`: read-only metadata export and reconstruction of earlier task attempts from audit events.
- `attempts.csv`, `metadata.json`, and `runs.csv`: the recorded timing snapshot.
- Six PNG figures, including `morning-timeline.png`, the full 252-row startup timeline.
- `daily-readiness.csv`, `family-summary.csv`, `latest-morning-tasks.csv`, and `summary.json`: generated tables and headline values.
- `request-phases.csv`, `readiness-phases.csv`, and `log-evidence.txt`: original Nov 12 log evidence. These files are separate from the plotting inputs.

## Refresh from Airflow

The default connection is the SSH user `infra` on `infra.t1`. The remote user needs permission to read the existing `airflow` container through Docker. The exporter uses that container&#39;s configured metadata connection; it never prints the connection URL or its credentials.

Copy the bundle to a separate directory before refreshing if you want to retain the original results. After a completed trading session, use SSH key authentication:

```bash
export AIRFLOW_SSH_USER=infra
export AIRFLOW_SSH_HOST=infra.t1
PYTHON=.venv/bin/python bash run.sh --refresh
```

If password authentication is required, set `AIRFLOW_SSH_PASSWORD` through your environment or secret manager. In an interactive Bash shell, enter it without showing or storing it in shell history:

```bash
read -r -s -p &#39;SSH password: &#39; AIRFLOW_SSH_PASSWORD
printf &#39;\n&#39;
export AIRFLOW_SSH_PASSWORD
PYTHON=.venv/bin/python bash run.sh --refresh
unset AIRFLOW_SSH_PASSWORD
```

This mode needs `sshpass`. It passes the password through the environment rather than a command-line argument. The runner disables shell tracing before handling credentials. No password values or database credentials belong in these files.

Refresh selects the latest 20 completed scheduled runs for `trading.hyena17`, reads task instances, failure records, and audit events, and writes `attempts.csv`, `metadata.json`, and `runs.csv` locally. The MySQL session is read-only. It does not clear tasks, trigger DAGs, restart services, or change the remote database.

The plotting script then regenerates the figures and summary tables. Fresh results can differ from the Nov 12 report. The article text and the three original log-evidence files are not refreshed automatically. An incomplete or changed task layout can fail the account/colo coverage checks instead of silently producing a partial chart.

## Interpretation limits

Only successful first morning attempts enter duration percentiles. Failed and unresolved attempts remain in the snapshot. Missing data is not treated as a zero-duration success. Queue measurements require a surviving matching task-instance record. Long-lived trading sessions are measured by their start times rather than treated as slow setup tasks.
````


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-12-airflow-trading-hyena17-task-timing/  

