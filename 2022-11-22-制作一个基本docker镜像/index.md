# 制作一个基本Docker镜像


使用 `Dockerfile`，从源代码开始搭建一个基本的 `Docker Image`，为其他应用提供基础服务。

&lt;!--more--&gt;

## Dockerfile

```dockerfile
FROM centos:centos7.9.2009
MAINTAINER William
LABEL Remarks=&#34;CentOS7.9 Develop&amp;Testing Environment @WuyaCapital&#34;

RUN yum update -y &amp;&amp; yum install -y \
    sudo vim git make cmake htop\
    gcc gcc-c&#43;&#43; kernel-devel \
    bzip2 mlocate sqlite-devel \
    openssl-devel libcurl-devel chrony \
    wget dmidecode net-tools openssh-server perl-CPAN perl-IPC-Cmd

RUN yum install -y kde-l10n-Chinese &amp;&amp; \
    yum reinstall -y glibc-common &amp;&amp; \
    localedef -c -f GB18030 -i zh_CN zh_CN.GB18030 &amp;&amp; \
    updatedb

RUN cd /tmp &amp;&amp; wget --no-check-certificate http://mirrors.ustc.edu.cn/gnu/libc/glibc-2.18.tar.gz &amp;&amp; \
    tar -xvf glibc-2.18.tar.gz &amp;&amp; \
    cd glibc-2.18 &amp;&amp; \
    mkdir build &amp;&amp; cd build &amp;&amp; \
    ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin &amp;&amp; \
    make &amp;&amp; make install &amp;&amp; \
    rm -rf /tmp/glibc*

RUN cd /tmp &amp;&amp; mkdir gcc9 &amp;&amp; cd gcc9 &amp;&amp; \
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
    sudo ./configure --prefix=/usr/local/gcc9 --enable-bootstrap --enable-checking=release --enable-languages=c,c&#43;&#43; --disable-multilib &amp;&amp; \
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

RUN cd /tmp &amp;&amp; wget --no-check-certificate https://www.openssl.org/source/openssl-3.0.7.tar.gz &amp;&amp; \
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

RUN cd /tmp &amp;&amp; wget --no-check-certificate https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz &amp;&amp; \
    tar -xvf Python-3.11.0.tar.xz &amp;&amp; \
    cd Python-3.11.0 &amp;&amp; \
    CFLAGS=&#34;-I/usr/local/openssl/include&#34; LDFLAGS=&#34;-L/usr/local/openssl/lib64&#34; \
        ./configure --enable-optimizations \
        --enable-loadable-sqlite-extensions \
        --prefix=/usr/local/python3 \
        --with-openssl=/usr/local/openssl &amp;&amp; \
    make &amp;&amp; make install &amp;&amp; \
    ln -s /usr/local/python3/bin/python3 /usr/bin/python3 &amp;&amp; \
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3 &amp;&amp; \
    python3 -m ssl &amp;&amp; \
    rm -rf /tmp/Python*

ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime &amp;&amp; echo $TZ &gt; /etc/timezone

RUN mkdir -p /shared/trading /data

ENV PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
ENV LANG=en_US.UTF-8
ENV BASH_ENV=~/.bashrc \
    ENV=~/.bashrc \
    PROMPT_COMMAND=&#34;source ~/.bashrc&#34;
EXPOSE 22 80
WORKDIR /app
CMD [&#34;/usr/sbin/init&#34;]
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-22-%E5%88%B6%E4%BD%9C%E4%B8%80%E4%B8%AA%E5%9F%BA%E6%9C%ACdocker%E9%95%9C%E5%83%8F/  

