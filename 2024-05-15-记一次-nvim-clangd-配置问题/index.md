# 记一次 nvim clangd 配置问题


&gt; 最近在迁移开发环境（本质上是这家公司太抠门了，舍不得给开发狗购买机器），需要重新配置我的 `nvim`。由于我使用 `clangd` 进行`c&#43;&#43;` 代码的实时编译、检测以及语法高度，所以要求机器能够支持 `clangd` 的编译环境。

&lt;!--more--&gt;

## 遇到的问题

打开 `nvim` 编辑 `c&#43;&#43;` 代码文件，会出现报错

```
Client 1 quit with exit code 1 and signal 0
```

无法在代码之间进行跳转。因此大概可以猜测 `lsp` 出问题了。

### node 版本过低

### clangd 无法启动

可以先试着在终端执行 `clangd` 命令，看看环境是否支持

```bash
/home/lfang/.config/nvim/lazy/mason/bin/clangd

/home/lfang/.config/nvim/lazy/mason/bin/clangd: /lib64/libc.so.6: version `GLIBC_2.18&#39; not found (required by /home/lfang/.config/nvim/lazy/mason/bin/clangd)
```

尴尬的是，这家公司实在拉跨，程序常年不更新，所以找不到 `GLIBC_2.18` 的版本号。

## 解决方案

### 升级 node

### 升级 glibc_2.18

```bash
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
> URL: https://williamlfang.github.io/2024-05-15-%E8%AE%B0%E4%B8%80%E6%AC%A1-nvim-clangd-%E9%85%8D%E7%BD%AE%E9%97%AE%E9%A2%98/  

