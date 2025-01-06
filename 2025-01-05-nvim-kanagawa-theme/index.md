# nvim kanagawa theme



`kanagawa` 一款柔和色调的主题，相比 `tokyo.night` 没有那么的刺眼。主要特别注意的是，这款插件采用了 `jit` 编译技术，一旦修改配置，还需要执行 `KanagawaCompile` 才能生效。

&lt;!--more--&gt;

# kanagawa

```lua
-- Kanagawa comes in three variants:
-- 1.wave the default heart-warming theme,
-- 2.dragon for those late-night sessions
-- 3.lotus for when you&#39;re out in the open.
return {
    &#34;rebelot/kanagawa.nvim&#34;,
    config = function ()
        require(&#39;kanagawa&#39;).setup({
            -- If you enable compilation, make sure to run :KanagawaCompile command every time you make changes to your config.
            compile = true,             -- enable compiling the colorscheme
            undercurl = true,            -- enable undercurls
            commentStyle = { italic = true, bold = false},
            functionStyle = { bold = true },
            keywordStyle = { italic = true},
            statementStyle = { bold = true },
            typeStyle = {italic = true, bold = false},
            transparent = true,         -- do not set background color
            dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
            terminalColors = true,       -- define vim.g.terminal_color_{0,17}
            globalStatus = true,       -- adjust window separators highlight for laststatus=3
            colors = {                   -- add/modify theme and palette colors
                palette = {},
                theme = {
                    wave = {},
                    lotus = {},
                    dragon = {},
                    all = {
                        ui = {
                            bg_gutter = &#34;none&#34;,
                            bg_p1 = &#39;none&#39;,
                        },
                    }
                },
            },
            overrides = function(colors) -- add/modify highlights
                -- eg: ~/.config/nvim/lazy/kanagawa.nvim/lua/kanagawa/highlights/editor.lua
                local theme = colors.theme
                local palette = colors.palette
                return {
                    -- CursorLineNr = { fg = theme.diag.warning, bg = theme.ui.bg_gutter, bold = true },
                    CursorLineNr = { fg = &#34;#709db2&#34;, bg = theme.ui.bg_gutter, bold = false },
                    -- CursorLineNr = { fg = &#34;#545c7e&#34;, bg = theme.ui.bg_gutter, bold = true },

                    -- Visual		Visual mode selection.
                    -- Visual = { bg = theme.ui.bg_visual },
                    -- Visual = { bg = palette.waveBlue2 },
                    Visual = { bg = &#34;#2D4F67&#34; },
                    -- VisualNOS	Visual mode selection when vim is &#34;Not Owning the Selection&#34;.
                    VisualNOS = { link = &#34;Visual&#34; },

                    NormalFloat = { bg = &#34;none&#34; },
                    FloatBorder = { bg = &#34;none&#34; },
                    FloatTitle = { bg = &#34;none&#34; },

                    -- Save an hlgroup with dark background and dimmed foreground
                    -- so that you can use it where your still want darker windows.
                    -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
                    NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

                    -- Popular plugins that open floats will link to NormalFloat by default;
                    -- set their background accordingly if you wish to keep them dark and borderless
                    LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                    MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

                    -- Search = { bg = colors.surimiOrange },
                    -- Search = { bg = &#39;#FFA066&#39; },
                }
            end,
            theme = &#34;wave&#34;,              -- Load &#34;wave&#34; theme when &#39;background&#39; option is not set
            background = {               -- map the value of &#39;background&#39; option to a theme
                dark = &#34;dragon&#34;,           -- try &#34;dragon&#34; !
                light = &#34;lotus&#34;
            },
        })
    end
}
```

# 修改 lualine

打开 `~/.config/nvim/lazy/kanagawa.nvim/lua/lualine/themes/kanagawa.lua`

```lua
local theme = require(&#34;kanagawa.colors&#34;).setup().theme

local kanagawa = {}

kanagawa.normal = {
  a = { bg = theme.syn.fun, fg = theme.ui.bg_m3 },
  b = { bg = theme.diff.change, fg = theme.syn.fun },
  -- c = { bg = theme.ui.bg_p1, fg = theme.ui.fg },
  c = { bg = nil, fg = &#34;#938AA9&#34; },
}

kanagawa.insert = {
  a = { bg = theme.diag.ok, fg = theme.ui.bg },
  b = { bg = theme.ui.bg, fg = theme.diag.ok },
}

kanagawa.command = {
  a = { bg = theme.syn.operator, fg = theme.ui.bg },
  b = { bg = theme.ui.bg, fg = theme.syn.operator },
}

kanagawa.visual = {
  a = { bg = theme.syn.keyword, fg = theme.ui.bg },
  b = { bg = theme.ui.bg, fg = theme.syn.keyword },
}

kanagawa.replace = {
  a = { bg = theme.syn.constant, fg = theme.ui.bg },
  b = { bg = theme.ui.bg, fg = theme.syn.constant },
}

kanagawa.inactive = {
  a = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
  b = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim, gui = &#34;bold&#34; },
  c = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
}

if vim.g.kanagawa_lualine_bold then
  for _, mode in pairs(kanagawa) do
    mode.a.gui = &#34;bold&#34;
  end
end

return kanagawa
```

# tmux 颜色问题

`tmux` 可能出现显示颜色问题，需要修改

## alacritty

```toml
## ----------------------------------------------------------------------------env
[env]
TERM=&#39;xterm-256color&#39;
# TERM=&#39;Alacritty&#39;
```

## tmux

```bash
set -g default-terminal &#34;screen-256color&#34;
set-option -sa terminal-overrides &#39;,screen-256color:Tc&#39;
```

ref: https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-05-nvim-kanagawa-theme/  

