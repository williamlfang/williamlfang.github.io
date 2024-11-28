# R 调用 python


利用 `reticulate` 接口，我们可以在 `R` 中调用 `python` 封装的函数。

![r-python](./r-python.png &#34;R calling python function&#34;)

&lt;!--more--&gt;

## 环境变量

```bash
export LD_LIBRARY_PATH=/home/ops/anaconda3/lib:/shared/trading/lib/gcc/lib64:/shared/trading/lib:/shared/trading/lib/gcc9/lib64:/shared/trading/lib/gcc9/lib:${LD_LIBRARY_PATH}
export PATH=/shared/trading/lib/gcc/bin:/shared/trading/lib/binutils/bin:/shared/trading/lib/gcc9/bin:${PATH}
```

## 修改 Make

```bash
mkdir -p ~/.R
vim ~/R/Makevars

CC                 = /shared/trading/lib/gcc9/bin/gcc
CXX                = /shared/trading/lib/gcc9/bin/g&#43;&#43;
CXXSTD             = -std=c&#43;&#43;11
CXXFLAGS           = -g -O3 -Wall -fPIC -pipe -Wno-unused -pedantic -static-libgcc -static-libstdc&#43;&#43;
LD_LIBRARY_PATH    = /shared/trading/lib/gcc9/lib64:/shared/trading/lib/gcc9/lib:$LD_LIBRARY_PATH
CPLUS_INCLUDE_PATH = /shared/trading/lib/gcc9/include:$CPLUS_INCLUDE_PATH
#CXX17 = g&#43;&#43;-7 -std=gnu&#43;&#43;17 -fPIC CXX11 = g&#43;&#43;
CXX14 = g&#43;&#43;
CXX17 = g&#43;&#43;
CXX17STD = -std=c&#43;&#43;17
```

## 安装 reticulate

```R
install.packages(&#34;https://cran.r-project.org/src/contrib/Archive/reticulate/reticulate_1.25.tar.gz&#34;, repos=NULL, type=&#34;source&#34;)
install.packages(&#34;https://cran.r-project.org/src/contrib/Archive/RcppTOML/RcppTOML_0.1.3.tar.gz&#34;, repos=NULL, type=&#34;source&#34;)
```

## 使用

```R
library(reticulate)
use_python(&#34;~/miniconda3/bin/python&#34;)
source_python(&#39;/fs/public/ops/config/ceph.py&#39;)

dt &lt;- read_s3_csv(&#39;raven/futures_minute/prod/trade_config/GTJA_ZGC_SHFE/2024-11-28.csv&#39;)
print(dt)
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-11-28-r-%E8%B0%83%E7%94%A8-python/  

