# tmux lag, round 2: every status-bar fork froze the server for 30 ms


Two days after the
[last fix]({{&lt; relref &#34;2026-09-30-tmux-status-bar-lag&#34; &gt;}}), my tmux was laggy
again, and the server was back at about a quarter of a CPU core. The culprit was
the same as last time: the status bar&#39;s `#()` jobs. This time, though, the
number of jobs wasn&#39;t the problem. Each one had become slow, because every job
is a fork of the whole tmux server and my server had grown to 1.5 GB.

This post covers how I measured it, where the 1.5 GB came from (mostly the
scrollback of three panes), and the fixes. One of them corrects a claim in my
previous post.

&lt;!--more--&gt;

## Measure what lag feels like

CPU percentage doesn&#39;t tell you how typing feels. Latency does. A trivial tmux
command makes a good probe, because it goes through the same event loop as your
keystrokes:

```python
import subprocess, time, random
lat = []
for _ in range(300):
    t = time.perf_counter()
    subprocess.run([&#34;tmux&#34;, &#34;display&#34;, &#34;-p&#34;, &#34;x&#34;], stdout=subprocess.DEVNULL)
    lat.append((time.perf_counter() - t) * 1000)
    time.sleep(random.uniform(0.01, 0.06))
lat.sort()
print(&#34;p50 %.1f  p99 %.1f  max %.1f ms, &gt;40 ms: %d&#34; %
      (lat[150], lat[297], lat[-1], sum(x &gt; 40 for x in lat)))
```

```text
p50 5.0  p99 119.5  max 123.2 ms, &gt;40 ms: 23
```

Most commands came back in 5 ms, but about one in thirteen took 40–120 ms.
Hits like that, several times a second, are what lag feels like.

## The profiler pointed at the frame after the problem

I ran the same `eu-stack` sampling loop as last time, and got the same picture:
the busy samples sat in `job_run`, mostly in `environ_free`:

```text
14  _int_free;environ_free;job_run;format_expand1;...;status_redraw
 5  environ_RB_REMOVE;environ_free;job_run;...
```

But the environment tmux builds for a job was only 104 variables (15 KB).
Freeing that can&#39;t take milliseconds. So I timed the syscalls instead:

```bash
timeout 6 strace -p &lt;server-pid&gt; -T -ttt -qq -o st.txt
grep clone st.txt     # one line per fork, duration in &lt;...&gt;
```

There were 40 forks in 6 seconds, and **each `clone()` took 28–37 ms in the
kernel**. tmux is single-threaded, so the server handles no input while it
forks.

A fork has to copy the page tables of the whole process, swap entries included,
and this server was 918 MB in RAM plus 614 MB in swap. After the fork, every page
is shared copy-on-write, so the first writes the parent makes take page faults.
In tmux, the first thing that writes is `environ_free`, and that&#39;s why the
sampling profile blamed it. **A sampling profiler shows you where the time
surfaced; `strace -T` shows you which syscall it went into.**

The forks also came in pairs. Every client ran `status-left.sh` and
`status-right.sh` back to back each second, so one client&#39;s refresh froze the
server for 60 ms or more. That accounts for the long tail in the latency numbers.

## Where 1.5 GB came from

tmux reports scrollback memory per pane:

```bash
tmux list-panes -a -F &#39;#{history_bytes} #{history_size} #{session_name}:#{window_index}.#{pane_index} #{pane_current_command}&#39; \
  | sort -rn | head -4
```

```text
531541574 61441 ch:3.1 python3
196847422 38544 ch:1.1 python3
139474919 34260 ch:2.1 python3
 18343891 59805 ...    tail
```

The panes held 881 MB of scrollback, and **827 MB of it was in three panes**
running interactive `clickhouse-cli`. Their result tables are drawn with 24-bit
color and box-drawing characters, and tmux has to store cells like that in its
large &#34;extended&#34; format. That came to **~52 bytes per cell, 8.6 KB per line**.
One pane held 61,441 lines and 507 MB. The plain text of all three histories
saved to 18.6 MB.

My `history-limit 65535` is what let them get that big. The other 163 panes held
54 MB between them.

## Fix 1: one job for the whole status line

One job per client is the minimum, since something has to render the clock each
second. Two was one too many. The new `status-line.sh` draws both halves of the
status line. `status-left` runs it and `status-right` is empty:

```bash
set -g status-left-length 300
set -g status-left &#34;#{?#{E:#{@quote_cond}},#($HOME/.tmux/scripts/status-line.sh 1 #{q:session_name}),#($HOME/.tmux/scripts/status-line.sh 0 #{q:session_name})}&#34;
set -g status-right &#34;&#34;
```

The script prints the left block, then a style tag that moves everything after
it to the right edge (Nerd Font icons left out here):

```bash
#!/bin/sh
# $1: 1 to show the quote, else 0    $2: session name
dir=&#34;$HOME/.cache/tmux-status&#34;

# left side
if [ -f &#34;$HOME/.tmux/plugins/tmux-pom/data/pom_start_time.txt&#34; ]; then
    printf &#39;#[fg=black,bg=yellow,bold]&#39;
else
    printf &#39;#[fg=black,bg=blue,bold]&#39;
fi
printf &#39; XPS:%s #[nobold,italics,nounderscore]&#39; &#34;$2&#34;
cat &#34;$dir/left_pom&#34; 2&gt;/dev/null

# right side
printf &#39;#[default align=right range=right]&#39;
cat &#34;$dir/right&#34; 2&gt;/dev/null
if [ &#34;$1&#34; = 1 ]; then
    printf &#39;#[fg=color244,bg=brightblack,noitalics]&#39;
    cat &#34;$dir/quote&#34; 2&gt;/dev/null
    printf &#39; &#39;
fi
printf &#39;%s&#39; &#34;$(date &#39;&#43;#[fg=blue,bg=brightblack] %b%d %H:%M:%S&#39;)&#34;
```

tmux honors `#[...]` style tags in job output, and that includes `align=`. Three
details took a test each to get right:

- **It has to be `status-left`.** My first version put the job in `status-right`
  and sent the left block over with `#[align=left]`. The block was drawn *after*
  the window list. My window list is left-justified, and text that comes after a
  left-justified list stays attached to it.
- **The output must be a single line.** tmux shows only one line of a job&#39;s
  output, and `date`&#39;s trailing newline split the first draft in two, so one half
  disappeared. That&#39;s why the clock is wrapped in `printf &#39;%s&#39; &#34;$(...)&#34;`.
- **`status-left-length` has to cover the whole line.** Mine was 30, which would
  have cut off the right half.

To check that nothing changed visually, I started two throwaway servers on their
own sockets, one with the old config and one with the new, and attached a
client to each from inside a third server. `capture-pane -e` on that outer pane
returns the inner client&#39;s screen, status line and colors included. Once the
clock and the CPU numbers were masked, the two lines were byte-identical. (Pin
the window name for this, or `automatic-rename` will race you: a pane started
as `zsh -c cat` shows up as zsh for a moment.) Server forks went from 20 to 10
per 10 seconds per client.

## Fix 2: strftime doesn&#39;t run inside `#()`, which my last post got wrong

In the previous post I passed the quote condition into the job as
`#{E:#{@quote_cond}}`. That condition contains a time window, `%H%M` compared
against `1715` and `0630`. It turns out tmux does **not** apply strftime to
anything expanded inside a `#()` command:

```bash
tmux set -g @t &#39;#{&gt;=:%H%M,0000}&#39;
tmux set -g status-right &#39;#(echo JOB=#{E:#{@t}}) NATIVE=#{E:#{@t}}&#39;
```

```text
JOB=0 NATIVE=1
```

Inside the job, `%H%M` stayed a literal string, so `#{&lt;:%H%M,0630}` was always
true, and so was the condition. Nobody noticed because the quote was switched
off. Now tmux evaluates the condition outside the job and picks which of two
commands to run: `#{?cond,#(job 1),#(job 0)}`. Only the chosen branch runs, so
it is still one job.

One caveat remains on this particular server. A long-running tmux server keeps
the timezone it started with (see
[this post]({{&lt; relref &#34;2026-09-26-linux-timezone-clock-and-tmux&#34; &gt;}})), and mine
is still an hour behind. Until it restarts, the window flips an hour late. The
clock itself is fine, because it comes from `date`.

## Fix 3: Ctrl-L was forking the server

My config still had this line from my
[2022 post]({{&lt; relref &#34;2022-09-13-tmux-vim-导致无法使用-ctrl-l-清屏&#34; &gt;}}),
which took Ctrl-L back from vim-tmux-navigator:

```bash
bind-key -n C-l if-shell &#34;$is_vim&#34; &#34;send-keys C-l&#34;  &#34;send-keys C-l&#34;
```

I had stopped using vim-tmux-navigator long ago, and `$is_vim` was commented
out. So every Ctrl-L ran an empty shell command, which meant a full fork of the
1.5 GB server, only to choose between two identical branches. I removed it:

```bash
unbind -q -n C-l    # -q: on a fresh server the key isn&#39;t bound
```

If you do use vim-tmux-navigator, `bind-key -n C-l send-keys C-l` after the tpm
line has the same effect without a fork.

## Fix 4: save the scrollback, then clear it

I didn&#39;t want to lose those query results, so I saved them first. `-J` joins
lines that tmux wrapped, which makes the wide tables readable again:

```bash
tmux capture-pane -p -J -S - -E - -t &lt;pane&gt; &gt; ch_3.1.txt
tmux clear-history -t &lt;pane&gt;
```

Reading 507 MB of history that was partly in swap froze tmux for 4.3 seconds,
once. After the three panes, scrollback across all panes went from 881 MB to
53 MB, and clickhouse-cli kept running.

Clearing alone doesn&#39;t shrink the process: freed memory stays inside malloc. As
it turns out, tmux 3.5a calls `malloc_trim(0)` once an hour, from
`server_tidy_event`:

```bash
objdump -d /usr/local/bin/tmux | awk &#39;/^[0-9a-f]&#43; &lt;.*&gt;:$/{fn=$2} /call.*&lt;malloc_trim@plt&gt;/{print fn}&#39;
# &lt;server_tidy_event&gt;:
```

So within an hour, the memory goes back to the OS on its own.

## Results

|                                  | before        | after fixes 1–3 | after fix 4 &#43; trim |
|----------------------------------|---------------|-----------------|--------------------|
| server forks per second          | 6.7           | 3.2             | AFTER_FORKS        |
| fork, median                     | 28 ms         | 21 ms           | AFTER_FORK_P50     |
| command round trip, p99 / max    | 120 / 123 ms  | 63 / 69 ms      | AFTER_LAT          |
| round trips over 40 ms (of 300)  | 23            | 10              | AFTER_GT40         |
| tmux server CPU                  | ~25%          | ~18%            | AFTER_CPU          |
| server memory (RAM &#43; swap)       | 918 &#43; 614 MB  | same            | AFTER_MEM          |

## What&#39;s still left

- **`history-limit` is still 65535**, so those panes will grow back. A pane keeps
  the limit it was created with, so lowering it only takes effect in new panes.
- **Every attached client costs one fork per second.** Two of mine were terminal
  windows I hadn&#39;t typed into for two days.
- **The server has leaked panes.** It holds 279 pseudo-terminals for 166 panes.
  The other 112 belong to processes that no session lists anymore, because tmux
  never freed their windows. Some of them are probe panes from my own
  measurements two weeks earlier, which ended up in the live server instead of a
  throwaway one.
- **A leftover plugin loop still calls `set-option` every 5 minutes.** That
  repaints every pane on every client (see the
  [last post]({{&lt; relref &#34;2026-09-30-tmux-status-bar-lag&#34; &gt;}})).
- **Restarting the server fixes all of the above.** A fresh server is tens of MB,
  so a fork takes well under a millisecond. It also loses every process running
  in a pane.

## Takeaways

1. **Measure latency, not just CPU.** A loop of trivial tmux commands shows the
   stalls you feel when typing.
2. **Time the syscall.** A sampling profiler showed the fork&#39;s cost in the code
   that ran after it. `strace -T` on `clone` showed the cost itself.
3. **Every `#()` forks the server, and a fork costs more as the server grows.**
   Scrollback is most of that size, and colorful output costs several times more
   per cell than plain text.
4. **strftime isn&#39;t applied inside `#()` commands.** Evaluate anything with
   `%H`/`%M` in it outside the job.
5. **Save before you clear.** `capture-pane -p -J -S - -E -` keeps the text, and
   tmux&#39;s hourly `malloc_trim` returns the memory.

## References

- [tmux manual: `FORMATS`, `STYLES` (`align=`, `range=`), `capture-pane`, `clear-history`](https://github.com/tmux/tmux/blob/master/tmux.1)
- [tmux source: `format_job_get()`, where job commands are expanded without strftime](https://github.com/tmux/tmux/blob/master/format.c)
- [tmux source: `server_tidy_event()` and `malloc_trim`](https://github.com/tmux/tmux/blob/master/server.c)
- [Previous post: the status bar was forking a 1.2 GB server 24 times a second]({{&lt; relref &#34;2026-09-30-tmux-status-bar-lag&#34; &gt;}})


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-02-tmux-lag-round-2/  

