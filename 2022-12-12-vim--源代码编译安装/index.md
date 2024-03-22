# Vim: 源代码编译安装


从源代码编译安装 `Vim9.2`。

&lt;!--more--&gt;

```bash
export LDFLAGS=&#34;-rdynamic&#34;
cd /tmp &amp;&amp; \
    yum install perl-ExtUtils-Embed ruby ruby-devel -y &amp;&amp; \
    yum clean all &amp;&amp; \
    rm -rf /var/cache/yum/* &amp;&amp; \
    wget --no-check-certificate http://www.lua.org/ftp/lua-5.4.4.tar.gz &amp;&amp; \
    tar -xvf lua-5.4.4.tar.gz &amp;&amp; \
    cd lua-5.4.4 &amp;&amp; \
    make -j &amp;&amp; make install &amp;&amp; \
    rm -rf /tmp/lua* &amp;&amp; \
    cd /tmp &amp;&amp; \
    git clone https://github.com/vim/vim.git &amp;&amp; \
    cd vim &amp;&amp; \
    git pull origin master &amp;&amp; \
    make clean distclean &amp;&amp; \
    ./configure --prefix=/usr/local/vim9 \
        --with-features=huge \
        --enable-multibyte \
        --enable-rubyinterp=yes \
        --enable-python3interp=yes \
        --with-python3-command=/usr/local/python3/bin/python3 \
        --with-python3-config-dir=$(/usr/local/python3/bin/python3-config --configdir) \
        --enable-perlinterp=yes \
        --enable-luainterp=yes \
        --with-lua-prefix=/usr/local \
        --enable-cscope\
        --enable-largefile \
        --disable-netbeans \
        --with-compiledby=&#34;william&#34; \
        --enable-fail-if-missing &amp;&amp; \
    make -j &amp;&amp; make install &amp;&amp; \
    ln -sfn /usr/local/vim9/bin/vim /usr/bin/vim &amp;&amp; \
    echo &#34;/usr/local/vim9/bin&#34; &gt;&gt; /etc/ld.so.conf &amp;&amp; \
    ldconfig -v &amp;&amp; \
    rm -rf /tmp/vim*
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-12-12-vim--%E6%BA%90%E4%BB%A3%E7%A0%81%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85/  

