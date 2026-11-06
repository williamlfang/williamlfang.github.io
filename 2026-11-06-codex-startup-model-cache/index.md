# Codex startup: a shared model cache and a five-second timeout


My Codex CLI sometimes paused for about five seconds when it started. Other
launches were almost immediate. After checking the
[proxy setup]({{&lt; relref &#34;2026-11-06-idc-v2raya-proxy-codex&#34; &gt;}}), I looked at
the startup logs. They showed **a model-list request consuming five seconds**
before timing out.

Three Codex versions were sharing the same model cache. A cache written by one
version could be rejected by another, which forced another network request.
I aligned the CLI with the shared server and changed the desktop launcher to
use the same CLI on its next launch. Five subsequent terminal checks reached
the model and prompt in a median of 0.80 seconds.

&lt;!--more--&gt;

## The versions behind one command

Running `codex --version` only checked the terminal executable. It did not
describe every Codex process on the machine:

| Component | Version before the fix |
|---|---|
| Standalone CLI in `~/.local/bin/codex` | 0.166.0 |
| Shared app-server daemon | 0.167.0 |
| Codex bundled with the desktop app | 0.159.0 |

The standalone CLI used the shared daemon by default. The desktop app also had
a separate server running from its bundled executable. These processes used
the same `~/.codex` directory, including `models_cache.json`.

The relevant checks were:

```bash
command -v codex
readlink -f ~/.local/bin/codex
codex --version
codex app-server daemon version
/usr/lib/chatgpt/resources/codex --version
```

The last path belongs to my Linux desktop installation. Other installation
layouts can put the bundled executable elsewhere. The daemon&#39;s `version`
command reported both `cliVersion` and `appServerVersion`, which exposed the
0.166.0 versus 0.167.0 mismatch.

## The startup trace accounted for the pause

In this installation, diagnostic logs were stored in
`~/.codex/logs_2.sqlite`. I opened the database read-only and selected the
startup and model-cache messages. This Python snippet prints recent matching
records without dumping conversation contents:

```python
from pathlib import Path
import sqlite3

database = Path.home() / &#34;.codex/logs_2.sqlite&#34;
with sqlite3.connect(database.as_uri() &#43; &#34;?mode=ro&#34;, uri=True) as connection:
	rows = connection.execute(&#34;&#34;&#34;
		SELECT feedback_log_body
		FROM logs
		WHERE target = &#39;codex_tui::app::startup&#39;
		   OR (
		       target LIKE &#39;codex_models_manager%&#39;
		       AND (
		           feedback_log_body LIKE &#39;%cache version mismatch%&#39;
		           OR feedback_log_body LIKE &#39;%request timed out%&#39;
		       )
		   )
		ORDER BY id DESC
		LIMIT 30
	&#34;&#34;&#34;)
	for (message,) in rows:
		print(message)
```

The database name and schema are details of these installed versions, not a
stable logging API. Check the files in `~/.codex` before using the query on
another installation.

One slow launch recorded:

```text
tui startup initial frame scheduled duration_ms=5098 bootstrap_ms=5006 thread_and_widget_ms=18 initial_session_ms=0 event_stream_ms=6
```

The whole recorded startup stage took 5,098 ms. Bootstrap accounted for
5,006 ms. The model-list trace explained that interval:

| Time, UTC | Event |
|---|---|
| 10:04:45.694 | Cache rejected: expected 0.167.0, cached 0.159.0 |
| 10:04:50.695 | Model-list refresh timed out |
| 10:04:50.736 | Initial frame scheduled |

A second model-list request started immediately afterward and timed out at
10:04:55.728. There was both a delay before the initial frame and another
failed refresh during session startup.

## A fresh cache could still be unusable

`models_cache.json` contained a `client_version` field as well as a fetch
timestamp and the model list. The logs showed all of these combinations:

```text
expected_version=&#34;0.167.0&#34; cached_version=Some(&#34;0.166.0&#34;)
expected_version=&#34;0.167.0&#34; cached_version=Some(&#34;0.159.0&#34;)
expected_version=&#34;0.159.0&#34; cached_version=Some(&#34;0.167.0&#34;)
expected_version=&#34;0.166.0&#34; cached_version=Some(&#34;0.167.0&#34;)
```

The cache did not have to be old. In the slow launch above, the desktop version
had fetched it less than a minute earlier. The newer server rejected it
because the version differed.

For these versions, the sequence was:

1. One process refreshed the shared cache and recorded its own version.
2. Another version loaded the file and rejected the entry.
3. That process requested the model list over the network.
4. A slow request reached the five-second timeout and delayed startup.

That also explained the inconsistent experience. Some earlier startup traces
were around 0.1 seconds, while several others were around 5.1 seconds. Which
version had most recently written the cache mattered.

## The proxy worked, but the model endpoint was slow

The shared daemon already had the HTTP proxy configured in its environment.
Codex&#39;s network diagnostic passed:

```bash
codex doctor --network-only --summary --ascii --no-color
```

```text
4 ok | 0 warn | 0 fail ok
```

Those checks established connectivity. They did not establish that every
authenticated model-list request completed within five seconds.

An authenticated request to
`https://chatgpt.com/backend-api/codex/models?client_version=0.167.0` returned
HTTP 200 and 11 model records. Through the existing HTTP proxy, one request
took 4.342 seconds. A separate request through the IDC SOCKS route took
4.008 seconds.

These were single diagnostic requests, using different clients. They were
not enough to rank the routes or explain the network delay. Both responses
were close to the timeout seen in the Codex logs, so I kept the existing proxy
route and fixed the repeated cache misses first.

## Align the CLI and the desktop launcher

The first change was to bring the standalone CLI to 0.167.0, matching the
running daemon. For a normal installation, the built-in update command is:

```bash
codex update
```

The download was slow in this session. A complete 0.167.0 package was already
installed under `~/.codex/packages/app-server-daemon`, so the local repair
reused that package in the standalone release directory and switched
`~/.codex/packages/standalone/current` to it. The package included its helper
executables and resources. The running daemon stayed in place.

Afterward, `codex --version` returned:

```text
codex-cli 0.167.0
```

`codex app-server daemon version` also reported 0.167.0 for both the CLI and
the app server.

The desktop launcher needed a separate change. My desktop entry already used
`~/.local/bin/chatgpt-proxy`. I added this line before its existing `exec`
command:

```bash
export CODEX_CLI_PATH=&#34;$HOME/.local/bin/codex&#34;
```

The installed desktop application&#39;s code recognized `CODEX_CLI_PATH` as an
executable override. This lets the next desktop launch use the updated CLI
instead of its bundled 0.159.0 binary. This behavior was checked in the local
application; it should be verified again after a desktop upgrade.

Changing the wrapper does not change an already-running desktop process.
I left that process and the active sessions running. Until the desktop app
restarts, its old server can still write a 0.159.0 cache entry.

Finally, an explicit catalog refresh populated a 0.167.0 cache:

```bash
codex debug models &gt; /tmp/codex-models.json
```

The refresh completed successfully in 4.878 seconds and returned 11 model
records. I checked the cache metadata without printing credentials:

```python
from pathlib import Path
import json

cache = json.loads((Path.home() / &#34;.codex/models_cache.json&#34;).read_text())
print(cache[&#34;client_version&#34;])
print(len(cache[&#34;models&#34;]))
```

```text
0.167.0
11
```

## What the later checks measured

After the repair, one startup trace recorded:

```text
tui startup initial frame scheduled duration_ms=73 bootstrap_ms=4 thread_and_widget_ms=1 initial_session_ms=0 event_stream_ms=0
```

That trace showed the five-second bootstrap wait was gone for that launch.
Five separate checks of server initialization plus `model/list` completed in
2 to 4 ms. The requested default model was present in every response.

I also launched the actual CLI five times in a pseudo-terminal, using the
normal shared daemon and the same working directory. The check waited until
both the model name and the input prompt appeared. It did not submit a task
or wait for a model response.

| Launch | Time to visible model and prompt |
|---|---:|
| 1 | 3.705 s |
| 2 | 0.813 s |
| 3 | 0.796 s |
| 4 | 0.804 s |
| 5 | 0.791 s |
| Median | **0.804 s** |

These numbers measure different stages. The 73 ms value comes from Codex&#39;s
internal initial-frame trace. The 0.804 s median includes the work needed to
display the model and prompt in the terminal. Neither is the latency of the
first answer.

The earlier 5.1-second traces and the later terminal checks were not an
alternating before-and-after benchmark, so I would not turn them into a
speedup ratio. They establish a narrower result: the logs identified a
five-second model-list timeout, and later launches used a matching cache and
reached the prompt successfully.

The endpoint&#39;s variable response time remains unexplained. Keeping the local
versions aligned avoids the cache misses caused by version mismatches; it
does not make an uncached network request faster.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-06-codex-startup-model-cache/  

