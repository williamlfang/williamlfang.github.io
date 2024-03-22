# R: 安装 tensorflow


```R
Sys.setenv(TENSORFLOW_PYTHON=&#34;/home/fl/anaconda3/bin&#34;)
devtools::install_github(&#34;rstudio/tensorflow&#34;)
devtools::install_github(&#34;rstudio/keras&#34;)

library(tensorflow)

hello &lt;- tf$constant(&#34;Hello&#34;)
print(hello)
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-05-16-r--%E5%AE%89%E8%A3%85-tensorflow/  

