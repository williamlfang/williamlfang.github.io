# nvim cmp



使用 `nvim-cmp` 进行补全。

&lt;!--more--&gt;

```lua
local M = {
	&#34;hrsh7th/nvim-cmp&#34;,
	dependencies = {
		&#34;hrsh7th/cmp-nvim-lsp&#34;,
		&#34;hrsh7th/cmp-nvim-lua&#34;,
		&#34;hrsh7th/cmp-buffer&#34;,
		&#34;hrsh7th/cmp-path&#34;,
		&#34;hrsh7th/cmp-cmdline&#34;,
		&#34;saadparwaiz1/cmp_luasnip&#34;,
		&#34;L3MON4D3/LuaSnip&#34;,
	},
    enabled = true,
    event = &#34;InsertEnter&#34;,
}

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match(&#34;%s&#34;) == nil
end

local cmp = require&#39;cmp&#39;
local luasnip = require&#39;luasnip&#39;

M.config = function()
	local cmp = require(&#34;cmp&#34;)
	vim.opt.completeopt = { &#34;menu&#34;, &#34;menuone&#34;, &#34;noselect&#34; }

	local kind_icons = {
		-- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#basic-customisations
		Text = &#34; &#34;,
		Method = &#34;󰆧&#34;,
		Function = &#34;ƒ &#34;,
		Constructor = &#34; &#34;,
		Field = &#34;󰜢 &#34;,
		Variable = &#34; &#34;,
		Constant = &#34; &#34;,
		Class = &#34; &#34;,
		Interface = &#34;󰜰 &#34;,
		Struct = &#34; &#34;,
		Enum = &#34;了 &#34;,
		EnumMember = &#34; &#34;,
		Module = &#34;&#34;,
		Property = &#34; &#34;,
		Unit = &#34; &#34;,
		Value = &#34;󰎠 &#34;,
		Keyword = &#34;󰌆 &#34;,
		Snippet = &#34; &#34;,
		File = &#34; &#34;,
		Folder = &#34; &#34;,
		Color = &#34; &#34;,
	}

	cmp.setup({
		snippet = {
			expand = function(args)
				require(&#34;luasnip&#34;).lsp_expand(args.body) -- For `luasnip` users.
			end,
		},
		window = {
			-- completion = cmp.config.window.bordered(),
			-- documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			[&#34;&lt;C-b&gt;&#34;] = cmp.mapping.scroll_docs(-4),
			[&#34;&lt;C-f&gt;&#34;] = cmp.mapping.scroll_docs(4),
			[&#34;&lt;C-Space&gt;&#34;] = cmp.mapping.complete(),
			[&#34;&lt;C-e&gt;&#34;] = cmp.mapping.abort(),
			[&#34;&lt;CR&gt;&#34;] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            [&#34;&lt;Tab&gt;&#34;] = cmp.mapping(
                function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { &#34;i&#34;, &#34;s&#34; }),
            [&#34;&lt;S-Tab&gt;&#34;] = cmp.mapping(
                function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { &#34;i&#34;, &#34;s&#34; }),
		}),
		sources = cmp.config.sources(
            {
                { name = &#34;nvim_lsp&#34; },
                { name = &#34;nvim_lua&#34; },
                { name = &#34;luasnip&#34; }, -- For luasnip users.
		    },
            {
                {
                    name = &#34;buffer&#34;,
                    option = {
                        -- Options go into this table
                        -- get_bufnrs = function()
                        --     -- return vim.api.nvim_list_bufs()
                        --     local buf = vim.api.nvim_get_current_buf()
                        --     local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                        --     if byte_size &gt; 1024 * 1024 then -- 1 Megabyte max
                        --         return {}
                        --     end
                        --     return { buf }
                        -- end
                        get_bufnrs = function()
                            return vim.api.nvim_list_bufs()
                        end
                    },
                },
                { name = &#34;path&#34; },
		    },
            {
                { name = &#34;neorg&#34; },
		    },
            {
                {
                    name = &#39;tmux&#39;,
                    option = {
                        -- Source from all panes in session instead of adjacent panes
                        all_panes = false,

                        -- Completion popup label
                        label = &#39;[tmux]&#39;,

                        -- Trigger character
                        trigger_characters = { &#39;.&#39; },

                        -- Specify trigger characters for filetype(s)
                        -- { filetype = { &#39;.&#39; } }
                        trigger_characters_ft = {},

                        -- Keyword patch mattern
                        keyword_pattern = [[\w\&#43;]],

                        -- Capture full pane history
                        -- `false`: show completion suggestion from text in the visible pane (default)
                        -- `true`: show completion suggestion from text starting from the beginning of the pane history.
                        --         This works by passing `-S -` flag to `tmux capture-pane` command. See `man tmux` for details.
                        capture_history = false,
                    }
                },
            }
        ),

		formatting = {
			format = function(entry, vim_item)
				-- Kind icons
				vim_item.kind = string.format(&#34;%s %s&#34;, kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
				-- Source
				vim_item.menu = ({
					buffer = &#34;[Buffer]&#34;,
					nvim_lsp = &#34;[LSP]&#34;,
					luasnip = &#34;[LuaSnip]&#34;,
					nvim_lua = &#34;[NvimAPI]&#34;,
					path = &#34;[Path]&#34;,
				})[entry.source.name]
				return vim_item
			end,
		},
	})

    -- Set configuration for specific filetype.
    cmp.setup.filetype(&#39;gitcommit&#39;, {
        sources = cmp.config.sources({
            { name = &#39;cmp_git&#39; }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
            {
                name = &#39;buffer&#39;,
            },
        })
    })

    -- Use buffer source for `/` (if you enabled `native_menu`, this won&#39;t work anymore).
    cmp.setup.cmdline(&#39;/&#39;, {
        sources = {
            {
                name = &#39;buffer&#39;,
            }
        }
    })

    -- Use cmdline &amp; path source for &#39;:&#39; (if you enabled `native_menu`, this won&#39;t work anymore).
	cmp.setup.cmdline(&#34;:&#34;, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = &#34;path&#34; },
		}, {
			{ name = &#34;cmdline&#34; },
		}),
	})
end

return M
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-02-nvim-cmp/  

