# tmux: error while loading shared libraries: libevent_core 2.1.so.6


`tmux` 报错

```bash
tmux: error while loading shared libraries: libevent_core-2.1.so.7
```

使用 `ldd` 查看是可以找到动态库

```bash
ldd ~/local/bin/tmux
        linux-vdso.so.1 (0x00007ffe043f8000)
        libutil.so.1 =&gt; /lib64/libutil.so.1 (0x00007fa85ce0c000)
        libtinfo.so.5 =&gt; /lib64/libtinfo.so.5 (0x00007fa85cbe2000)
        libevent_core-2.1.so.6 =&gt; /home/lfang/local/lib/libevent_core-2.1.so.6 (0x00007fa85c9ac000)
        libm.so.6 =&gt; /lib64/libm.so.6 (0x00007fa85c6aa000)
        libresolv.so.2 =&gt; /lib64/libresolv.so.2 (0x00007fa85c493000)
        libc.so.6 =&gt; /lib64/libc.so.6 (0x00007fa85c0e7000)
        libcrypto.so.10 =&gt; /lib64/libcrypto.so.10 (0x00007fa85bc84000)
        libpthread.so.0 =&gt; /lib64/libpthread.so.0 (0x00007fa85ba66000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fa85d00f000)
        libdl.so.2 =&gt; /lib64/libdl.so.2 (0x00007fa85b862000)
        libz.so.1 =&gt; /home/lfang/opt/lib/libz.so.1 (0x00007fa85d20c000)
```
&lt;!--more--&gt;

查询后发现，`tmux` 除非在安装的时候指定动态库路径，否则在运行时，**只会查找默认的系统动态了路径**，即 `/lib64/`。这样的花，需要我们手动复制一份动态库到系统路径

```bash
cd /lib64
cp /home/lfang/local/lib/libevent_core-2.1.so.6.0.2 .
ln libevent_core-2.1.so.6.0.2  libevent_core-2.1.so.6
```

再次启动 `tmux` 即可。

当然，我们也可以重新编译 `tmux`，关键是需要添加参数 `LDFLAGS=&#34;-Wl,-rpath=&lt;libevent_lib_path&gt; -L$HOME/local/lib&#34;`， 比如我的路径是：`LDFLAGS=&#34;-Wl,-rpath=$HOME/local/lib -L$HOME/local/lib&#34;`。

```bash
cd $HOME/tmp
export TMUX_VERSION=3.4
wget --no-check-certificate https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
tar -xvf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure --prefix=$HOME/local CPPFLAGS=&#34;-I$HOME/local/include -I$HOME/local/include/ncurses&#34; LDFLAGS=&#34;-Wl,-rpath=$HOME/local/lib -L$HOME/local/lib&#34;
make -j
make install
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-02-20-tmux--error-while-loading-shared-libraries--libevent_core-2.1.so.6/  

