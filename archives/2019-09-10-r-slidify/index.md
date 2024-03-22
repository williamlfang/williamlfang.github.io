# R slidify


使用 R-slidify 制作讲演课件

# 安装

## 安装 `slidify`软件包

```R
library(devtools)
install_github(&#39;ramnathv/slidify&#39;)
install_github(&#39;ramnathv/slidifyLibraries&#39;)
```
&lt;!--more--&gt;

# Demo

## 初始化

```R
library(slidify)
author(&#39;mydeck&#39;)

slidify(&#34;index.Rmd&#34;)
```

## 格式

# 上传到 Github

```R
# publish to github
# create an empty repo on github. replace USER and REPO with your repo details
  publish(user = &#39;williamlfang&#39;, repo = &#39;myslidify&#39;)

# publish to rpubs
publish(title = &#39;My Deck&#39;, &#39;index.html&#39;, host = &#39;rpubs&#39;)
```

## demo
可以参考我的[小例](https://williamlfang.github.io/myslidify/)。



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-09-10-r-slidify/  

