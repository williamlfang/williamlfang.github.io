# nvim 使用 cppinsights


`cppinsights` 通过展示编译器眼里的源代码，可以让我们更直观地看到编译器做了哪些预处理，从而更好的理解代码生成过程（非汇编）。

我们可以在 `nvim` 安装一个插件，通过快捷键即可看到转换后的代码了，尤其对于现代 `c&#43;&#43;` 提供的语法糖，可以更进一步的理解背后的语法。

&lt;!--more--&gt;

```lua
return {
	&#34;rossjaywill/insights.nvim&#34;,
	dependencies = {
		&#34;nvim-lua/plenary.nvim&#34;,
		&#34;nvim-telescope/telescope.nvim&#34;,
	},
	config = function()
		require(&#34;insights&#34;).setup{
            insights_bin = &#39;insights&#39;,
			async = true,
			use_default_keymaps = true, -- disable default keymaps, to be user defined
			use_libc = true, -- do not use libc&#43;&#43; headers
            vim.api.nvim_set_keymap(&#39;n&#39;, &#39;ci&#39;, &#39;:lua require(&#34;insights&#34;).run_current_buf()&lt;CR&gt;&#39;, { noremap = true, silent = true })
		}
	end,
}

-- local_only = false, -- only allow insights.nvim to invoke a local cppinsights binary
-- http_only = false,  -- only allow insights.nvim to make HTTP requests to cppinsights.io
--                     -- If both of these are not set (i.e. the default), then insights.nvim
--                     -- will use a local binary, if available, otherwise it will fallback to HTTP
--                     -- WARNING: You should think carefully about sending source code over HTTP -
--                     -- especially if you are working on a proprietary system.
-- async = true,
-- insights_bin = &#39;insights&#39;,
-- use_default_keymaps = true,
-- use_libc = true,
-- use_vsplit = true,
```

有两点需要说明一下：
- 如果没有在本地找到 `cppinsights`，则插件会向[网站](https://cppinsights.io/)请求，并把结果传送到本地
- 如果本地有安装二进制，需要 `llvm` 支持


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-16-nvim-%E4%BD%BF%E7%94%A8-cppinsights/  

