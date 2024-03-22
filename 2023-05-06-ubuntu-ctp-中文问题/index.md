# ubuntu ctp 中文问题




&lt;!--more--&gt;


```bash
terminate called after throwing an instance of &#39;std::runtime_error&#39;
what(): locale::facet::_S_create_c_locale name not valid
```

需要安装中文包支持，因为 `CTP` 采用了中文接口

```bash
# Set the locale
RUN apt-get clean &amp;&amp; \
    apt-get update &amp;&amp; \
    apt-get install -y locales locales-all &amp;&amp; \
    locale-gen zh_CN.GB18030
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-06-ubuntu-ctp-%E4%B8%AD%E6%96%87%E9%97%AE%E9%A2%98/  

