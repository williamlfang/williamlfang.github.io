# nvim treesitter 与 csv.nvim 冲突


需要把 `nvim-treesitter` 的 `csv` 语法关闭

```lua
-- List of parsers to ignore installing (or &#34;all&#34;)
ignore_install = {
    &#34;javascript&#34;,
    &#34;markdown&#34;,
    &#34;org&#34;,
    &#34;csv&#34;, -- we do not use tree-sitter csv since csv.lua would be broken
},
highlight = {
    enable = true,
    -- disable = {&#34;csv&#34;, &#34;markdown&#34;}
    disable = {&#34;csv&#34;}
},
```

&lt;!--more--&gt;


# nvim-treesitter

```lua
return  {
    &#34;nvim-treesitter/nvim-treesitter&#34;,
    build = &#34;:TSUpdate&#34;,
    lazy = true,
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
            &#34;csv&#34;, -- we do not use tree-sitter csv since csv.lua would be broken
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

# csv.nvim

```lua
return {
    &#39;cameron-wags/rainbow_csv.nvim&#39;,
    config = true,
    -- event = &#34;VeryLazy&#34;,
    -- lazy = true,
    event = &#34;BufRead&#34;,
    ft = {
        &#39;csv&#39;,
        &#39;tsv&#39;,
        &#39;csv_semicolon&#39;,
        &#39;csv_whitespace&#39;,
        &#39;csv_pipe&#39;,
        &#39;rfc_csv&#39;,
        &#39;rfc_semicolon&#39;
    },
    cmd = {
        &#39;RainbowDelim&#39;,
        &#39;RainbowDelimSimple&#39;,
        &#39;RainbowDelimQuoted&#39;,
        &#39;RainbowMultiDelim&#39;
    },
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-17-nvim-treesitter-%E4%B8%8E-csv.nvim-%E5%86%B2%E7%AA%81/  

