# nvim buffer 文本补全


有时我们在编辑一些文本文件时，会同时打开多个 `buffer`，并且希望可能在多个 `buffe` 之间，根据文本进行自动补全。默认的补全规则是基于当前的 `buffer`，这个需要进行相应的修改才能实现我们的需求。

&lt;!--more--&gt;

# nvim-cmp.lua

```lua

local cmp = require(&#34;cmp&#34;)
cmp.setup({
    sources = cmp.config.sources(
        {
            {
                name = &#34;buffer&#34;,
                option = {
                    get_bufnrs = function()
                        return vim.api.nvim_list_bufs()
                    end
                },
            },
            { name = &#34;path&#34; },
        },
    )
})
```

# blink.cmp

```lua
return {
    &#34;saghen/blink.cmp&#34;,
    version = not vim.g.lazyvim_blink_main and &#34;*&#34;,
    build = vim.g.lazyvim_blink_main and &#34;cargo build --release&#34;,
    opts_extend = {
        &#34;sources.completion.enabled_providers&#34;,
        &#34;sources.compat&#34;,
        &#34;sources.default&#34;,
    },
    dependencies = {
        &#34;rafamadriz/friendly-snippets&#34;,
        {
            &#34;saghen/blink.compat&#34;,
            optional = false,
            lazy = true,
            opts = {
                impersonate_nvim_cmp = false,
                debug = false,
            },
            version = not vim.g.lazyvim_blink_main and &#34;*&#34;,
        },
        { &#34;onsails/lspkind.nvim&#34; },
        { &#39;dmitmel/cmp-digraphs&#39; },
    },
    event = &#34;InsertEnter&#34;,

    opts = {
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            -- adding any nvim-cmp sources here will enable them
            -- with blink.compat
            compat = {},
            default = { &#34;lsp&#34;, &#34;path&#34;, &#34;snippets&#34;, &#34;buffer&#34;, &#39;digraphs&#39; },
            providers = {
                buffer = {
                    name = &#39;Buffer&#39;,
                    module = &#39;blink.cmp.sources.buffer&#39;,
                    fallbacks = { &#39;lsp&#39; },
                    min_keyword_length = 1,
                    -- all buffers
                    opts = {
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs()
                        end
                    },
                },
            },
        },
    },
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-02-08-nvim-buffer-%E6%96%87%E6%9C%AC%E8%A1%A5%E5%85%A8/  

