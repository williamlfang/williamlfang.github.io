# R 安装 stringi 包


命令行安装 R `stringi` 软件包

&lt;!--more--&gt;

```bash
RUN cd /tmp &amp;&amp; \
    wget --no-check-certificate https://github.com/gagolews/stringi/archive/master.zip -O stringi.zip &amp;&amp; \
    unzip stringi.zip &amp;&amp; \
    sed -i &#39;/\/icu..\/data/d&#39; stringi-master/.Rbuildignore &amp;&amp; \
    R CMD build stringi-master &amp;&amp; \
    R CMD INSTALL `ls -alh |grep tar |cut -d&#39; &#39; -f11`
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-01-10-r-%E5%AE%89%E8%A3%85-stringi-%E5%8C%85/  

