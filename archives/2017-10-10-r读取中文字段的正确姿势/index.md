# R读取中文字段的正确姿势




# `readr` 软件包

## 读取数据

`readr` 是大神**Hadley Wickham**开发的用于读取数据文件的软件包，可以读取多个格式的文件，如 `.csv`, `.txt` 等，而且其提供了丰富的调用函数。

对于一般的数据文件，我通常是使用另外一个包`data.table`里面的`fread`，这是因为该函数读取大容量的数据文件速度较快，而且直接生成`data.table`格式，方便之后的数据清理。但是，该函数由于接口限制，暂时还无法处理其他格式的文件，而且对多语言的支持也比较弱，目前还无法用来读取包含中文字段的文件。因此，我只能使用`read_csv`来读取*在2010年的期货交易数据*，因为这份数据的表头字段是中文。

## 功能介绍

目前我主要还是使用`readr`当中的函数，`read_csv`。具体的函数说明，可以通过帮助来获得。


```r
Sys.setlocale(&#34;LC_ALL&#34;, &#39;en_US.UTF-8&#39;)
```

```
[1] &#34;LC_CTYPE=en_US.UTF-8;LC_NUMERIC=C;LC_TIME=en_US.UTF-8;LC_COLLATE=en_US.UTF-8;LC_MONETARY=en_US.UTF-8;LC_MESSAGES=en_US.UTF-8;LC_PAPER=zh_CN.UTF-8;LC_NAME=C;LC_ADDRESS=C;LC_TELEPHONE=C;LC_MEASUREMENT=zh_CN.UTF-8;LC_IDENTIFICATION=C&#34;
```

```r
library(readr)
library(magrittr)

?read_csv
```

&gt; read_csv(file, col_names = TRUE, col_types = NULL,locale = default_locale(), na = c(&#34;&#34;, &#34;NA&#34;), quoted_na = TRUE, quote = &#34;\&#34;&#34;, comment = &#34;&#34;, trim_ws = TRUE, skip = 0, n_max = Inf, guess_max = min(1000, n_max), progress = show_progress())


这里有几个参数需要设置：

- 首先设置系统的默认编码格式，`Sys.setlocale(&#34;LC_ALL&#34;, &#39;en_US.UTF-8&#39;)`
- 使用 `guess_encodng(file)` 来获取文件的编码格式
- 利用 `locale=locale(encoding = &#39;GB18030&#39;))` 来解码中文字段
- 同时，我们还可以使用 `iconv(x, from, to)` 来转码


# 代码演示


```r
dataFile &lt;- &#34;https://raw.githubusercontent.com/williamlfang/williamlfang.github.io/sources/content/files/a1005.csv&#34;
```

## 错误姿势

&gt; 没有设置编码格式


```r
dt &lt;- dataFile %&gt;% read_csv()
```

## 正确姿势


```r
dt &lt;- dataFile %&gt;% read_csv(., locale = locale(encoding = &#34;GB18030&#34;))

knitr::kable(dt)
```





---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-10-10-r%E8%AF%BB%E5%8F%96%E4%B8%AD%E6%96%87%E5%AD%97%E6%AE%B5%E7%9A%84%E6%AD%A3%E7%A1%AE%E5%A7%BF%E5%8A%BF/  

