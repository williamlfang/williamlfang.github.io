# avante.nvim


前两天在 B 站看了一个视频， 介绍了目前国内 `AI` 领域做得非常不错的一家公司，也是量化界的领头羊-幻方。其中，谈到他们开发大模型 `deepseek` 已经拥有非常强劲的实力，能够满足大部分场景下的 `AGI` 使用，比如机器人、自动化代码生成器等。联想到之前我在网上看到 `avante.nvim` 这个插件可以为 `nvim` 带来 `AI` 辅助功能，当时由于国内还无法使用国外开发的大模型工具，所以就不了了之了。现在终于可以在国内合理合法的使用 `AI` 在 `nvim` 中辅助编程了。


&lt;!--more--&gt;

# 购买 API 服务

# avante.nvim

## 配置

## 操作

## 效果

# FAQ

## 标题颜色

参考：[Avante - get rid of &#34;half moon&#34; symbols](https://www.reddit.com/r/neovim/comments/1fn11ln/avante_get_rid_of_half_moon_symbols/)

修改 `~/.config/nvim/init.lua`

```lua
-- require(&#34;avante&#34;);
local set_hl = vim.api.nvim_set_hl
local function setup_avante_highlights()
    -- Apply highlights for title
    set_hl(0, &#34;AvanteTitle&#34;, { fg = &#34;black&#34;, bg = &#34;#DCA561&#34; })
    set_hl(0, &#34;AvanteReversedTitle&#34;, {
        fg = &#34;#DCA561&#34;,
        bg = &#34;#16161D&#34;,
    })
    -- Apply highlights for subtitle
    -- set_hl(0, &#34;AvanteSubtitle&#34;, { fg = &#34;#c4746e&#34;, bg= &#34;#a09cac&#34; })
    set_hl(0, &#34;AvanteSubtitle&#34;, { fg = &#34;black&#34;, bg= &#34;#a09cac&#34; })
    set_hl(0, &#34;AvanteReversedSubtitle&#34;, {
        fg = &#34;#a09cac&#34;,
        bg = &#34;#16161D&#34;,
    })
    -- Apply highlights for prompt
    set_hl(0, &#34;AvanteThirdTitle&#34;, { fg=&#34;#5d57a3&#34;, bg= &#34;#76946A&#34; })
    set_hl(0, &#34;AvanteReversedThirdTitle&#34;, {
        fg = &#34;#76946A&#34;,
        bg = &#34;#16161D&#34;,
    })
    -- Apply highlights for hints
    -- set_hl(0, &#34;AvanteInlineHint&#34;, { link = &#34;LspDiagnosticsVirtualTextHint&#34; })
    -- set_hl(0, &#34;AvantePopupHint&#34;, { link = &#34;DiagnosticVirtualTextHint&#34; })
end
-- Run the function
setup_avante_highlights()

vim.opt.syntax = &#34;on&#34;
vim.g.markdown_fenced_languages = {&#39;Avante&#39;, &#39;python&#39;, &#39;javascript&#39;, &#39;html&#39;, &#39;bash&#39;, &#39;sh&#39;}
```

## Avante markdown 无法高亮

参考：[bug: Codeblocks and quote blocks have weird interactions](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/249)

需要修改 `~/.config/nvim/lua/plugins/nvim-treesitter.lua`，通过 `config` 使其加载进来

```lua
config = function(_, opts)
    require&#39;nvim-treesitter.configs&#39;.setup(opts)
end
```

完整的配置如下：

```lua
return {
    &#34;nvim-treesitter/nvim-treesitter&#34;,
    build = &#34;:TSUpdate&#34;,
    -- event = &#34;VeryLazy&#34;,
    event = &#34;BufRead&#34;,
    -- ft = { &#34;cpp&#34;, &#34;python&#34;, &#34;bash&#34;, &#34;conf&#34;, &#34;R&#34;, &#34;zsh&#34; },
    dependencies = {
        {&#34;nvim-treesitter/nvim-treesitter-textobjects&#34;}, -- Syntax aware text-objects
        {
            &#34;nvim-treesitter/nvim-treesitter-context&#34;, -- Show code context
            opts = {
                -- 用于折叠显示前面的 function prototype
                enable = true, -- FIXME: true?
                mode = &#34;topline&#34;,
                line_numbers = false,
                multiwindow = false, -- Enable multiwindow support.
                max_lines = 5, -- How many lines the window should span. Values &lt;= 0 mean no limit.
                -- min_window_height = 0, -- Minimum editor window height to enable context. Values &lt;= 0 mean no limit.
                -- line_numbers = false,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                -- trim_scope = &#39;outer&#39;, -- Which context lines to discard if `max_lines` is exceeded. Choices: &#39;inner&#39;, &#39;outer&#39;
                -- mode = &#39;topline&#39;,  -- Line used to calculate context. Choices: &#39;cursor&#39;, &#39;topline&#39;
                -- -- Separator between context and content. Should be a single character string, like &#39;-&#39;.
                -- -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                -- separator = nil,
                -- zindex = 20, -- The Z-index of the context window
            }
        }
    },
    opts = {
        -- A list of parser names, or &#34;all&#34; (the five listed parsers should always be installed)
        ensure_installed =
        {
            &#34;bash&#34;,
            &#34;c&#34;,
            &#34;cpp&#34;,
            &#34;diff&#34;,
            &#34;html&#34;,
            &#34;javascript&#34;,
            &#34;json&#34;,
            &#34;lua&#34;,
            &#34;markdown&#34;,
            &#34;markdown_inline&#34;,
            &#34;python&#34;,
            &#34;query&#34;,
            &#34;regex&#34;,
            &#34;tsx&#34;,
            &#34;typescript&#34;,
            &#34;vim&#34;,
            &#34;yaml&#34;,
        },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don&#39;t have `tree-sitter` CLI installed locally
        auto_install = true,
        -- List of parsers to ignore installing (or &#34;all&#34;)
        ignore_install = {
            &#34;javascript&#34;,
            &#34;markdown&#34;,
            &#34;org&#34;,
        },
        highlight = {
            enable = true,
            -- disable = {&#34;csv&#34;, &#34;markdown&#34;}
            disable = {&#34;csv&#34;}
        },
        --FIXME: 可能导致 cpp indent 有点不对
        indent = { enable = true },
        textobjects = {select = {enable = true, lookahead = true}}
    },
    config = function(_, opts)
        require&#39;nvim-treesitter.configs&#39;.setup(opts)
    end
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-12-avante.nvim/  

