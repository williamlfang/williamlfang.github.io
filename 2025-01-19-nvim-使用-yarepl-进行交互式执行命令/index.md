# nvim 使用 yarepl 进行交互式执行命令


我有时候需要使用一些脚本语言进行工作，比如使用 `bash` 编写简单的任务、使用 `python` 进行数据分析。这些脚本语言的一个好处是可以快速的验证想法，比较灵活操作一些简单的任务。同时，脚本语言还提供了 `REPL` 的交互式操作，即可以一边写代码、一边执行代码。比如，对于 `python` 脚本，我可能写了一个函数，然后想快速验证函数里面的某写代码块是否符合逻辑，这时候我们可以利用 `REPL` 的功能把相关的代码快输入到解释器，即可得到验证。

在 `nvim` 中编写 `python` 代码，如何配置实现 `REPL` 功能呢？

这可以通过插件 `yarepl.nvim` 完成。

&lt;!--more--&gt;

# yarepl

首先需要配置

```lua
return {
    &#34;milanglacier/yarepl.nvim&#34;,
    lazy = true,
    event = &#34;BufReadPost&#34;,
    ft = { &#34;python&#34;, &#34;bash&#34;, &#34;R&#34; },
    config = function()
        local yarepl = require &#39;yarepl&#39;
        yarepl.setup {
            -- see `:h buflisted`, whether the REPL buffer should be buflisted.
            buflisted = false,
            -- whether the REPL buffer should be a scratch buffer.
            scratch = false,
            -- the filetype of the REPL buffer created by `yarepl`
            ft = &#39;REPL&#39;,
            -- How yarepl open the REPL window, can be a string or a lua function.
            -- See below example for how to configure this option
            -- wincmd = &#39;belowright 15 split&#39;,
            -- wincmd = &#39;vertical 120 split&#39;,
            wincmd = &#39;vertical split&#39;, -- equally 50%
            -- wincmd = function(bufnr, name)
            --     if name == &#39;ipython&#39; then
            --         vim.api.nvim_open_win(bufnr, true, {
            --             relative = &#39;editor&#39;,
            --             row = math.floor(vim.o.lines * 0.25),
            --             col = math.floor(vim.o.columns * 0.25),
            --             width = math.floor(vim.o.columns * 0.5),
            --             height = math.floor(vim.o.lines * 0.5),
            --             style = &#39;minimal&#39;,
            --             title = name,
            --             border = &#39;rounded&#39;,
            --             title_pos = &#39;center&#39;,
            --         })
            --     else
            --         -- vim.cmd [[belowright 15 split]]
            --         -- vim.api.nvim_set_current_buf(bufnr)
            --     end
            -- end,
            -- The available REPL palattes that `yarepl` can create REPL based on
            metas = {
                aichat = { cmd = &#39;aichat&#39;, formatter = yarepl.formatter.bracketed_pasting },
                radian = { cmd = &#39;radian&#39;, formatter = yarepl.formatter.bracketed_pasting },
                ipython = { cmd = &#39;ipython&#39;, formatter = yarepl.formatter.bracketed_pasting },
                -- python = { cmd = &#39;python&#39;, formatter = yarepl.formatter.trim_empty_lines },
                python = { cmd = &#39;bpython -q&#39;, formatter = yarepl.formatter.trim_empty_lines },
                R = { cmd = &#39;R&#39;, formatter = yarepl.formatter.trim_empty_lines },
                bash = { cmd = &#39;bash&#39;, formatter = yarepl.formatter.trim_empty_lines },
                zsh = { cmd = &#39;zsh&#39;, formatter = yarepl.formatter.bracketed_pasting },
            },
            -- when a REPL process exits, should the window associated with those REPLs closed?
            close_on_exit = true,
            -- whether automatically scroll to the bottom of the REPL window after sending
            -- text? This feature would be helpful if you want to ensure that your view
            -- stays updated with the latest REPL output.
            scroll_to_bottom_after_sending = true,
            os = {
                -- Some hacks for Windows. macOS and Linux users can simply ignore
                -- them. The default options are recommended for Windows user.
                windows = {
                    -- Send a final `\r` to the REPL with delay,
                    send_delayed_cr_after_sending = true,
                },
            },
        }
        -- 在这里的定义：~/.config/nvim/lazy/yarepl.nvim/lua/yarepl/init.lua
        -- modifi: api.nvim_create_user_command(&#39;REPLStart&#39;, function(opts)
        -- vim.keymap.set({&#34;n&#34;}, &#34;&lt;CR&gt;&#34;, &#34;:REPLSendLine&lt;CR&gt;j&#34;, { silent = true })
        -- vim.keymap.set({&#34;v&#34;}, &#34;&lt;CR&gt;&#34;, &#34;&lt;Esc&gt;:REPLSendVisual&lt;CR&gt;j&#34;, { silent = true })
    end
}
```

# 设置快捷键 `Enter` 执行代码

## 效果

我通过绑定快捷键 `Enter` 触发代码块

- 如果是在 `normal` 模式，按下 `Enter` 会执行当前这一行的代码
- 如果是在 `visual` 模型，按下 `Enter` 则触发执行高亮的代码块

## 修改触发条件

为了实现以上效果，我们需要修改 `yarepl` 的默认配置，使其在进入 `REPL` 状态是，修改 `Enter` 键的绑定功能。


```lua

api.nvim_create_user_command(&#39;REPLStart&#39;, function(opts)
    -- if calling the command without any count, we want count to become 1.
    local repl_name = opts.args
    local id = opts.count == 0 and 1 or opts.count
    local repl = M._repls[id]
    local current_bufnr = api.nvim_get_current_buf()

    if repl_is_valid(repl) then
        vim.notify(string.format(&#39;REPL %d already exists&#39;, id))
        focus_repl(repl)
        return
    end

    -- binding Enter under normal/visual mode
    vim.keymap.set({&#34;n&#34;}, &#34;&lt;CR&gt;&#34;, &#34;:REPLSendLine&lt;CR&gt;j&#34;, { silent = true })
    vim.keymap.set({&#34;v&#34;}, &#34;&lt;CR&gt;&#34;, &#34;&lt;Esc&gt;:REPLSendVisual&lt;CR&gt;j&#34;, { silent = true })
    -- ...
)
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-19-nvim-%E4%BD%BF%E7%94%A8-yarepl-%E8%BF%9B%E8%A1%8C%E4%BA%A4%E4%BA%92%E5%BC%8F%E6%89%A7%E8%A1%8C%E5%91%BD%E4%BB%A4/  

