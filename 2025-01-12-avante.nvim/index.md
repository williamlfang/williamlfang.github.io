# avante.nvim


前两天在 B 站看了一个视频， 介绍了目前国内 `AI` 领域做得非常不错的一家公司，也是量化界的领头羊-幻方。其中，谈到他们开发大模型 `deepseek` 已经拥有非常强劲的实力，能够满足大部分场景下的 `AGI` 使用，比如机器人、自动化代码生成器等。联想到之前我在网上看到 `avante.nvim` 这个插件可以为 `nvim` 带来 `AI` 辅助功能，当时由于国内还无法使用国外开发的大模型工具，所以就不了了之了。现在终于可以在国内合理合法的使用 `AI` 在 `nvim` 中辅助编程了。

&lt;!--more--&gt;

# 购买 API 服务

第一个步骤是需要购买 `API` 服务，然后获取 `key`，这样我们就可以在 `nvim` 中调用密钥发送请求了。

得到密钥后，需要设置环境变量

```bash
##=============================================================================[deepseek: openai]
## https://platform.deepseek.com/api_keys: sk-******************************a7c
export OPENAI_API_KEY=sk-******************************a7c
##=============================================================================
```

# avante.nvim

`avante` 提供了接入多个大模型应用 `API` 的配置，比如 `openai`、`claude`，而 `deepseek` 为了跟 `openai` 保持一致接口，也是采用了 `openai` 的方式。因此我们看到上面配置的密钥格式是 `openai` 的格式。

## 配置

这里我把自己使用的配置粘贴上来

```lua
return {
    &#34;yetone/avante.nvim&#34;,
    event = &#34;VeryLazy&#34;,
    lazy = true,
    version = false, -- set this if you want to always pull the latest change
    opts = {
        provider = &#34;openai&#34;,
        auto_suggestions_provider = &#34;openai&#34;, -- Since auto-suggestions are a high-frequency operation and therefore expensive,
                                              -- it is recommended to specify an inexpensive provider or even a free provider: copilot
        openai = {
            endpoint = &#34;https://api.deepseek.com/v1&#34;,
            model = &#34;deepseek-chat&#34;,
            timeout = 30000, -- Timeout in milliseconds
            temperature = 0,
            max_tokens = 4096,
            [&#34;local&#34;] = false,
        },
    },
    behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
    },
    mappings = {
        --- @class AvanteConflictMappings
        diff = {
            ours = &#34;co&#34;,
            theirs = &#34;ct&#34;,
            all_theirs = &#34;ca&#34;,
            both = &#34;cb&#34;,
            cursor = &#34;cc&#34;,
            next = &#34;]x&#34;,
            prev = &#34;[x&#34;,
        },
        suggestion = {
            accept = &#34;&lt;M-l&gt;&#34;,
            next = &#34;&lt;M-]&gt;&#34;,
            prev = &#34;&lt;M-[&gt;&#34;,
            dismiss = &#34;&lt;C-]&gt;&#34;,
        },
        jump = {
            next = &#34;]]&#34;,
            prev = &#34;[[&#34;,
        },
        submit = {
            normal = &#34;&lt;CR&gt;&#34;,
            insert = &#34;&lt;C-s&gt;&#34;,
        },
        -- NOTE: The following will be safely set by avante.nvim
        ask = &#34;&lt;leader&gt;aa&#34;,
        edit = &#34;&lt;leader&gt;ae&#34;,
        refresh = &#34;&lt;leader&gt;ar&#34;,
        focus = &#34;&lt;leader&gt;af&#34;,
        toggle = {
            default = &#34;&lt;leader&gt;at&#34;,
            debug = &#34;&lt;leader&gt;ad&#34;,
            hint = &#34;&lt;leader&gt;ah&#34;,
            suggestion = &#34;&lt;leader&gt;as&#34;,
            repomap = &#34;&lt;leader&gt;aR&#34;,
        },
        sidebar = {
            apply_all = &#34;A&#34;,
            apply_cursor = &#34;a&#34;,
            switch_windows = &#34;&lt;Tab&gt;&#34;,
            reverse_switch_windows = &#34;&lt;S-Tab&gt;&#34;,
            remove_file = &#34;d&#34;,
            add_file = &#34;@&#34;,
        },
        files = {
            add_current = &#34;&lt;leader&gt;ac&#34;, -- Add current buffer to selected files
        },
    },
    hints = { enabled = true },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = &#34;make&#34;,
    -- build = &#34;powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false&#34; -- for windows
    dependencies = {
        &#34;nvim-treesitter/nvim-treesitter&#34;,
        &#34;stevearc/dressing.nvim&#34;,
        &#34;nvim-lua/plenary.nvim&#34;,
        &#34;MunifTanjim/nui.nvim&#34;,
        {
            &#34;nvim-treesitter/nvim-treesitter&#34;,
            opts = {
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                ensure_installed = {
                    &#34;markdown&#34;,
                    &#34;markdown_inline&#34;,
                    &#34;bash&#34;,
                    &#34;python&#34;,
                    &#34;lua&#34;,
                    &#34;javascript&#34;,
                    &#34;typescript&#34;,
                    &#34;html&#34;,
                    &#34;css&#34;,
                },
            },
        },
        --- The below dependencies are optional,
        &#34;nvim-tree/nvim-web-devicons&#34;, -- or echasnovski/mini.icons
        &#34;zbirenbaum/copilot.lua&#34;, -- for providers=&#39;copilot&#39;
        {
            -- support for image pasting
            &#34;HakonHarnes/img-clip.nvim&#34;,
            event = &#34;VeryLazy&#34;,
            opts = {
                -- recommended settings
                default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        -- {
        --     -- Make sure to set this up properly if you have lazy=true
        --     &#39;MeanderingProgrammer/render-markdown.nvim&#39;,
        --     -- branch = &#34;main&#34;,
        --     -- commit = &#34;82184c4a3c3580a7a859b2cb7e58f16c10fd29ef&#34;,
        --     -- opts = {
        --     --     file_types = { &#34;markdown&#34;, &#34;Avante&#34; },
        --     -- },
        --     -- ft = { &#34;markdown&#34;, &#34;Avante&#34; },
        --     -- highlight = {
        --     --     enabled = true,
        --     --     theme = &#34;github&#34;,  -- or &#34;monokai&#34;, &#34;onedark&#34;, etc.
        --     --     background = true,
        --     -- },
        --     -- code_blocks = {
        --     --     highlight = true,
        --     --     theme = &#34;github&#34;,  -- Match your colorscheme
        --     -- },
        -- },
    },
}
```

