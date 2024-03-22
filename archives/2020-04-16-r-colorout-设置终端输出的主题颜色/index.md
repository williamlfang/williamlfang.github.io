# R:colorout 设置终端输出的主题颜色


项目地址：[colorout](https://github.com/jalvesaq/colorout)



# 安装

在终端运行

```bash
cd ~/Documents
git clone https://github.com/jalvesaq/colorout.git
R CMD INSTALL colorout
```
&lt;!--more--&gt;

# 配置方案

## 转化函数 to_ansi

```R
#&#39; Helper for generating ansi color codes with hex color codes.
#&#39;
#&#39; After generating ansi color codes, feed input to `colorout::setOutputColors`.
#&#39;
#&#39; @param fg Foreground color in hex format (ie &#39;#000000&#39;). Leave blank for default.
#&#39; @param bg Background color in hex format (ie &#39;#000000&#39;). Leave blank for default.
#&#39; @param fo Formatting (see details)
#&#39;
#&#39; @details
#&#39; Value	Formating
#&#39; 0	No formating
#&#39; 1	Bold or bright
#&#39; 2	Faint
#&#39; 3	Italic or inverse
#&#39; 4	Underline
#&#39; 5	Blink slowly
#&#39; 6	Blink quickly
#&#39; 7	Invert

to_ansi &lt;- function(col, fg = &#39;&#39;, bg = &#39;&#39;, fo = &#39;&#39;) {

  escape &lt;- &#39;\\x1b[&#39;

  if (fg != &#39;&#39;) fg &lt;- {
    rgb_fg &lt;- col2rgb(fg)
    paste0(&#34;38;2;&#34;, rgb_fg[1], &#34;;&#34;, rgb_fg[2], &#34;;&#34;, rgb_fg[3])
  }
  if (bg != &#39;&#39;) bg &lt;- {
    rgb_bg &lt;- col2rgb(bg)
    paste0(&#34;;48;2;&#34;, rgb_bg[1], &#34;;&#34;, rgb_bg[2], &#34;;&#34;, rgb_bg[3])
  }
  fo &lt;- if (fo != &#39;&#39;) paste0(&#39;;&#39;, fo)

  # Use `cat`, not `paste0`, for correctly printing escape char &#39;\x1b[&#39;
  cat(col, &#39;: &#39;, escape, fg, bg, fo, &#39;m&#39;, &#39;\n&#39;, sep = &#39;&#39;)
}
```

## 主题配置

```R
# Fill in color names, foreground colors, background colors and formatting (ie bold/italic). For default, leave it blank.
theme &lt;- list(
  colors     = c(&#39;white&#39;,   &#39;black&#39;,   &#39;snow&#39;,    &#39;turquoise&#39;, &#39;dark_red&#39;, &#39;dark_green&#39;, &#39;yellow&#39;,  &#39;green&#39;,   &#39;red&#39;,     &#39;yellow_bold&#39;),
  foreground = c(&#34;#ECEFF4&#34;, &#34;#4C566A&#34;, &#39;#D8DEE9&#39;, &#39;#88C0D0&#39;,   &#34;#B48EAD&#34;,  &#34;#8FBCBB&#34;,    &#34;#EBCB8B&#34;, &#34;#A3BE8C&#34;, &#34;#BF616A&#34;, &#34;#EBCB8B&#34;),
  background = c(&#34;&#34;,        &#34;&#34;,        &#34;&#34;,        &#34;&#34;,          &#34;&#34;,         &#34;&#34;,           &#34;&#34;,        &#34;&#34;,        &#34;&#34;,        &#34;&#34;),
  formatting = c(&#34;&#34;,        &#34;&#34;,        &#34;&#34;,        &#34;&#34;,          &#34;&#34;,         &#34;&#34;,           &#34;&#34;,        &#34;&#34;,        &#34;&#34;,        1)
)

# - Manually copy &amp; paste color codes (in character type) to `colorout::setOutputColors`. It&#39;s okay because you only set it once-and-for-all. Otherwise, you can assign the colors to variables and remove them after calling `colorout::setOutputColors`
# - or assign them to variables AND make sure to remove them after calling `colorout::setOutputColors` because you don&#39;t want them to contaminate your environments.
suppressMessages( {
    sink( &#34;/tmp/null&#34; )
    invisible( mapply(to_ansi, theme[[1]], theme[[2]], theme[[3]], theme[[4]]) )
    # capture.output(
    #                invisible( mapply(to_ansi, theme[[1]], theme[[2]], theme[[3]], theme[[4]]) ),
    #                file=&#39;NUL&#39;
    #                )
    sink()
} ))

# white:       \x1b[38;2;236;239;244m
# black:       \x1b[38;2;76;86;106m
# snow:        \x1b[38;2;216;222;233m
# turquoise:   \x1b[38;2;136;192;208m
# dark_red:    \x1b[38;2;180;142;173m
# dark_green:  \x1b[38;2;143;188;187m
# yellow:      \x1b[38;2;235;203;139m
# green:       \x1b[38;2;163;190;140m
# red:         \x1b[38;2;191;97;106m
# yellow_bold: \x1b[38;2;235;203;139;1m

# General ----------------------------------------

colorout::setOutputColors(

  index    = &#39;\x1b[38;2;76;86;106m&#39;,
  normal   = &#39;\x1b[38;2;216;222;233m&#39;,

  number   = &#39;\x1b[38;2;236;239;244m&#39;,
  negnum   = &#39;\x1b[38;2;180;142;173m&#39;,
  zero     = &#39;\x1b[38;2;136;192;208m&#39;, zero.limit = 0.01,
  infinite = &#39;\x1b[38;2;236;239;244m&#39;,

  string   = &#39;\x1b[38;2;235;203;139m&#39;,
  date     = &#39;\x1b[38;2;236;239;244m&#39;,
  const    = &#39;\x1b[38;2;136;192;208m&#39;,

  true     = &#39;\x1b[38;2;163;190;140m&#39;,
  false    = &#39;\x1b[38;2;191;97;106m&#39;,

  warn     = &#39;\x1b[38;2;235;203;139m&#39;,
  stderror = &#39;\x1b[38;2;191;97;106m&#39;, error = &#39;\x1b[38;2;191;97;106m&#39;,

  verbose  = FALSE
)

# Custom patterns --------------------------------

# NOTE Do not copy all. Pick what you use/like.

# _ {data.table} ---------------------------------

colorout::addPattern(&#39;[0-9]*:&#39;,  &#39;\x1b[38;2;143;188;187m&#39;)  # Row num
colorout::addPattern(&#39;---&#39;,      &#39;\x1b[38;2;76;86;106m&#39;)  # Row splitter
colorout::addPattern(&#39;&lt;[a-z]*&gt;&#39;, &#39;\x1b[38;2;143;188;187m&#39;)  # Col class

## Nord
# colorout::addPattern(&#39;[0-9]*:&#39;,  &#39;\x1b[38;2;143;188;187m&#39;)  # Row num
# colorout::addPattern(&#39;---&#39;,      &#39;\x1b[38;2;76;86;106m&#39;)  # Row splitter
# colorout::addPattern(&#39;&lt;[a-z]*&gt;&#39;, &#39;\x1b[38;2;143;188;187m&#39;)  # Col class

## Monokai
# colorout::addPattern(&#39;[0-9]*:&#39;,  &#39;\x1b[38;2;117;113;94m&#39;)  # Row num
# colorout::addPattern(&#39;---&#39;,      &#39;\x1b[38;2;117;113;94m&#39;)  # Row splitter
# colorout::addPattern(&#39;&lt;[a-z]*&gt;&#39;, &#39;\x1b[38;2;117;113;94m&#39;)  # Col class


# _ `str` ----------------------------------------

# Class
colorout::addPattern(&#39; num &#39;,        &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; int &#39;,        &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; chr &#39;,        &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; Factor &#39;,     &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; Ord.factor &#39;, &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; logi &#39;,       &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39;function &#39;,    &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; dbl &#39;,        &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; lgcl &#39;,       &#39;\x1b[38;2;143;188;187m&#39;)
colorout::addPattern(&#39; cplx &#39;,       &#39;\x1b[38;2;143;188;187m&#39;)
# Misc
colorout::addPattern(&#39;$ &#39;,           &#39;\x1b[38;2;76;86;106m&#39;)

# _ `str`, {mlr3} --------------------------------

# R6 field name
colorout::addPattern(&#39;* [A-z]*:&#39;,                      &#39;\x1b[38;2;235;203;139m&#39;)
colorout::addPattern(&#34;* [A-z]* [A-z]*:&#34;,               &#39;\x1b[38;2;235;203;139m&#39;)
colorout::addPattern(&#34;* [A-z]* [A-z]* [A-z]*:&#34;,        &#39;\x1b[38;2;235;203;139m&#39;)
colorout::addPattern(&#34;* [A-z]* [A-z]* [A-z]* [A-z]*:&#34;, &#39;\x1b[38;2;235;203;139m&#39;)
# So on...

# Clean up
rm(theme, to_ansi)
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-16-r-colorout-%E8%AE%BE%E7%BD%AE%E7%BB%88%E7%AB%AF%E8%BE%93%E5%87%BA%E7%9A%84%E4%B8%BB%E9%A2%98%E9%A2%9C%E8%89%B2/  

