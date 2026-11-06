# Profiling zsh: a Python plugin was adding 190 ms to every command


After [fixing tmux]({{&lt; relref &#34;2026-10-02-tmux-lag-round-2&#34; &gt;}}), I looked at
the shell running inside it. My zsh config had grown over a few years to about
30 plugins and Oh My Zsh snippets on top of zinit and Powerlevel10k. It felt a
little heavy, but nothing stood out.

Measured properly, it was slow in three separate ways, each with its own cause:

| | before | after |
|---|---:|---:|
| startup to a usable shell | 267 ms | 101 ms |
| added to **every command** | 188 ms | 3 ms |
| added to **every prompt** | 15 ms | 4 ms |

This post covers how I measured each one, the fixes, and how I checked that the
fixes didn&#39;t change anything else. That check caught two mistakes of my own.

&lt;!--more--&gt;

## The setup

- zsh 5.8 on Linux Mint 20.3
- [zinit](https://github.com/zdharma-continuum/zinit), with many plugins in
  turbo mode (`wait`), which loads them just *after* the first prompt
- Powerlevel10k with instant prompt
- zsh-vi-mode, fzf-tab, zsh-autosuggestions, fast-syntax-highlighting, and
  three directory jumpers (zoxide, autojump, zsh-z)

## Startup: the easy number is misleading

The usual first measurement:

```bash
for i in $(seq 1 12); do
  s=$(date &#43;%s%N); zsh -i -c exit; e=$(date &#43;%s%N); echo $(( (e-s)/1000000 ))
done | sort -n
```

That gave a median of **148 ms**, against 2 ms for `zsh -f`. Not great, but
not alarming either. It turned out to be the optimistic number, for two
reasons:

1. `zsh -i -c exit` exits before zinit&#39;s turbo plugins load, so it never sees
   them. They still cost time in a real shell: right after the prompt appears,
   anything you type waits until they&#39;ve finished.
2. Running it back to back leaves a cache in a state that real use never does.
   More on that under compinit below.

Powerlevel10k&#39;s instant prompt hides startup time too. It draws the prompt
before `.zshrc` has finished, but your keystrokes aren&#39;t handled until the
config is done.

## Profile every line with xtrace timestamps

zsh can timestamp every traced line. `%D{%s.%6.}` in `PS4` gives microseconds:

```bash
PS4=&#39;&#43;%D{%s.%6.} %N:%i&gt; &#39; zsh -i -x -c exit 2&gt; trace.txt
```

Each trace line shows the file (or function) and line number. To charge
everything to a top-level line of `.zshrc`, add up the time from each `.zshrc`
line to the next one, which includes everything that line sourced or called:

```python
import re
rx = re.compile(r&#39;^\&#43;(\d&#43;\.\d&#43;) (\S&#43;?):(\d&#43;)&gt; ?(.*)$&#39;)
cost, text, cur = {}, {}, None
for line in open(&#39;trace.txt&#39;, errors=&#39;replace&#39;):
    m = rx.match(line)
    if not m: continue
    t, f, ln, cmd = float(m[1]), m[2], int(m[3]), m[4]
    if f.endswith(&#39;/.zshrc&#39;):
        if cur: cost[cur[0]] = cost.get(cur[0], 0) &#43; t - cur[1]
        cur = (ln, t); text.setdefault(ln, cmd)
for ln, c in sorted(cost.items(), key=lambda x: -x[1])[:15]:
    print(f&#34;{c*1000:6.1f} ms  line {ln:&lt;4} {text[ln][:70]}&#34;)
```

Tracing roughly doubles the run time (275 ms traced), so read the ranking
rather than the absolute numbers. The top of the list was mostly duplication:

- **`ssh-agent` loaded twice**, as `OMZ::plugins/ssh-agent/...` and as
  `OMZP::ssh-agent`, which is the same file. Each load checked the agent and its
  keys again.
- **fzf set up twice.** The Oh My Zsh fzf plugin runs `eval &#34;$(fzf --zsh)&#34;`
  itself, and my config ran it again a few lines later.
- **`OMZ::lib/history.zsh` loaded twice**, once synchronously and once in turbo
  mode.
- **A tmux plugin loaded into zsh.** `zinit light tmux-plugins/vim-tmux-focus-events`
  loads nothing useful into zsh: it&#39;s a Vim/tmux plugin. The line after it,
  `set -g focus-events on`, is tmux syntax. In zsh, `set -g` turns on an option
  (`-g` is `HIST_IGNORE_SPACE`), and the remaining words become the shell&#39;s
  arguments. My interactive shell had been running with `$1=focus-events` and
  `$2=on` for who knows how long.

All of that was real but small: a few milliseconds per item. The large costs
were elsewhere.

## Measure the shell you actually use

To see turbo plugins and hooks, you need an interactive shell with a terminal.
Python&#39;s `pty` module provides one:

```python
import os, pty, select, time
pid, fd = pty.fork()
if pid == 0:
    os.execvp(&#34;zsh&#34;, [&#34;zsh&#34;, &#34;-i&#34;])
def pump(secs):
    out, end = b&#34;&#34;, time.time() &#43; secs
    while time.time() &lt; end:
        if select.select([fd], [], [], 0.05)[0]:
            out &#43;= os.read(fd, 65536)
    return out.decode(errors=&#34;replace&#34;)
pump(4)                              # give the turbo plugins time to load
os.write(fd, b&#34; zinit times\r&#34;)      # note the leading space, see &#34;Traps&#34;
print(pump(1.5))
os.write(fd, b&#34; exit\r&#34;)
```

`zinit times` lists how long each plugin took to load. Three turbo plugins
stood out:

```text
  318 ms - zdharma-continuum/fast-syntax-highlighting
   72 ms - zsh-users/zsh-autosuggestions
   50 ms - hlissner/zsh-autopair
Total: 0.545 sec
```

fast-syntax-highlighting isn&#39;t slow by itself. Its `atinit` runs `compinit`,
the completion system setup, and that&#39;s where the 318 ms went.

The same shell can also show which functions run before every command
(`preexec`) and before every prompt (`precmd`), and time them:

```zsh
zmodload zsh/datetime
t() { local s=$EPOCHREALTIME; &#34;$@&#34; &gt;/dev/null 2&gt;&amp;1
      printf &#39;%-30s %6.1f ms\n&#39; &#34;$1&#34; $(( (EPOCHREALTIME-s)*1000 )); }
print -l $preexec_functions $precmd_functions
t _alias_tips__preexec &#34;ls -la&#34; &#34;ls -la&#34; &#34;ls -la&#34;
t _check_aliases &#34;ls -la&#34; &#34;ls -la&#34; &#34;ls -la&#34;
t _zsh_autosuggest_bind_widgets
```

```text
_alias_tips__preexec           161.4 ms   (192.1, 324.8 on other runs)
_check_aliases                   1.5 ms
_zsh_autosuggest_bind_widgets   12.7 ms   (30.8, 13.0)
```

## Every command: alias-tips ran Python

[alias-tips](https://github.com/djui/alias-tips) reminds you when you type a
command that has an alias. Before *every* command, its `preexec` hook:

- runs `git config --get-regexp &#39;^alias\.&#39;` through four `sed`s,
- dumps the full source of every function in the shell through `grep`
  (my shell has 2,552 functions),
- pipes all of that into `python3 alias-tips.py`.

The first `python3` on my PATH is miniconda&#39;s, which is slow to start. Together
that&#39;s **160–325 ms of waiting after every Enter**, before the command even
starts. It&#39;s easy to blame the command itself for that delay.

I already had [zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use),
which gives the same reminders in pure zsh in 1.5–4 ms. So alias-tips went.

## Every prompt: settings that never took effect

zsh-autosuggestions has to wrap zle widgets to work. By default it re-wraps
*all* of them before every prompt, in case another plugin has replaced one. I
have 854 widgets, so that took 13–31 ms on every prompt. Setting
`ZSH_AUTOSUGGEST_MANUAL_REBIND` turns this off, and my config did set it:

```zsh
zinit wait lucid light-mode for \
    atload&#34;_zsh_autosuggest_start; \
        ZSH_AUTOSUGGEST_STRATEGY=(history completion) \
        ZSH_AUTOSUGGEST_MANUAL_REBIND=0 \
        ZSH_AUTOSUGGEST_HISTORY_IGNORE=&#39; *&#39; \
        bindkey &#39;^ &#39; autosuggest-accept;&#34; \
    zsh-users/zsh-autosuggestions
```

Look at the backslashes. Inside a double-quoted string, backslash-newline is a
line continuation, so the `atload` code is a single line:

```zsh
_zsh_autosuggest_start; ZSH_AUTOSUGGEST_STRATEGY=(history completion) ZSH_AUTOSUGGEST_MANUAL_REBIND=0 ZSH_AUTOSUGGEST_HISTORY_IGNORE=&#39; *&#39; bindkey &#39;^ &#39; autosuggest-accept;
```

Written like that, the three assignments are **prefix assignments to
`bindkey`**: they only exist while `bindkey` runs. Only the key binding ever
took effect. In the running shell, the strategy was still the default
`(history)` and `MANUAL_REBIND` was unset. Note too that the plugin only checks
whether `MANUAL_REBIND` is *set*: `0` would have enabled it as well.

The fix sets the variable as a real assignment, before the plugin reads it:

```zsh
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zinit wait lucid light-mode for \
    atload&#34;_zsh_autosuggest_start; bindkey &#39;^ &#39; autosuggest-accept&#34; \
    zsh-users/zsh-autosuggestions
```

I left `STRATEGY` and `HISTORY_IGNORE` out on purpose. They had never worked,
so turning them on now would change how suggestions behave, and the completion
strategy costs time on every keystroke. That&#39;s a separate decision.

Rebinding once is safe here because every plugin that wraps widgets loads
before autosuggestions.

## Every start: two compinits fighting over one cache

Why did compinit take 318 ms? The startup trace had a clue: `compinit` also
showed up *before* `.zshrc` was read. Ubuntu&#39;s `/etc/zsh/zshrc` runs its own:

```zsh
if grep -q &#39;^ID.*=.*ubuntu&#39; /etc/os-release &amp;&amp; [[ -z &#34;$skip_global_compinit&#34; ]]; then
  autoload -U compinit
  compinit
fi
```

On Mint, that pattern matches the `ID_LIKE=ubuntu` line, so it runs here too.
That gives two compinits per shell. The global one runs with only the system
completion directories, and zinit&#39;s runs later with all 36 (`fpath`). Both use
`~/.zcompdump`. compinit only reuses that cache if it was built for the same
set of files (its first line records the count), so each run found the other&#39;s
cache stale and rebuilt it. Its timestamp changed with every new shell:

```text
22:47:34.99  ~/.zcompdump
22:48:10.53  ~/.zcompdump   &lt;- after one more shell
22:48:16.57  ~/.zcompdump   &lt;- and another
```

This is also why the 148 ms startup number was optimistic. Back-to-back
`zsh -i -c exit` runs never reach zinit&#39;s compinit, so the cache stayed valid
for the global one. In real use, every interactive shell leaves a cache built
for the full `fpath`. When I restored that state before each run, startup was
**267 ms**.

The fix is a single line in `~/.zshenv`:

```zsh
skip_global_compinit=1
```

### …which exposed lost completions

Plugins call `compdef` to register completions as they load. Before compinit
has run, `compdef` doesn&#39;t exist yet, so zinit records those calls in a queue
for `zinit cdreplay` to apply later. My config never called `cdreplay`. The
queue held 21 entries that had never been applied:

```text
_tmux _zsh_tmux_plugin_run      &lt;- the `tmux` alias from Oh My Zsh&#39;s tmux plugin
_omz_tmux_alias_ta ta           &lt;- ta, tad, ts, tkss
_pip pipig                      &lt;- pip helper aliases
_git ggp=git-checkout           &lt;- git helper functions
_gitignore gi                   &lt;- gi, gii
...
```

With `complete_aliases` off, `tmux &lt;Tab&gt;` completes for whatever the alias
expands to, and `_zsh_tmux_plugin_run` had no completion registered. So it had
been offering file names instead of tmux commands. Running the replay right
after compinit fixed it:

```zsh
zinit ice lucid wait=&#39;0&#39; atinit=&#39;zpcompinit; zpcdreplay -q&#39;
zinit light zdharma-continuum/fast-syntax-highlighting
```

## Proving nothing else changed

Deleting duplicate plugins sounds harmless, but the order in which plugins load
matters. Before touching anything, I dumped everything that defines how the
interactive shell behaves, inside a real interactive shell after the turbo
plugins had loaded:

```zsh
{
  for km in main viins vicmd visual viopp emacs isearch command menuselect; do
    bindkey -M $km -L; done | sort
  alias -L | sort
  print -rl -- ${(ok)functions}
  for w in ${(ok)widgets}; do print -r -- &#34;$w=$widgets[$w]&#34;; done
  set -o | sort; zstyle -L | sort
  print -rl -- $precmd_functions $preexec_functions $chpwd_functions $fpath $path
  for k in ${(ok)_comps}; do print -r -- &#34;$k=$_comps[$k]&#34;; done
  # parameters, with values hashed: my environment holds API keys
  for k in ${(ok)parameters}; do
    print -r -- &#34;$k ${parameters[$k]} $(print -rn -- &#34;${(P)k}&#34; | md5sum)&#34;; done
} &gt; snapshot.txt
```

(The real version also skips parameters that change on their own, such as
`RANDOM`, `PPID` and Powerlevel10k&#39;s internal state.)

I took one snapshot before and one after, and diffed them by section. The diff
caught two regressions I had introduced:

1. **`cd` lost zoxide&#39;s completion.** zoxide only registers it if `compdef`
   already exists when `zoxide init` runs. With the global compinit gone, it
   doesn&#39;t. The fix queues it for the replay instead:

   ```zsh
   (( ${&#43;functions[compdef]} )) || zicompdef __zoxide_z_complete cd
   ```

2. **Tab quietly changed.** fzf-tab wraps whatever Tab is bound to *at the
   moment it loads*. The Oh My Zsh fzf plugin I deleted had bound fzf&#39;s
   completion widget to Tab earlier in the file, so the old chain was fzf-tab →
   fzf-completion (fzf&#39;s `**&lt;Tab&gt;` trigger) → normal completion. Without it,
   fzf-tab wrapped normal completion directly, so fzf&#39;s `**&lt;Tab&gt;` trigger was
   out of the chain. Running fzf&#39;s own setup *before* fzf-tab restores it:

   ```zsh
   eval &#34;$(fzf --zsh)&#34;
   zinit light Aloxaf/fzf-tab
   bindkey -M emacs &#39;^I&#39; fzf-completion   # what the old second `fzf --zsh` left there
   ```

After those fixes, key bindings, aliases, all 854 widgets, options, zstyles,
`fpath` and `PATH` were identical. The only differences left were the intended
ones: the removed plugin, the two hooks I took out, the replayed completions,
and two new settings. There was also one side effect I accepted: `psql` and the
other PostgreSQL tools now complete with zsh-completions&#39; `_pgsql_utils`
instead of zsh&#39;s own `_postgresql`. Both packages provide completion for those
commands, and with only one compinit, zsh-completions&#39; version wins.

## Results

Old and new configs measured the same way (the old one via `ZDOTDIR`, with its
completion cache restored to its real-life state before each run):

| | before | after |
|---|---:|---:|
| startup, `zsh -i -c exit`, median of 15 | 267 ms | **101 ms** |
| `preexec` hooks, i.e. added to every command | 188 ms | **2.9 ms** |
| `precmd` hooks, i.e. added to every prompt | 14.9 ms | **3.9 ms** |
| all plugin loading (`zinit times` total) | 0.39–0.42 s | **0.13 s** |

## What I left alone

- **Caching `eval &#34;$(tool init)&#34;` output.** This is a common tip, but `fzf --zsh`
  took 1.3 ms and `zoxide init` 0.4 ms. Not worth the cache invalidation.
- **Compiling `~/.p10k.zsh`.** It took 2.7 ms to source, or 0.8 ms compiled. Also
  not worth the extra moving part.
- **The three directory jumpers.** Counting my last 20,000 commands: zoxide&#39;s
  `cd` 2,187, autojump&#39;s `j` 225, zsh-z&#39;s `z` 16. I use all three.
- **The ssh-agent zstyles** (`lazy`, `quiet`, `identities`). They come after the
  plugin in my config, so they have never applied. Moving them up would change
  when keys get added, so I left them and added a note.

## Traps

- **Test shells write to your real history.** With `share_history` and
  `inc_append_history`, every command typed into a throwaway shell goes straight
  to `~/.zsh_history`. Start each one with a space: `hist_ignore_space` keeps it
  out.
- **`grep` thinks zsh history is binary.** zsh stores non-ASCII text in its own
  &#34;metafied&#34; form. Without `-a`, `grep -c` quietly counted zero for every command
  I looked for.
- **`zsh -i -c exit` only measures part of the startup.** It misses turbo
  plugins, every hook, and, here, the cache rebuilds.
- **Backslashes inside quoted plugin settings.** If a zinit `atload` or
  `atinit` string spans several lines, check what it looks like as one line.

## Takeaways

1. **Measure all three latencies**: startup, per prompt and per command. The
   biggest cost here was per command, and no startup benchmark would ever show
   it.
2. **List your hooks.** `print -l $preexec_functions $precmd_functions` shows
   everything that runs every time you press Enter. Time each one.
3. **Watch for two compinits.** On Ubuntu and its derivatives,
   `/etc/zsh/zshrc` runs one unless `skip_global_compinit=1` is set. If your
   plugin manager runs another, they fight over the cache.
4. **If compinit runs late, replay the queued compdefs.** Otherwise completions
   disappear without any error.
5. **Diff the shell&#39;s state before and after.** Load order matters, and I&#39;d
   have shipped a broken `cd` completion and Tab chain without the snapshot.

## References

- [zsh-bench](https://github.com/romkatv/zsh-bench): a proper tool for measuring
  first-prompt, command and input lag
- [zinit: turbo mode, `zicompinit` and `zicdreplay`](https://github.com/zdharma-continuum/zinit)
- [zsh-autosuggestions: `ZSH_AUTOSUGGEST_MANUAL_REBIND`](https://github.com/zsh-users/zsh-autosuggestions)
- [fzf-tab](https://github.com/Aloxaf/fzf-tab)
- [zsh manual: prompt expansion (`%D{...}`, `%N`, `%i`) for `PS4`](https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html)
- [The tmux half of this cleanup]({{&lt; relref &#34;2026-10-02-tmux-lag-round-2&#34; &gt;}})


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-02-zsh-startup-and-command-lag/  

