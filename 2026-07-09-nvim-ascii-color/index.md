# nvim ASCII color



# Baleia Auto-Colorize for Neovim

## Problem

Auto-run baleia.nvim to colorize ANSI escape codes when opening, reloading, or creating `.log` files.

&lt;!--more--&gt;


## Key Gotchas

1. **lazy.nvim race condition** — Don&#39;t use a separate autocmd that depends on `vim.g.baleia` before the plugin loads. Instead, use lazy.nvim&#39;s built-in `event` pattern matching to trigger loading, then handle the buffer inside `config`.

2. **`automatically()` vs `once()`** — They do different things:
   - `once(buf)` — colorizes existing buffer content immediately.
   - `automatically(buf)` — attaches an `nvim_buf_attach` handler for **future** lines only; does NOT touch current content.

3. **Reloads** (`:e`, `:e!`) — `config` only runs once. You need a `BufReadPost` autocmd to re-colorize on reload.

4. **`automatically()` is idempotent** — it checks a `baleia_on_new_lines` buffer var and skips if already attached. Safe to call multiple times.

## Solution

All logic lives in the plugin spec — no separate autocmd files needed.

```lua
-- lua/plugins/baleia.lua
return {
    &#34;m00qek/baleia.nvim&#34;,
    version = &#34;*&#34;,
    -- lazy.nvim loads the plugin only when a .log file is opened
    event = { &#34;BufReadPost *.log&#34;, &#34;BufNewFile *.log&#34; },
    config = function()
        vim.g.baleia = require(&#34;baleia&#34;).setup({ })

        local function colorize(buf)
            vim.g.baleia.once(buf)           -- colorize existing content
            vim.g.baleia.automatically(buf)  -- hook new lines (idempotent)
        end

        -- Handle reloads (:e, :e!) and future log file opens
        vim.api.nvim_create_autocmd({ &#34;BufReadPost&#34;, &#34;BufNewFile&#34; }, {
            pattern = &#34;*.log&#34;,
            callback = function()
                colorize(vim.api.nvim_get_current_buf())
            end,
        })

        -- Handle the buffer that triggered lazy loading
        -- (the autocmd above won&#39;t fire for it — event already passed)
        colorize(vim.api.nvim_get_current_buf())

        -- Manual colorize command for non-log files
        vim.api.nvim_create_user_command(&#34;BaleiaColorize&#34;, function()
            vim.g.baleia.once(vim.api.nvim_get_current_buf())
        end, { bang = true })

        -- Show baleia logs
        vim.api.nvim_create_user_command(&#34;BaleiaLogs&#34;, vim.cmd.messages, { bang = true })
    end,
}
```

## How Each Scenario Works

| Scenario | What fires | `once` | `automatically` |
|---|---|---|---|
| **First open** `.log` | Explicit call in `config` | Colorizes existing ANSI | Attaches buf handler |
| **Reload** (`:e!`) | `BufReadPost` autocmd | Re-colorizes reloaded content | No-op (already attached) |
| **Open another** `.log` | `BufReadPost` autocmd | Colorizes existing ANSI | Attaches buf handler |
| **Create new** `.log` | `BufNewFile` autocmd | No-op (empty buffer) | Attaches buf handler |

## Notes

- For `tail -f` / live-log scenarios, `automatically` ensures newly appended lines are colorized as they arrive.
- Remove the `BufReadPost quickfix` entry from the event list if you don&#39;t need quickfix colorization.
- Tested on baleia.nvim v1.x (`m00qek/baleia.nvim`).


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-07-09-nvim-ascii-color/  

