# nvim dap 映射 r 快捷键


最近在研究如何使用 `nvim-dap` 进行 `debugging`。在 `gdb`，我们可以很方便的使用单个按键就可以触发一些行为，如

- [x] `r`: `run`
- [x] `c`: `continue`
- [x] `s`: `step-in`

那么，我的想法也是在 `nvim-dap` 实现这样快捷键 `r` 来模拟 `run` 的行为。现在的问题是：由于在 `normal mode`，单个按键 `r` 代表 `replace one character`。

因此，我们需要在 `nvim` 的 `buffers` 去识别是否启动了 `nvim-dap`

- [x] 如果存在 `dap-repl`，则映射 `r`；
- [x] 如果找不到，则回退到 `replace` 的功能。

&lt;!--more--&gt;

按照以上的思路，我们可以写一个映射函数，用于识别当前打开的 `buffers` 是否能找到 `dap-repl` 即可。以下便是这个快捷键映射的实现

```lua
return {
    &#34;mfussenegger/nvim-dap&#34;,
    keys = {
        { &#34;r&#34;,
            function()
                -- Check if any buffer has dap-repl filetype
                local has_repl = false
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].filetype == &#39;dap-repl&#39; then
                        has_repl = true
                        break
                    end
                end

                if has_repl then
                    return require(&#34;dap&#34;).continue()
                end

                return &#34;r&#34;  -- fallback to normal &#39;r&#39; behavior
            end, desc = &#34;Run/Continue&#34;, mode = {&#34;n&#34;}, expr = true
        },
    }
}
```

![nvim-dap-repl](./nvim-dap-repl.png &#34;using r to run when nvim-dap-repl is actived&#34;)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-02-22-nvim-dap-%E6%98%A0%E5%B0%84-r-%E5%BF%AB%E6%8D%B7%E9%94%AE/  

