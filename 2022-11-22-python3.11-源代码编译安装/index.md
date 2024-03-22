# Python3.11：源代码编译安装


从源代码开始编译、安装 `Python3.11`，由于从这个版本之后，`Python` 采用了 `SSL` 的加密方式，需要依赖 `openssl-1.1.1`。同时，如果我们开启了 `--enable-optimization` 优化选项，还需要依赖 `gcc9` 以上版本才能支持，否则会一直出现报错。

&lt;!--more--&gt;

## 安装依赖包

```bash
yum update -y &amp;&amp; yum install -y \
        sudo vim git make cmake htop\
        gcc gcc-c&#43;&#43; kernel-devel \
        bzip2 mlocate sqlite-devel \
        zlib zlib-devel libffi-devel \
        openssl-devel libcurl-devel chrony \
        wget dmidecode net-tools openssh-server openssh-client perl-CPAN perl-IPC-Cmd &amp;&amp; \
    yum clean all &amp;&amp; \
    rm -rf /var/cache/yum/*
```


## 安装 glibc

```bash
cd /tmp &amp;&amp; wget --no-check-certificate http://mirrors.ustc.edu.cn/gnu/libc/glibc-2.18.tar.gz &amp;&amp; \
    tar -xvf glibc-2.18.tar.gz &amp;&amp; \
    cd glibc-2.18 &amp;&amp; \
    mkdir build &amp;&amp; cd build &amp;&amp; \
    ../configure --prefix=/usr \
        --disable-profile \
        --enable-add-ons \
        --with-headers=/usr/include \
        --with-binutils=/usr/bin &amp;&amp; \
    make &amp;&amp; make install &amp;&amp; \
    rm -rf /tmp/glibc*
```

## 安装 gcc9

```bash
cd /tmp &amp;&amp; mkdir gcc9 &amp;&amp; cd gcc9 &amp;&amp; \
    wget --no-check-certificate https://ftp.gnu.org/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.gz &amp;&amp; \
    tar zxvf gcc-9.2.0.tar.gz &amp;&amp; \
    cd gcc-9.2.0 &amp;&amp; \
    wget --no-check-certificate ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2 &amp;&amp; \
    wget --no-check-certificate ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-3.1.4.tar.bz2 &amp;&amp; \
    wget --no-check-certificate ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz &amp;&amp; \
    wget --no-check-certificate ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2 &amp;&amp; \
    tar jxvf gmp-6.1.0.tar.bz2 &amp;&amp; \
    tar zxvf mpc-1.0.3.tar.gz &amp;&amp; \
    tar jxvf mpfr-3.1.4.tar.bz2 &amp;&amp; \
    tar jxvf isl-0.18.tar.bz2 &amp;&amp; \
    ln -s gmp-6.1.0 gmp  &amp;&amp; \
    ln -s mpfr-3.1.4 mpfr  &amp;&amp; \
    ln -s mpc-1.0.3 mpc &amp;&amp; \
    ln -s isl-0.18 isl &amp;&amp; \
    sudo ./configure --prefix=/usr/local/gcc9 \
        --enable-bootstrap \
        --enable-checking=release \
        --enable-languages=c,c&#43;&#43; \
        --disable-multilib &amp;&amp; \
    make &amp;&amp; make install &amp;&amp; \
    echo  &#34;export PATH=/usr/local/gcc9/bin:$PATH&#34; &gt;&gt; /etc/profile.d/gcc.sh &amp;&amp; \
    source /etc/profile.d/gcc.sh &amp;&amp; \
    ln -sv /usr/local/gcc9/include/ /usr/include/gcc &amp;&amp; \
    echo &#34;/usr/local/gcc9/lib64&#34; &gt;&gt; /etc/ld.so.conf.d/gcc.conf &amp;&amp; \
    ldconfig -v &amp;&amp; \
    ldconfig -p |grep gcc &amp;&amp; \
    ln -sf /usr/local/gcc9/bin/g&#43;&#43; /usr/bin/g&#43;&#43; &amp;&amp; \
    ln -sf /usr/local/gcc9/bin/gcc /usr/bin/gcc &amp;&amp; \
    ln -sf /usr/local/gcc9/bin/c&#43;&#43; /usr/bin/c&#43;&#43; &amp;&amp; \
    ln -sf /usr/local/gcc9/bin/cc /usr/bin/cc &amp;&amp; \
    rm -rf /tmp/gcc*
```

## 安装 openssl

```bash
cd /tmp &amp;&amp; wget --no-check-certificate https://www.openssl.org/source/openssl-3.0.7.tar.gz &amp;&amp; \
    tar -xvf openssl-3.0.7.tar.gz &amp;&amp; \
    cd openssl-3.0.7 &amp;&amp; \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl no-shared zlib-dynamic &amp;&amp; \
    make &amp;&amp; make install &amp;&amp; \
    ln -s /usr/local/openssl/include/openssl /usr/include/openssl &amp;&amp; \
    ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so &amp;&amp; \
    ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1 &amp;&amp; \
    ln -s /usr/local/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1 &amp;&amp; \
    ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl &amp;&amp; \
    echo &#34;/usr/local/openssl/lib64&#34; &gt;&gt; /etc/ld.so.conf &amp;&amp; \
    ldconfig -v &amp;&amp; \
    rm -rf /tmp/openssl*
```

这里需要注意：

- 指定了安装路径：``--prefix=/usr/local/openssl`，这个在安装 `Python` 的时候使用



## 安装 Python 3.11

```bash
export PYTHON_VERSION=3.11.1
cd /tmp &amp;&amp; \
    # wget --no-check-certificate https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz &amp;&amp; \
    wget --no-check-certificate https://registry.npmmirror.com/-/binary/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz &amp;&amp; \
    tar -xvf Python-${PYTHON_VERSION}.tar.xz &amp;&amp; \
    cd Python-${PYTHON_VERSION} &amp;&amp; \
    export LDFLAGS=-rdynamic &amp;&amp; \
    CFLAGS=&#34;-I/usr/local/openssl/include&#34; LDFLAGS=&#34;-L/usr/local/openssl/lib64&#34; \
    ./configure \
        --enable-shared \
        --enable-optimizations \
        --enable-loadable-sqlite-extensions \
        --prefix=/usr/local/python3 \
        --with-openssl=/usr/local/openssl &amp;&amp; \
    make -j &amp;&amp; make install &amp;&amp; \
    ln -s /usr/local/python3/bin/python3 /usr/bin/python3 &amp;&amp;\
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3 &amp;&amp; \
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip &amp;&amp; \
    echo &#34;export PATH=/usr/local/python3/bin:$PATH&#34; &gt;&gt; /etc/profile.d/python3.sh &amp;&amp; \
    echo &#34;/usr/local/python3/lib&#34; &gt;&gt; /etc/ld.so.conf &amp;&amp; \
    ldconfig -v &amp;&amp; \
    python3 -m ssl &amp;&amp; \
    rm -rf /tmp/Python*
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-22-python3.11-%E6%BA%90%E4%BB%A3%E7%A0%81%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85/  

