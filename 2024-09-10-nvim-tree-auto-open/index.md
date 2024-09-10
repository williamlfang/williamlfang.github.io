# nvim tree auto open


主要在 `~/.config/nvim/lua/plugins/nvim-tree.lua` 添加配置

```lua
--auto open from terminal
if vim.fn.argc(-1) == 0 then
    vim.cmd(&#39;NvimTreeOpen&#39;)
end
```

&lt;!--more--&gt;

```lua
-- 查看默认配置
-- :help vim-tree-mappings-default
local function my_on_attach(bufnr)
    local api = require(&#39;nvim-tree.api&#39;)

    local function opts(desc)
        return { desc = &#39;nvim-tree: &#39; .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    -- your removals and mappings go here
    -- copy default mappings here from defaults in next section
    vim.keymap.set(&#39;n&#39;, &#39;&lt;C-]&gt;&#39;, api.tree.change_root_to_node, opts(&#39;CD&#39;))
    vim.keymap.set(&#39;n&#39;, &#39;&lt;C-e&gt;&#39;, api.node.open.replace_tree_buffer, opts(&#39;Open: In Place&#39;))
    ---
    -- OR use all default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- remove a default
    vim.keymap.del(&#39;n&#39;, &#39;&lt;C-]&gt;&#39;, { buffer = bufnr })

    -- override a default
    vim.keymap.set(&#39;n&#39;, &#39;r&#39;, api.tree.reload, opts(&#39;Refresh&#39;))
    vim.keymap.set(&#39;n&#39;, &#39;u&#39;, api.tree.change_root_to_parent, opts(&#39;Up&#39;))
    vim.keymap.set(&#39;n&#39;, &#39;x&#39;, api.node.navigate.parent_close, opts(&#39;Close Directory&#39;))
    vim.keymap.set(&#39;n&#39;, &#39;&lt;CR&gt;&#39;, api.node.open.no_window_picker, opts(&#39;Open: No Window Picker&#39;))
    vim.keymap.set(&#39;n&#39;, &#39;o&#39;, api.node.open.no_window_picker, opts(&#39;Open: No Window Picker&#39;))
    vim.keymap.set(&#39;n&#39;, &#39;p&#39;, api.node.open.preview, opts(&#39;Open  Preview&#39;))

    -- add your mappings
    vim.keymap.set(&#39;n&#39;, &#39;?&#39;, api.tree.toggle_help, opts(&#39;Help&#39;))
    ---
end

return {
    &#34;nvim-tree/nvim-tree.lua&#34;,
    -- version = &#34;*&#34;,
    -- version = &#34;v10.16.0&#34;,
    branch = &#34;master&#34;,
    -- commit= &#34;f1b3e6a7eb92da492bd693257367d9256839ed3d&#34;,
    commit= &#34;fbee8a69a46f558d29ab84e96301425b0501c668&#34;,    -- ok:
    -- commit= &#34;d9cb432d2c8d8fa9267ddbd7535d76fe4df89360&#34;, --broken
    -- commit= &#34;e9ac136a3ab996aa8e4253253521dcf2cb66b81b&#34;, -- broken
    dependencies = { &#34;nvim-tree/nvim-web-devicons&#34; },
    event = &#34;VeryLazy&#34;,
    -- hijack_directories = {
    --     enable = true,
    --     auto_open = false,
    --     },
    config = function()
        require(&#34;nvim-tree&#34;).setup {
            view = {
                width = 35, -- pt
                side = &#34;left&#34;,
                -- bindings = {
                --     { key = {&#34;&lt;CR&gt;&#34;, &#34;o&#34; }, action = &#34;edit&#34;, mode = &#34;n&#34;},
                --     { key = &#34;p&#34;, action = &#34;print_path&#34;, action_cb = print_node_path },
                -- }
            },
            -- renderer = {
            --     group_empty = true,
            -- },
            -- filters = {
            --     dotfiles = true,
            -- },
            ui = {
                confirm = {
                    remove = true,
                    trash = true,
                },
            },
            actions = {
                open_file = {
                    resize_window = false,
                },
            },
            git = {
                enable = true,
                ignore = false,
            },
            on_attach = my_on_attach,
        }
        --auto open from terminal
        if vim.fn.argc(-1) == 0 then
            vim.cmd(&#39;NvimTreeOpen&#39;)
        end
    end
}
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-09-10-nvim-tree-auto-open/  