由于我使用的是 `markview` 这款插件来渲染 `markdown`，因此就没有使用上面注释部分中的 `render-markdown`。

```lua
return {
    &#34;OXY2DEV/markview.nvim&#34;,
    enabled = true,
    lazy = true,      -- Recommended
    event = &#34;BufRead&#34;,
    ft = {&#34;markdown&#34;}, -- If you decide to lazy-load anyway
    dependencies = {
        &#34;nvim-treesitter/nvim-treesitter&#34;,
        &#34;nvim-tree/nvim-web-devicons&#34;
    },
    config = function()
        local presets = require(&#34;markview.presets&#34;);
        require(&#34;markview&#34;).setup({
            filetypes = { &#34;markdown&#34;, &#34;quarto&#34;, &#34;rmd&#34; },
            headings = presets.headings.marker,
            checkboxes = presets.checkboxes.nerd,
            -- Initial plugin state,
            -- true = show preview
            -- falss = don&#39;t show preview
            initial_state = true,
        })
    end,
}
```

## 操作

我一开始犯了一个迷糊：`avante` 写的是使用 `&lt;leader&gt;aa` 启动对话。我以为这里的 `leader` 就是我自己设置的 `leader` 键位，即 `;`。但是后来发现 `avante` 配置的 `leader` 其实对应的应该是 `Space` 空格键，所以如果启动对话，需要敲击的键位是：`&lt;Space&gt;aa`。

## 效果

最近在测试升级 `glibc`，其中有一个测试条件需要过滤：针对 `nss` 的一个条件判断，我们不需要添加测试，否则 `glibc` 无法通过编译。其中使用的语法就是 `bash` 的正则表达式，但是混合了特殊符号。即使对于一个非常熟悉 `bash` 语法的程序员，在处理正则表达式时也常常感到心累，大概是因为其复杂的语法。

比如这里（代码位于 `glibc-2.30/scripts/test-installation.pl`）

```bash
if ($name ne &#34;nss_ldap&#34; &amp;&amp; $name ne &#34;db1&#34;
    &amp;&amp; $name ne &#34;thread_db&#34;
    &amp;&amp; $name ne &#34;nss_test1&#34; &amp;&amp; $name ne &#34;libgcc_s&#34;) {
    $link_libs .= &#34; -l$name&#34;;
    $versions{$name} = $version;
}
```

我们想使用 `sed` 添加一个条件， `&amp;&amp; $name ne &#34;nss_test2&#34;`。一开始我尝试自己去写正则表达式，但是两次都失败了，得不到想要的结果。于是想到让 `AI` 试试看，便把上面那段代码粘贴到一个临时的脚本文件，然后简单描述了我需要得到的效果，至于怎么处理，就交给 `AI` 了。

```bash
use `sed` to add one more condition: $name ne &#34;nss_test2&#34;
```

让我十分震惊的是，`AI` 竟然很快就给出了答案，而且还详细说明分析的思路，并且把运行的结果也展示出来。

![sed](./sed.png &#34;using sed from AI&#34;)

{{&lt; admonition &gt;}}

- Datetime: 2025-01-12 21:24:59

- Model: openai/deepseek-chat

- Selected files:
  - test.sh

- Selected code:

```bash
        &amp;&amp; $name ne &#34;nss_test1&#34; &amp;&amp; $name ne &#34;libgcc_s&#34;) {
```

&gt; use `sed` to add one more condition: $name ne &#34;nss_test2&#34;

I&#39;ll provide a sed command that will add the new condition while preserving the existing formatting. Here&#39;s the sed command to run:

```bash;h
sed -i &#39;/&amp;&amp; $name ne &#34;nss_test1&#34; &amp;&amp; $name ne &#34;libgcc_s&#34;/s/&amp;&amp; $name ne &#34;libgcc_s&#34;/\&amp;\&amp; $name ne &#34;nss_test2&#34; \&amp;\&amp; $name ne &#34;libgcc_s&#34;/&#39; test.sh
```

This command:
1. Looks for the specific line containing both &#34;nss_test1&#34; and &#34;libgcc_s&#34; conditions
2. Replaces just the &#34;libgcc_s&#34; condition part with &#34;nss_test2&#34; followed by the original &#34;libgcc_s&#34; condition
3. Maintains proper spacing and formatting
4. Uses -i flag to edit the file in-place

After running this command, the line will become:
```bash
        &amp;&amp; $name ne &#34;nss_test1&#34; &amp;&amp; $name ne &#34;nss_test2&#34; &amp;&amp; $name ne &#34;libgcc_s&#34;) {
```

{{&lt; /admonition &gt;}}

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

