# nvim 添加自定义代码段 snippets


我们在写代码时，会经常使用一些普遍的写法，比如一个 `for` 循环；或者是一些常用的代码段，比如 `datetime` 直接输入当前的日期。

```c&#43;&#43;
for (int i = 0; i &lt; n; &#43;&#43;i)
{
    ...
}
```

&lt;!--more--&gt;

# luasnip.lua

我们需要添加 `luasnip` 这个插件，里面定义了常用的代码段

```lua
return {
	&#34;L3MON4D3/LuaSnip&#34;,
	-- follow latest release.
	version = &#34;v2.*&#34;, -- Replace &lt;CurrentMajor&gt; by the latest released major (first number of latest release)
	build = &#34;make install_jsregexp&#34;,
    lazy = true,
    event = &#34;InsertEnter&#34;,
    dependencies = {
        &#34;rafamadriz/friendly-snippets&#34;, -- this is good!
    },
    config = function ()
        -- for friendly snippets
        require(&#34;luasnip.loaders.from_vscode&#34;).lazy_load()
        -- for custom snippets
        -- ref: &lt;https://github.com/jmbuhr/quarto-nvim-kickstarter/tree/95c56fb29e0f7222dad0b1a432028bd610ab3dcb&gt;
        require(&#34;luasnip.loaders.from_vscode&#34;).lazy_load({ paths = { vim.fn.stdpath(&#34;config&#34;) .. &#34;/snips&#34; } })
    end
}
```

我把用户自定义的代码段放在 `~/.config/nvim/snips/` 这个子目录。

`luasnip.lua` 里面提供了一些常用的函数可以用户自定义的 `json` 文件直接调用，`~/.config/nvim/lazy/LuaSnip/lua/luasnip/util/_builtin_vars.lua`。比如，

```lua
-- DateTime Related
function lazy_vars.CURRENT_YEAR()
	return os.date(&#34;%Y&#34;)
end

function lazy_vars.CURRENT_YEAR_SHORT()
	return os.date(&#34;%y&#34;)
end

function lazy_vars.CURRENT_MONTH()
	return os.date(&#34;%m&#34;)
end

function lazy_vars.CURRENT_MONTH_NAME()
	return os.date(&#34;%B&#34;)
end

function lazy_vars.CURRENT_MONTH_NAME_SHORT()
	return os.date(&#34;%b&#34;)
end

function lazy_vars.CURRENT_DATE()
	return os.date(&#34;%d&#34;)
end

function lazy_vars.CURRENT_DAY_NAME()
	return os.date(&#34;%A&#34;)
end

function lazy_vars.CURRENT_DAY_NAME_SHORT()
	return os.date(&#34;%a&#34;)
end

function lazy_vars.CURRENT_HOUR()
	return os.date(&#34;%H&#34;)
end

function lazy_vars.CURRENT_MINUTE()
	return os.date(&#34;%M&#34;)
end

function lazy_vars.CURRENT_SECOND()
	return os.date(&#34;%S&#34;)
end

function lazy_vars.CURRENT_SECONDS_UNIX()
	return tostring(os.time())
end

function lazy_vars.CURRENT_TIMEZONE_OFFSET()
	return time_util
		.get_timezone_offset(os.time())
		:gsub(&#34;([&#43;-])(%d%d)(%d%d)$&#34;, &#34;%1%2:%3&#34;)
end
```


# 用户自定义代码段

在以上配置，我把代码段放在 `~/.config/nvim/snips/`。里面的目录结构如下

```bash
tree -L 2
.
├── package.json
└── snippets
    ├── css.json
    ├── global.json
    ├── json.json
    ├── markdown.json
    ├── org.json
    ├── quarto.json
    └── tex.json
```

## package.json

在这个配置文件，我们需要针对不同的文件类型，配置相应的代码段。其中，`global.json` 是所用文件通用。

```json
{
    &#34;name&#34;: &#34;snips&#34;,
    &#34;engines&#34;: {
        &#34;vscode&#34;: &#34;^1.11.0&#34;
    },
    &#34;contributes&#34;: {
        &#34;snippets&#34;: [
            {
                &#34;language&#34;: [
                    &#34;markdown&#34;,
                    &#34;tex&#34;,
                    &#34;html&#34;,
                    &#34;quarto&#34;,
                    &#34;org&#34;
                ],
                &#34;path&#34;: &#34;./snippets/global.json&#34;
            },
            {
                &#34;language&#34;: &#34;org&#34;,
                &#34;path&#34;: &#34;./snippets/org.json&#34;
            },
            {
                &#34;language&#34;: &#34;quarto&#34;,
                &#34;path&#34;: &#34;./snippets/quarto.json&#34;
            },
            {
                &#34;language&#34;: &#34;markdown&#34;,
                &#34;path&#34;: &#34;./snippets/markdown.json&#34;
            },
            {
                &#34;language&#34;: [
                    &#34;json&#34;
                ],
                &#34;path&#34;: &#34;./snippets/json.json&#34;
            },
            {
                &#34;language&#34;: [&#34;css&#34;, &#34;scss&#34;],
                &#34;path&#34;: &#34;./snippets/css.json&#34;
            },
            {
                &#34;language&#34;: &#34;tex&#34;,
                &#34;path&#34;: &#34;./snippets/tex.json&#34;
            }
    ]
    }
}
```

## org.json

比如，我们需要在 `org` 的文件快速添加 `SCHEDULED` 的日期，就需要编辑文件 `~/.config/nvim.20250115.ok/snips/snippets/org.json`


```json
{
    &#34;codeblock&#34;: {
        &#34;prefix&#34;: [&#34;codeblock&#34;, &#34;begin_src&#34;],
        &#34;body&#34;: [&#34;#&#43;BEGIN_SRC ${1:bash}&#34;, &#34;${2}&#34;, &#34;#&#43;END_SRC&#34;]
    },

    &#34;schedule&#34;: {
        &#34;prefix&#34;: [&#34;sched&#34;],
        &#34;body&#34;: [
            &#34;SCHEDULED: &lt;${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DATE} ${CURRENT_DAY_NAME_SHORT}&gt;&#34;
        ]
    }
}
```

如此以来，我只需要在 `org` 类型的文件里面输入 `sched` 就可以快速插入当前 `TODO` 的 `SCHEDULED`。

![sched](./sched.png &#34;SCHEDULED for org&#34;)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-02-09-nvim-%E6%B7%BB%E5%8A%A0%E8%87%AA%E5%AE%9A%E4%B9%89%E4%BB%A3%E7%A0%81%E6%AE%B5-snippets/  

