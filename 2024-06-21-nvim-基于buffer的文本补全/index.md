# nvim 基于buffer的文本补全


`nvim` 可以通过插件`lsp`实现基于编程语法的自动补全。而对于一般的文本，`lsp` 就无助于事了。这时候我们需要一个基于文本分析的自动补全功能。这个可以通过 `echasnovski/mini.nvim` 来实现

&lt;!--more--&gt;

```lua
return {
    &#34;echasnovski/mini.nvim&#34;,
    enabled = true,
    event = &#34;VeryLazy&#34;,
    config = function()
        require(&#34;mini.completion&#34;).setup {
            -- Delay (debounce type, in ms) between certain Neovim event and action.
            -- This can be used to (virtually) disable certain automatic actions by
            -- setting very high delay time (like 10^7).
            delay = { completion = 100, info = 100, signature = 50 },

            -- Configuration for action windows:
            -- - `height` and `width` are maximum dimensions.
            -- - `border` defines border (as in `nvim_open_win()`).
            window = {
                info = { height = 25, width = 80, border = &#39;none&#39; },
                signature = { height = 25, width = 80, border = &#39;none&#39; },
            },

            -- Way of how module does LSP completion
            lsp_completion = {
                -- `source_func` should be one of &#39;completefunc&#39; or &#39;omnifunc&#39;.
                source_func = &#39;completefunc&#39;,

                -- `auto_setup` should be boolean indicating if LSP completion is set up
                -- on every `BufEnter` event.
                auto_setup = true,

                -- `process_items` should be a function which takes LSP
                -- &#39;textDocument/completion&#39; response items and word to complete. Its
                -- output should be a table of the same nature as input items. The most
                -- common use-cases are custom filtering and sorting. You can use
                -- default `process_items` as `MiniCompletion.default_process_items()`.
                -- process_items = --&lt;function: filters out snippets; sorts by LSP specs&gt;,
            },

            -- Fallback action. It will always be run in Insert mode. To use Neovim&#39;s
            -- built-in completion (see `:h ins-completion`), supply its mapping as
            -- string. Example: to use &#39;whole lines&#39; completion, supply &#39;&lt;C-x&gt;&lt;C-l&gt;&#39;.
            -- fallback_action = --&lt;function: like `&lt;C-n&gt;` completion&gt;,

                -- Module mappings. Use `&#39;&#39;` (empty string) to disable one. Some of them
                -- might conflict with system mappings.
                -- mappings = {
                --     force_twostep = &#39;&lt;C-Space&gt;&#39;, -- Force two-step completion
                --     force_fallback = &#39;&lt;A-Space&gt;&#39;, -- Force fallback completion
                -- },

            -- Whether to set Vim&#39;s settings for better experience (modifies
            -- `shortmess` and `completeopt`)
            set_vim_settings = true,
        }
    end
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-21-nvim-%E5%9F%BA%E4%BA%8Ebuffer%E7%9A%84%E6%96%87%E6%9C%AC%E8%A1%A5%E5%85%A8/  

