# glibc2.18 安装


先查看当前系统的 `glibc` 版本

```bash
locate libc.so                                                                                                                                                                               [16:20:29]

/usr/lib64/libc.so
/usr/lib64/libc.so.6
/usr/local/glibc-2.34/lib/libc.so
/usr/local/glibc-2.34/lib/libc.so.6
```

当前系统使用的 `glibc` 动态库在 `/usr/lib64/libc.so.6`。我们可以使用命令 `strings` 查看动态库的版本信息

```bash
strings /usr/lib64/libc.so.6 |egrep &#39;^GLIBC_2.&#39; |sort                                                                                                                                        [16:19:55]
GLIBC_2.10
GLIBC_2.10
GLIBC_2.11
GLIBC_2.11
GLIBC_2.12
GLIBC_2.13
GLIBC_2.13
GLIBC_2.14
GLIBC_2.15
GLIBC_2.16
GLIBC_2.16
GLIBC_2.17
GLIBC_2.17
GLIBC_2.18
GLIBC_2.18
GLIBC_2.2.5
GLIBC_2.2.6
GLIBC_2.2.6
GLIBC_2.3
GLIBC_2.3.2
GLIBC_2.3.3
GLIBC_2.3.4
GLIBC_2.4
GLIBC_2.5
GLIBC_2.5
GLIBC_2.6
GLIBC_2.6
GLIBC_2.7
GLIBC_2.7
GLIBC_2.8
GLIBC_2.8
GLIBC_2.9
GLIBC_2.9
```

&lt;!--more--&gt;

如果发现上述版本缺少 `GLIBC_2.18`，则需要源代码安装。

```bash
#!/bin/bash
export GLIBC_VERSION=2.18
cd /tmp &amp;&amp; wget --no-check-certificate http://mirrors.ustc.edu.cn/gnu/libc/glibc-${GLIBC_VERSION}.tar.gz &amp;&amp; \
    tar -xvf glibc-${GLIBC_VERSION}.tar.gz &amp;&amp; \
    cd glibc-${GLIBC_VERSION} &amp;&amp; \
    mkdir build &amp;&amp; cd build &amp;&amp; \
    ../configure --prefix=/usr \
        --disable-profile \
        --enable-add-ons \
        --with-headers=/usr/include \
        --with-binutils=/usr/bin &amp;&amp; \
    make &amp;&amp; make install &amp;&amp; \
    rm -rf /tmp/glibc*
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-11-glibc2.18-%E5%AE%89%E8%A3%85/  

