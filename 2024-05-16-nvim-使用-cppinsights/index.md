# nvim 使用 cppinsights


`cppinsights` 通过展示编译器眼里的源代码，可以让我们更直观地看到编译器做了哪些预处理，从而更好的理解代码生成过程（非汇编）。

我们可以在 `nvim` 安装一个插件，通过快捷键即可看到转换后的代码了，尤其对于现代 `c&#43;&#43;` 提供的语法糖，可以更进一步的理解背后的语法。

&lt;!--more--&gt;

## 关于 cppinsights

这里引述开发者原文：

&gt; 2017年，我开始研究我们在C&#43;&#43;11、C&#43;&#43;14和C&#43;&#43;17中得到的一些新特性。像lambda表达式、基于范围的for循环和结构化绑定这样令人惊奇的事物。我在一次演讲中将它们整合在一起。你可以在网上找到演讲幻灯片和视频。
&gt;
&gt; 然而，所有的研究以及我的一些培训和教学工作让我开始思考，如果我们能够像编译器一样“看”代码会怎样。当然，至少对于Clang来说，有一个AST转储功能。我们可以使用像Compiler Explorer这样的工具来查看编译器从C&#43;&#43;代码片段生成的代码。然而，我们看到的是汇编语言。无论是AST还是Compiler Explorer的输出，都不是我用编写代码时使用的语言。因此，我对这种输出并不熟悉。此外，在教授学生C&#43;&#43;时，展示一个AST并解释说这就是全部，对我来说并不十分令人满意。
&gt;
&gt; 我开始编写一个基于Clang的工具，它可以将基于范围的for循环转换为编译器内部版本。之后，我对结构化绑定和lambda表达式也做了同样的处理。最终，我完成的工作比最初计划的要多得多。它展示了操作符被调用的位置，以及编译器进行类型转换的地方。C&#43;&#43; Insights可以推断出auto或decltype背后的类型。目标是生成可编译的代码。然而，在所有地方都实现这一点是不可能的。
&gt;
&gt; 例如，你可以看到lambda表达式、基于范围的for循环或auto的转换。当然，你也可以转换任何其他C&#43;&#43;代码片段。

## 安装 insight.nvim  插件

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

## 安装 llvm

```bash

```

## 安装 cppinsights

```bash

```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-16-nvim-%E4%BD%BF%E7%94%A8-cppinsights/  

