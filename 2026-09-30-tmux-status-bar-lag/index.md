# Why my tmux was laggy: the status bar was forking a 1.2 GB server 24 times a second


&gt; **Update 2026-10-02:** two days later the lag was back. Each fork of the server
&gt; had become slow (~30 ms), and one claim below was wrong: passing
&gt; `#{E:#{@quote_cond}}` into the job does not work, because tmux does not apply
&gt; strftime inside a `#()` command. See
&gt; [round 2]({{&lt; relref &#34;2026-10-02-tmux-lag-round-2&#34; &gt;}}).

My tmux had started to feel sluggish. Nothing was broken, it just felt heavy.
It turned out the tmux server was using about a third of a CPU core all the time,
and nearly all of that went on the status bar. Part of the cost came from the
clock workaround in my
[previous post]({{&lt; relref &#34;2026-09-26-linux-timezone-clock-and-tmux&#34; &gt;}}).

This post covers how I tracked it down, including two wrong guesses, and the fix,
which brought the server from **~35% CPU to ~4%** without restarting it.

&lt;!--more--&gt;

## The setup

This is a tmux server that had been running for 23 days:

- tmux 3.5a
- 26 sessions, 167 panes, many of them long-lived ssh sessions
- `status-interval 1`, so the clock ticks every second
- A status bar full of widgets: CPU, memory, pomodoro timer, API usage limits,
  a market quote and a clock

The status bar had already been optimized once. An earlier version ran 13 `#()`
shell jobs every second, about 260 process spawns a second. A background daemon
(`status-daemon.sh`) replaced that. It computes the widget values out of band
and writes them to small files under `~/.cache/tmux-status/`, which the status
bar reads back with `#(cat ...)`.

So I didn&#39;t expect the status bar to be the problem.

## Step 1: is tmux actually busy?

`ps` reports a process&#39;s *lifetime average* CPU, which can be misleading, so
sample the live value with `top`:

```bash
top -b -d1 -n5 -p &#34;$(pgrep -o -x tmux)&#34; | awk &#39;/tmux/{print $9&#34;% cpu, RES &#34;$6}&#39;
```

```text
13.3% cpu, RES 1.2g
50.0% cpu, RES 1.2g
29.0% cpu, RES 1.2g
51.5% cpu, RES 1.2g
26.0% cpu, RES 1.2g
```

It was busy all the time, and resident memory was **1.2 GB**. That memory figure
turned out to matter later.

## Step 2: suspects that didn&#39;t pan out

### Suspect 1: pane output

In tmux, every byte a pane prints is parsed by the server, even in windows you
aren&#39;t looking at. I compared `capture-pane` snapshots taken 3 seconds apart:
**66 of 167 panes** were changing. That looked like the answer.

Then I measured the actual bytes. My first strace traced only `read`, but
libevent reads ptys with `readv`, so trace both:

```bash
timeout 5 strace -p &lt;server-pid&gt; -e trace=read,readv,write,writev,sendmsg -qq -o io.txt
```

Total pane input came to about **40 KB/s**, spread at roughly 1 KB/s per pane.
That&#39;s nothing. Output volume wasn&#39;t the problem.

### Suspect 2: an 8 KB `automatic-rename-format`

strace also showed tmux opening `/proc/&lt;pid&gt;/cmdline` **about 220 times a
second**. That&#39;s tmux resolving `#{pane_current_command}`. My
`window-icons.conf` sets an `automatic-rename-format` that maps command names to
Nerd Font icons. It&#39;s a single 8 KB nested ternary that references
`#{pane_current_command}` about 200 times, and it gets re-evaluated whenever a
window produces output.

It looked guilty, so I tested it directly:

| automatic-rename setting          | server CPU |
|-----------------------------------|------------|
| fancy 8 KB format (baseline)      | 34%        |
| plain `#{pane_current_command}`   | 37%        |
| automatic-rename off              | 32%        |

No difference. Counting syscalls tells you what a process does, not what it
spends its CPU on. For that you need a profiler.

## Step 3: profile it

`perf` wasn&#39;t installed, but `eu-stack` (from elfutils) was, and the tmux binary
wasn&#39;t stripped. A basic sampling profiler is just a loop:

```bash
pid=&lt;server-pid&gt;
for i in $(seq 1 120); do
  eu-stack -p &#34;$pid&#34; -1 2&gt;/dev/null | awk &#39;/^#/{print $NF}&#39; | paste -sd&#39;;&#39; &gt;&gt; stacks.txt
  sleep 0.1
done
grep -v &#39;^__poll&#39; stacks.txt | cut -d&#39;;&#39; -f1-8 | sort | uniq -c | sort -rn
```

Samples whose top frame is `__poll` are tmux sitting idle in its event loop. Of
120 samples, 44 were busy, which fits the ~35% CPU. Nearly all of those 44 had
the same shape:

```text
22  _int_free;environ_free;job_run;format_expand1;format_replace;format_expand1;format_expand_time;status_redraw
 8  environ_RB_REMOVE;environ_free;job_run;format_expand1;...;status_redraw
 3  __libc_fork;job_run;format_expand1;...;status_redraw
```

**About 95% of the server&#39;s busy time was in `job_run`**, the function that runs
a status-bar `#()` command.

Don&#39;t run `strace` and `eu-stack` at the same time. Both use ptrace, only one
can attach to a process, and the other gets nothing back.

## Why `#()` is expensive here

Each `#(...)` in a status format makes the tmux server:

1. **fork itself**, then
2. build an environment for the child and free it again in the parent.

Neither step is normally a big deal, but this process had a **1.2 GB heap after
23 days of uptime**. Forking it means copying page tables for all of that memory.
After the fork, the parent&#39;s pages are shared copy-on-write with the child, so
the parent&#39;s next writes, such as the `free()` calls in `environ_free`, can
trigger page faults. That fits the profile: the time shows up in `_int_free` and
`environ_RB_REMOVE`, which are not normally expensive functions.

The cost of a job comes almost entirely from forking the server, not from the
command being run. `#(cat file)` costs about the same as a heavy script.

This is what the live status bar was running each second, for each attached
client:

```text
status-left:   #(if test -f .../pom_start_time.txt; then ...; fi)   &lt;- pomodoro colour
               #(cat ~/.cache/tmux-status/left_pom)
status-right:  #(cat ~/.cache/tmux-status/right)
               #(cat ~/.cache/tmux-status/quote)                    &lt;- when enabled
               #(TZ=Asia/Tokyo date &#43;%b%d)                          &lt;- timezone workaround
               #(TZ=Asia/Tokyo date &#43;%H:%M:%S)                      &lt;- timezone workaround
```

With two clients attached, plus the daemon forcing refreshes with
`refresh-client -S`, strace counted **about 24 forks a second**.

To confirm, I replaced both status formats with job-free versions for a few
seconds:

| status line        | server CPU |
|--------------------|------------|
| with `#()` jobs    | ~35%       |
| no `#()` jobs      | **~3%**    |

(My first attempt at this test also showed ~38% with no jobs. I never worked out
why, but a clean rerun and the profiler agreed with each other, so I trusted
those.)

## The timezone workaround was part of the cost

In the [previous post]({{&lt; relref &#34;2026-09-26-linux-timezone-clock-and-tmux&#34; &gt;}}),
the system timezone changed to `Asia/Tokyo` after the tmux server had started,
and the server kept formatting `%H:%M:%S` in the old timezone:

```bash
$ tmux display -p &#39;%H:%M:%S&#39;; date &#43;%H:%M:%S
10:33:20
11:33:20
```

The workaround swapped the clock for `#(TZ=Asia/Tokyo date ...)`. It fixed the
time but added **two more forks of the server per second per client**. It was
also only a runtime setting: `.tmux.conf` still used the built-in `%H:%M:%S`, so
a `prefix r` reload would have brought the wrong time back.

## The fix: one job per side

Every `#()` costs one fork of the big server, no matter what it runs. But the
shell *inside* the job can fork as often as it likes, because it&#39;s a small
process. So merge each side of the status bar into **a single job** that runs a
script.

`~/.tmux/scripts/status-left.sh`:

```bash
#!/bin/sh
# $1: session name
if [ -f &#34;$HOME/.tmux/plugins/tmux-pom/data/pom_start_time.txt&#34; ]; then
    printf &#39;#[fg=black,bg=yellow,bold]&#39;
else
    printf &#39;#[fg=black,bg=blue,bold]&#39;
fi
printf &#39; XPS:%s #[nobold,italics,nounderscore]&#39; &#34;$1&#34;
cat &#34;$HOME/.cache/tmux-status/left_pom&#34; 2&gt;/dev/null
```

`~/.tmux/scripts/status-right.sh` (Nerd Font icons left out here):

```bash
#!/bin/sh
# $1: 1 to show the quote (the @quote_cond format), else 0
dir=&#34;$HOME/.cache/tmux-status&#34;

cat &#34;$dir/right&#34; 2&gt;/dev/null
if [ &#34;$1&#34; = 1 ]; then
    printf &#39;#[fg=color244,bg=brightblack,noitalics]&#39;
    cat &#34;$dir/quote&#34; 2&gt;/dev/null
    printf &#39; &#39;
fi
date &#39;&#43;#[fg=blue,bg=brightblack,noitalics,nounderscore] %b%d #[fg=blue,bg=brightblack]%H:%M:%S#[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]&#39;
```

And in `.tmux.conf`:

```bash
set -g status-left  &#34;#($HOME/.tmux/scripts/status-left.sh #{q:session_name})&#34;
set -g status-right &#34;#($HOME/.tmux/scripts/status-right.sh #{E:#{@quote_cond}})&#34;
```

A few details that matter:

- **tmux expands formats inside the job command before running it.**
  `#{q:session_name}` passes the session name, shell-quoted, and
  `#{E:#{@quote_cond}}` passes the quote condition as `1` or `0`. Anything that
  depends on the client or session goes in as an argument.
- **Job output is not re-expanded as a format.** Writing `#S` in the output
  wouldn&#39;t work, which is why the session name comes in as an argument.
  `#[...]` style tags in the output *are* honored, so the colors still work.
- **No `%%` escaping needed any more.** tmux runs strftime over status formats
  before running the jobs, which is why the old inline version had to write
  `date &#43;%%H:%%M:%%S`. Inside the script, `date` gets plain `%H:%M:%S`.
- **The clock comes from `date`, not tmux&#39;s `%H:%M:%S`.** `date` reads the system
  timezone each time it runs, so the time is right on this old server and on any
  fresh one. The timezone workaround is no longer needed.
- **Check for invisible characters.** My first edit to the config failed because
  the old `status-right` line held two Nerd Font glyphs that didn&#39;t show in the
  terminal. This shows them:

  ```bash
  grep &#39;^set -g status-right&#39; ~/.tmux.conf \
    | perl -CSD -pe &#39;s/([^\x00-\x7F])/sprintf(&#34;&lt;U&#43;%04X&gt;&#34;,ord($1))/ge&#39;
  ```

  Without that check, the calendar and clock icons would have silently
  disappeared from the bar.

Before switching, I compared the script output byte for byte with the old status
line. Then I applied just those two options to the running server with
`tmux set -g`, with no restart and no full config reload.

## Results

|                                     | before                         | after                              |
|-------------------------------------|--------------------------------|------------------------------------|
| `#()` jobs per client per refresh   | 5–6                            | 2                                  |
| server forks per second             | ~24                            | ~4                                 |
| tmux server CPU                     | ~35%                           | **~4%**                            |
| clock                               | correct only via a runtime override | correct, and survives a reload |

## Takeaways

1. **Measure CPU, don&#39;t infer it from syscalls.** Both of my early suspects
   looked convincing in strace and made no measurable difference. A 30-second
   sampling loop with `eu-stack` found the real cause straight away.
2. **In tmux, every `#()` is a fork of the server.** On a server that&#39;s been up
   for weeks with lots of scrollback, that&#39;s expensive. Count your `#()`s and
   merge them. One job running a script is much cheaper than five jobs each
   running `cat`.
3. **A long-running tmux server keeps the timezone it started with.** Get the
   time from `date` inside a job you already run, rather than adding new jobs.
4. **Restarting fixes both.** A fresh server would shrink back to a small heap,
   which makes forks cheap, and pick up the current timezone. `tmux kill-server`
   also ends every session, though. With 167 panes of live ssh sessions I didn&#39;t
   want to do that, and the fix above works without it.

## References

- [tmux manual: `FORMATS`, `#()` jobs and the `q`/`E` modifiers](https://github.com/tmux/tmux/blob/master/tmux.1)
- [tmux source: `format_job_get()` and `job_run()`](https://github.com/tmux/tmux/blob/master/format.c)
- [`eu-stack` (elfutils)](https://sourceware.org/elfutils/)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-30-tmux-status-bar-lag/  

