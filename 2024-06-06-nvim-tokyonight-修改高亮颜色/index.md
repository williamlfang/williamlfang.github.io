# nvim tokyonight 修改高亮颜色




&lt;!--more--&gt;

如果遇到在终端显示问题，可以修改高亮颜色: `~/.config/nvim/lua/plugins/tokyonight.lua`

```lua
on_highlights = function(hl, colors)
    hl.LineNr = {
        fg = &#34;#fffb7b&#34;,
    }
    hl.CursorLineNr = {
        fg = &#34;#709db2&#34;,
    }
end,
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-06-nvim-tokyonight-%E4%BF%AE%E6%94%B9%E9%AB%98%E4%BA%AE%E9%A2%9C%E8%89%B2/  

