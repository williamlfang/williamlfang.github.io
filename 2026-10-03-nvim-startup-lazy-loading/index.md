# Profiling Neovim startup: lazy-loaded plugins that weren&#39;t lazy


&gt; **Update 2026-10-17:** the next pass looked at big log files, and found an
&gt; `nc` mapping that made every `n` wait `timeoutlen` (500 ms) in every file. See
&gt; [Profiling Neovim on big logs]({{&lt; relref &#34;2026-10-17-nvim-big-log-files&#34; &gt;}}).

After [tmux]({{&lt; relref &#34;2026-10-02-tmux-lag-round-2&#34; &gt;}}) and
[zsh]({{&lt; relref &#34;2026-10-02-zsh-startup-and-command-lag&#34; &gt;}}), I looked at
Neovim. My config has grown to 138 plugins on lazy.nvim and LazyVim. Almost
every spec has an `event`, `cmd` or `keys`, so I assumed most of them were lazy.
They weren&#39;t: **89 of the 138 plugins loaded at startup**.

None of the causes was a slow plugin. They were config mistakes that only show
up once you ask lazy.nvim *why* each plugin loaded. I fixed them in two rounds:

| | before | after |
|---|---:|---:|
| CPU time to first screen, opening a new file | ~150 ms | **~120 ms** |
| CPU time to first screen, no file (dashboard) | 69 ms | **50 ms** |
| plugins loaded at startup | 89 | **73** |

&lt;!--more--&gt;

## The setup

- Neovim [v0.12.5]({{&lt; relref &#34;2026-09-10-neovim-v0.12.5&#34; &gt;}}), LuaJIT 2.1
- lazy.nvim with LazyVim as the base, pinned to a May 2024 commit
- 138 plugin specs under `~/.config/nvim/lua/plugins/`, plus old ones in
  `disabled/`, `tmp/` and `x/`
- `vim.loader.enable()` and lazy&#39;s `performance.rtp.disabled_plugins` already
  set, so the usual quick fixes were already done

## Step 1: headless numbers are too optimistic

The usual first measurement:

```bash
nvim --headless --startuptime st.log &#43;qa
tail -2 st.log
```

```text
063.355  000.003: editing files in windows
063.359  000.003: --- NVIM STARTED ---
```

63 ms looks fine, but it isn&#39;t what I see when I start Neovim. Headless mode
has no UI, so there&#39;s no `UIEnter`. Without `UIEnter`, lazy.nvim never fires
`VeryLazy`, and everything deferred to `VeryLazy` doesn&#39;t run.

To measure a real start, Neovim needs a terminal. `script` gives it a pty. I
also load a small probe with `--cmd`. At `VeryLazy` it asks lazy.nvim for its
stats and for the reason each plugin was loaded, writes them to a file, then
quits:

`measure.lua`:

```lua
vim.api.nvim_create_autocmd(&#34;User&#34;, { pattern = &#34;VeryLazy&#34;, callback = function()
  vim.defer_fn(function()
    local s = require(&#34;lazy&#34;).stats()
    local loaded = {}
    for _, p in ipairs(require(&#34;lazy&#34;).plugins()) do
      if p._.loaded then
        -- p._.loaded holds the reason: { event = ... } / { plugin = ... } / { start = ... }
        table.insert(loaded, string.format(&#34;%-40s %6.2fms  %s&#34;, p.name,
          (p._.loaded.time or 0) / 1e6, vim.inspect(p._.loaded):gsub(&#34;%s&#43;&#34;, &#34; &#34;)))
      end
    end
    local f = io.open(vim.env.OUT, &#34;w&#34;)
    f:write(string.format(&#34;startuptime=%.2fms count=%d loaded=%d\n&#34;, s.startuptime, s.count, s.loaded))
    for k, v in pairs(s.times or {}) do f:write(k .. &#34;=&#34; .. v .. &#34;\n&#34;) end
    f:write(table.concat(loaded, &#34;\n&#34;))
    f:close()
    vim.cmd(&#34;qa!&#34;)
  end, 1500)
end })
```

```bash
for i in 1 2 3; do
  OUT=stats$i.txt TERM=xterm-256color \
    script -qc &#34;nvim --startuptime tui$i.log --cmd &#39;luafile measure.lua&#39; x.lua&#34; /dev/null \
    &gt;/dev/null &lt;/dev/null
  head -1 stats$i.txt
done
```

```text
startuptime=137.55ms count=138 loaded=89
startuptime=170.15ms count=138 loaded=89
startuptime=151.94ms count=138 loaded=89
```

`startuptime` is lazy.nvim&#39;s time to `UIEnter`, which is roughly when the
first screen is drawn (CPU time, see below). The `times` table splits it up: lazy.nvim started at
10 ms, had set up all startup plugins by 54 ms, and `UIEnter` came at 138 ms.
So **most of the time went to opening the file**, after lazy.nvim&#39;s own setup.

### A 114 ms trap in the measurement itself

In the pty runs, `--startuptime` showed one very large entry, before my config
had even been read:

```text
119.938  114.801  114.694: require(&#39;vim._core.defaults&#39;)
```

That&#39;s Neovim&#39;s own runtime. Since 0.10 it asks the terminal for its background
color (OSC 11, plus a DSR query) and waits up to 100 ms for the answer.
`script` never answers, so every pty run included that wait. `:messages` says
so:

```text
E1568: Terminal did not respond to DSR request for &#39;background&#39; color. Startup may be slower. :help &#39;ttyfast&#39;
```

A real terminal answers in about a millisecond. So I ignored the total
`NVIM STARTED` time from these runs and compared lazy.nvim&#39;s `startuptime`
instead. On Linux, lazy.nvim measures it as **process CPU time**
(`clock_gettime(CLOCK_PROCESS_CPUTIME_ID)` in `lazy/stats.lua`). Time spent
idle, waiting for a reply that never comes, doesn&#39;t count.

One more caution: in one run `require(&#39;lazyvim.config.autocmds&#39;)` took
19.7 ms, and in the next two runs 0.07 ms. **Always run at least three times
before blaming a line.**

## Step 2: ask why each plugin loaded

The interesting part of the probe output is the reason column. Sorted, a few
patterns stood out right away:

```text
remote-sshfs.nvim                         10.50ms  { event = &#34;VeryLazy&#34; }
telescope.nvim                             8.42ms  { plugin = &#34;remote-sshfs.nvim&#34; }
telescope-fzf-native.nvim                  3.68ms  { plugin = &#34;telescope.nvim&#34; }
nvim-dap                                   4.47ms  { ft = &#34;lua&#34; }
nvim-dap-ui                                3.44ms  { plugin = &#34;nvim-dap&#34; }
nvim-tree.lua                              7.85ms  { event = &#34;VeryLazy&#34; }
diffview.nvim                              4.12ms  { start = &#34;start&#34; }
fold-preview.nvim                          3.63ms  { start = &#34;start&#34; }
namu.nvim                                  2.20ms  { start = &#34;start&#34; }
vscode-diff.nvim                           0.93ms  { start = &#34;start&#34; }
lsp-setup.nvim                            24.64ms  { event = &#34;BufNewFile&#34; }
nvim-lspconfig                            22.68ms  { event = &#34;LazyFile&#34; }
blink.cmp                                 17.23ms  { plugin = &#34;nvim-lspconfig&#34; }
friendly-snippets                          8.97ms  { plugin = &#34;blink.cmp&#34; }
LuaSnip                                    6.83ms  { plugin = &#34;friendly-snippets&#34;, require = &#34;luasnip.loaders.from_vscode&#34; }
```

- **`{ start = &#34;start&#34; }`** means the spec has no lazy trigger. I set
  `defaults.lazy = false`, so every spec without an `event`, `cmd`, `keys` or
  `ft` loads at startup.
- **`{ plugin = &#34;X&#34; }`** means it loaded because X listed it in `dependencies`.
  A dependency always loads together with its parent, even if it has its own
  `cmd`.
- **`{ ft = &#34;lua&#34; }`** on a debugger: dap loaded because I opened a Lua file.

## Round 1: the obvious ones

| plugin | why it loaded | fix |
|---|---|---|
| remote-sshfs &#43; telescope | `event = &#34;VeryLazy&#34;`, and telescope is its dependency | `cmd` &#43; `keys` |
| nvim-dap &#43; dap-ui | `event = &#34;VeryLazy&#34;` **and** `ft = {&#39;c&#39;,&#39;cpp&#39;,&#39;go&#39;,&#39;lua&#39;,&#39;python&#39;}` | `keys` only |
| diffview, vscode-diff | no trigger | `cmd = { &#34;Diffview*&#34; }`, `cmd = &#34;CodeDiff&#34;` |
| namu | no trigger | `cmd` &#43; `keys` &#43; a `vim.ui.select` stub |
| telescope | `event = &#34;VeryLazy&#34;` | `cmd = &#34;Telescope&#34;` |

A few details that matter:

- **remote-sshfs defines `&lt;Leader&gt;ff` and `&lt;Leader&gt;fg` in its `config`.** They
  replace my normal telescope mappings with versions that search the remote
  host when connected. If the plugin only loaded on `:RemoteSSHFSConnect`,
  those keys would quietly go back to the plain ones until the first connect.
  So I listed them in `keys`. Pressing one loads the plugin, its `config`
  installs the real mapping, and lazy.nvim replays the keys.
- **My dap `r` key still works.** It&#39;s an `expr` mapping that runs `continue`
  in a debug session and falls back to normal `r` (replace a character)
  everywhere else ([that post]({{&lt; relref &#34;2025-02-22-nvim-dap-映射-r-快捷键&#34; &gt;}})).
  Now that it&#39;s in `keys`, the first `r` loads dap. I checked in a pty that
  `rX` / `rY` on two lines still give `Xbc` / `Ybc`.
- **namu loaded at startup just to take over `vim.ui.select`.** I checked who
  owned it in a running session:

  ```lua
  debug.getinfo(vim.ui.select, &#34;S&#34;).source
  -- @.../lazy/namu.nvim/lua/namu/ui_select/ui_select.lua
  ```

  To keep namu as the owner without loading it, I install a stub at the same
  point in startup where namu&#39;s setup used to run, which is `LazyDone`. The
  stub loads namu on the first call:

  ```lua
  init = function()
    vim.api.nvim_create_autocmd(&#34;User&#34;, {
      pattern = &#34;LazyDone&#34;,
      once = true,
      callback = function()
        vim.ui.select = function(...)
          require(&#34;lazy&#34;).load({ plugins = { &#34;namu.nvim&#34; } })
          return vim.ui.select(...)   -- namu&#39;s setup has replaced it by now
        end
      end,
    })
  end,
  ```

### …and telescope still loaded

After all that, telescope was still there, now for a different reason:

```text
telescope.nvim                            13.22ms  { plugin = &#34;nvim-neoclip.lua&#34; }
```

`nvim-neoclip.lua` has to start early so it can record yanks. Its spec listed
both pickers it supports as hard dependencies:

```lua
dependencies = {
    -- you&#39;ll need at least one of these
    {&#39;nvim-telescope/telescope.nvim&#39;},
    {&#39;ibhagwan/fzf-lua&#39;},
},
```

neoclip&#39;s `setup()` doesn&#39;t use either of them. Only its pickers do, and those
`require` telescope or fzf-lua when you open them. lazy.nvim loads a lazy
plugin automatically when one of its modules is `require`d. So I removed both
from `dependencies`, and gave fzf-lua its own lazy spec so it stays installed.
`:Telescope neoclip` still works.

After round 1: **73 plugins at startup, `startuptime` 117–125 ms**, and about
33 ms less work right after the first screen.

## Round 2: opening a file

Round 1 was measured opening a file that doesn&#39;t exist yet (`BufNewFile`).
Opening a real file also fires `BufReadPost` and more plugins load. This time
I looked at which `require`s ran while the buffer was opened:

```bash
# --startuptime lines: clock, self&#43;sourced, self, name. Keep the part after
# ShaDa is read (i.e. after init.lua), sort by self&#43;sourced.
awk &#39;/reading ShaDa/{p=1} p&#39; server.log | grep -E &#39;^[0-9.]&#43; &#43;[0-9.]&#43; &#43;[0-9.]&#43;:&#39; \
  | awk &#39;{print $2, $4}&#39; | sort -rn | head
```

```text
009.587 require(&#39;luasnip.loaders.from_vscode&#39;)
005.895 require(&#39;luasnip.loaders.from_vscode&#39;)
005.227 require(&#39;luasnip.util.parser&#39;)
...
```

**The VSCode snippet loader ran twice, about 15 ms**, every time a file was
opened, before I had typed anything.

### Snippets loaded through a dependency&#39;s config

The chain was: the LSP specs list `blink.cmp` as a dependency (they need its
capabilities). blink lists `friendly-snippets`, and that dependency had its own
`config`. My blink spec is `plugins/blink-cmp.lua`, which turned out to be a
symlink to `x/blink-cmp.new.lua`:

```lua
{
  &#34;rafamadriz/friendly-snippets&#34;,
  config = function()
    require(&#34;luasnip.loaders.from_vscode&#34;).lazy_load()
    require(&#34;luasnip.loaders.from_vscode&#34;).lazy_load({ paths = { vim.fn.stdpath(&#34;config&#34;) .. &#34;/snippets&#34; } })
  end,
},
```

That&#39;s three problems in one block:

1. blink doesn&#39;t use LuaSnip. It has its own snippet source.
2. My LuaSnip spec already does the same two `lazy_load` calls on
   `InsertEnter`.
3. **`~/.config/nvim/snippets` doesn&#39;t exist.** My
   [own snippets]({{&lt; relref &#34;2025-02-09-nvim-添加自定义代码段-snippets&#34; &gt;}})
   live in `snips/`. That explains the warnings that had grown `luasnip.log` to
   3.4 MB. Back then I lowered LuaSnip&#39;s log level to hide them. Now the cause
   is gone.

The fix is to keep the dependency and remove its `config`:

```lua
{ &#34;rafamadriz/friendly-snippets&#34; },
```

Checked in a session: LSP still starts with snippet support
(`lua_ls(snip)`), LuaSnip isn&#39;t loaded until the first `InsertEnter`, and then
it has 18 Lua and 31 global snippets.

### A disabled spec that still ran code

The same profile showed `require(&#39;cmp&#39;)` during spec import, although I use
blink and `nvim-cmp.lua` says `enabled = false`. The file starts like this:

```lua
local M = {
	&#34;hrsh7th/nvim-cmp&#34;,
	...
    enabled = false,
}

local cmp = require&#39;cmp&#39;
local luasnip = require&#39;luasnip&#39;
```

**A spec file is a Lua module, and lazy.nvim runs all of it while importing
specs.** `enabled = false` only applies to the table it returns. The two
`require`s at the top run anyway. Headless, without any file:

```text
cmp=true luasnip=true LuaSnip loaded=false
```

So both modules were loaded at startup even though lazy.nvim considered the
plugin not loaded. I moved them inside a lazy wrapper:

```lua
local luasnip = setmetatable({}, { __index = function(_, k) return require(&#39;luasnip&#39;)[k] end })
```

### lualine was set up twice

`theme.lua` had cost 12–16 ms in every run. It loads the colorscheme and then
builds my lualine config, starting with:

```lua
local custom_fname = require(&#39;lualine.components.filename&#39;):extend()
```

That `require` loads lualine immediately. lazy.nvim then runs LazyVim&#39;s lualine
spec, which builds LazyVim&#39;s statusline and calls `setup()`. A hundred lines
later, `theme.lua` calls `require(&#39;lualine&#39;).setup({...})` again with my
config. So there were **two full setups at startup, and the first one was
thrown away**.

The fix was to move the lualine part of `theme.lua` unchanged into
`lua/statusline.lua`, which returns the config table, and pass it as `opts`:

`lua/plugins/lualine.lua`:

```lua
return {
    &#34;nvim-lualine/lualine.nvim&#34;,
    opts = function()
        local opts = require(&#34;statusline&#34;)
        opts.options.globalstatus = true   -- see below
        return opts
    end,
    config = function(_, opts)
        require(&#34;lualine&#34;).setup(opts)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == &#34;snacks_dashboard&#34; then
                vim.o.laststatus = 0
                break
            end
        end
    end,
}
```

Now `theme.lua` only loads kanagawa, and lualine is set up once, at
`VeryLazy`. The last ten lines of that spec are there because of a regression
I introduced first.

### Deferring setup changed what it saw

My first version only returned the opts. With a file argument, the statusline
was identical to before. Started without a file, the dashboard now showed a
statusline. Before, the dashboard had hidden it.

snacks&#39; dashboard hides the statusline by setting `laststatus=0`, and restores
it when the dashboard closes. To find what turned it back on, I wrapped every
Lua write to `vim.o.laststatus`:

```lua
local mt = getmetatable(vim.o); local orig = mt.__newindex
mt.__newindex = function(t, k, v)
  if k == &#34;laststatus&#34; then
    log[#log&#43;1] = (&#34;set -&gt; %s  %s&#34;):format(v, debug.traceback(&#34;&#34;, 2))
  end
  return orig(t, k, v)
end
```

```text
set 3 -&gt; 0   lazyvim/plugins/ui.lua:119: in function &#39;init&#39;
set 3 -&gt; 0   snacks/dashboard.lua:1187: in function &#39;setup&#39;
set 0 -&gt; 3   lazyvim/plugins/ui.lua:129: in function &#39;values&#39;
set 3 -&gt; 0   lua/plugins/lualine.lua:14: in function &#39;values&#39;
final ls=2
```

My own fix (set it back to 0 in `opts`) did run, but something set it to `2`
afterwards without going through `vim.o`. A grep found it in lualine itself:

```lua
-- lualine.nvim/lua/lualine/config.lua
globalstatus = vim.go.laststatus == 3,
-- lualine.nvim/lua/lualine.lua
modules.nvim_opts.set(&#39;laststatus&#39;, 2, { global = true })
```

**lualine decides `globalstatus` from `laststatus` at the moment `setup()`
runs.** Before, setup ran during startup, while `laststatus` was still 3 from
my options, so the statusline was global. At `VeryLazy` the dashboard had
already set it to 0, so lualine chose per-window statuslines and forced
`laststatus=2`. Setting `globalstatus = true` explicitly and hiding the
statusline *after* `setup()` restores the old behavior. With these two changes,
four out of four runs ended with `laststatus=0` on the dashboard, and `3` after
opening a file.

### nvim-tree: two specs, one plugin

The last one. My nvim-tree spec has `event = &#34;VeryLazy&#34;` because it
[opens the tree when Neovim starts without a file]({{&lt; relref &#34;2024-09-10-nvim-tree-auto-open&#34; &gt;}}).
That shouldn&#39;t apply when I open a file. I changed it to load on `:NvimTree*`
commands, with an `init` that loads it at `VeryLazy` only when there&#39;s no file
argument or the argument is a directory:

```lua
init = function()
    if vim.fn.argc(-1) == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
        vim.api.nvim_create_autocmd(&#34;User&#34;, {
            pattern = &#34;VeryLazy&#34;,
            once = true,
            callback = function()
                require(&#34;lazy&#34;).load({ plugins = { &#34;nvim-tree.lua&#34; } })
            end,
        })
    end
end,
```

It still loaded on every start. lazy.nvim&#39;s merged spec showed why:

```bash
nvim --headless -c &#39;lua local p = require(&#34;lazy.core.config&#34;).spec.plugins[&#34;nvim-tree.lua&#34;]
  io.write(&#34;event=&#34;, vim.inspect(p.event), &#34; lazy=&#34;, tostring(p.lazy), &#34;\n&#34;)&#39; &#43;qa
```

```text
event=&#34;VeryLazy&#34; lazy=true
```

```bash
grep -rln &#34;nvim-tree.lua&#39;\|nvim-tree.lua\&#34;&#34; lua/plugins --include=*.lua | grep -v &#39;\.bak&#39;
```

```text
lua/plugins/nvim-tree.lua
lua/plugins/disabled/nvim-tree-preview.lua
lua/plugins/tmp/nvim-tree.lua
lua/plugins/navigation/nvim-tree.lua
lua/plugins/navigation/nvim-tree-preview.lua
```

(`disabled/` and `tmp/` aren&#39;t imported.)

**lazy.nvim merges all specs with the same plugin name.** There was an older
`plugins/nvim-tree.lua` from September next to the one in `navigation/`. Its
`config` was replaced by the newer one (later imports win), so it had looked
dead. Its `event = &#34;VeryLazy&#34;` was still merged in. The preview plugin&#39;s file
also re-declares nvim-tree with `event = &#34;VeryLazy&#34;`. I commented out the event
in both. I also checked that `nvim &lt;directory&gt;` behaves as before: I swapped
the original files back in and compared.

## Verifying behavior, not just speed

Making a plugin lazy can break it without any error. Keys may lose their
mapping, or a plugin may lose ownership of something like `vim.ui.select`.
After each change I ran a probe in a pty, at `VeryLazy`, like the timing one:

```lua
local P = require(&#34;lazy.core.config&#34;).plugins
f:write(&#34;namu loaded=&#34; .. tostring(P[&#34;namu.nvim&#34;]._.loaded ~= nil) .. &#34;\n&#34;)
for _, lhs in ipairs({ &#34; ff&#34;, &#34; fg&#34;, &#34; rc&#34;, &#34; ns&#34;, &#34; db&#34; }) do
  local m = vim.fn.maparg(lhs, &#34;n&#34;, false, true)
  f:write(&#34;map&lt;leader&gt;&#34; .. lhs:sub(2) .. &#34;=&#34; .. (m.desc or m.rhs or &#34;?&#34;) .. &#34;\n&#34;)
end
pcall(vim.ui.select, { &#34;a&#34; }, {}, function() end)
f:write(&#34;ui.select=&#34; .. debug.getinfo(vim.ui.select, &#34;S&#34;).source .. &#34;\n&#34;)
```

```text
remote-sshfs.nvim loaded=false
nvim-dap loaded=false
namu.nvim loaded=false
map&lt;leader&gt;ff=Find files (remote-aware)
map&lt;leader&gt;rc=RemoteSSHfs connect
map&lt;leader&gt;ns=Jump to LSP symbol
map&lt;leader&gt;db=Toggle Breakpoint
namu after ui.select=true
ui.select=@.../lazy/namu.nvim/lua/namu/ui_select/ui_select.lua
diffview cmd ok=true
```

Other probes checked LSP capabilities, LuaSnip snippet counts, lualine&#39;s final
config, the `laststatus` value in each start mode, `&lt;F5&gt;` opening the tree,
and dap&#39;s `r` fallback. Every edited file has a `*.bak.20261002` copy next to
it, so the A/B runs below just swapped files.

## Results

Round 1 (opening a new file, 3–6 runs each):

| | before | after |
|---|---:|---:|
| lazy.nvim `startuptime` | 138–170 ms | **118–125 ms** |
| plugins loaded at startup | 89 | **73** |
| work right after first screen (remote-sshfs, telescope, dap) | ~33 ms | **0** |

Round 2 (original vs fixed files, median of 7):

| | before | after |
|---|---:|---:|
| no file (dashboard) | 69.4 ms | **50.2 ms** |
| existing file | 201.2 ms, 111 plugins | **194.9 ms**, 108 plugins |

Most of the dashboard gain comes from lualine. For an existing file, the gain
is within run-to-run noise. LuaSnip no longer loads, but the remaining cost is
in other plugins.

## What&#39;s left

Opening a real file still loads a lot of plugins on `BufRead*`:

| plugin | cost | note |
|---|---:|---|
| lsp-setup.nvim | 13.7 ms | mason registry checks for `ensure_installed` |
| opencode.nvim | 13.0 ms | `event = &#34;BufRead&#34;`, could be `cmd`/`keys` |
| marker-groups.nvim | 10.2 ms | same |
| lazygit.nvim &#43; telescope | 9.0 &#43; 7.7 ms | pulls telescope back in on every file |
| avante.nvim | 4.4 ms | same |

LazyVim is also pinned to a May 2024 commit. Updating it is overdue, but it&#39;s a
bigger change than any of the above.

## Takeaways

1. **Measure in a real terminal, and know what the harness adds.** Headless
   skips `VeryLazy` completely. A pty without a real terminal adds a 100 ms
   wait for a reply that never comes. Compare runs measured the same way.
2. **Ask lazy.nvim why each plugin loaded.** `p._.loaded` contains the reason.
   `{ start = &#34;start&#34; }` and `{ plugin = &#34;X&#34; }` point directly at the spec to
   fix.
3. **`dependencies` means &#34;load together with me&#34;.** For optional
   integrations, such as pickers, let `require` load them on demand.
4. **Specs are merged by name.** An old duplicate file can still add an
   `event`. Query `require(&#34;lazy.core.config&#34;).spec.plugins[name]` to see what
   lazy.nvim actually uses.
5. **A spec file is code.** `enabled = false` doesn&#39;t stop `require`s at the
   top of the file.
6. **Deferring a setup changes what it sees.** lualine reads `laststatus` when
   `setup()` runs. Pin the values that used to come from startup order.
7. **Verify behavior after each change, not only the timing.** Every
   regression in this post was silent. Probes showed them; the timings alone
   didn&#39;t.

## References

- lazy.nvim: [lazy loading](https://lazy.folke.io/spec/lazy_loading) and
  [spec merging](https://lazy.folke.io/spec#spec-merging)
- `:help --startuptime`, `:help &#39;ttyfast&#39;`
- Neovim runtime: `lua/vim/_core/defaults.lua` (OSC 11 background detection)
- lualine.nvim: `lua/lualine/config.lua` (`globalstatus` default)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-03-nvim-startup-lazy-loading/  

