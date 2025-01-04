# gcc14 源代码安装


通过源代码安装 `gcc14`，同时需要更新 `libstdc&#43;&#43;` 动态库链接。

&lt;!--more--&gt;

## 安装

```bash
wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz
tar xvf gcc-14.2.0.tar.gz
cd gcc-14.2.0

## install prerequisites
./contrib/download_prerequisites
for k in `ls |grep .tar.`; do
    tar xvf ${k}
done
ln -s gmp-6.2.1 gmp
ln -s mpfr-4.1.0 mpfr
ln -s mpc-1.2.1 mpc
ln -s isl-0.24 isl

mkdir -p /shared/trading/lib/gcc14
./configure --prefix=/shared/trading/lib/gcc14 \
        --enable-bootstrap \
        --enable-checking=release \
        --enable-languages=c,c&#43;&#43; \
        --disable-multilib
make &amp;&amp; make install

#echo  &#34;export PATH=/usr/local/gcc9/bin:$PATH&#34; &gt;&gt; /etc/profile.d/gcc.sh &amp;&amp; \
#source /etc/profile.d/gcc.sh &amp;&amp; \
#ln -sv /usr/local/gcc9/include/ /usr/include/gcc &amp;&amp; \
#echo &#34;/usr/local/gcc9/lib64&#34; &gt;&gt; /etc/ld.so.conf.d/gcc.conf &amp;&amp; \
#ldconfig -v &amp;&amp; \
#ldconfig -p |grep gcc &amp;&amp; \
#ln -sf /usr/local/gcc9/bin/g&#43;&#43; /usr/bin/g&#43;&#43; &amp;&amp; \
#ln -sf /usr/local/gcc9/bin/gcc /usr/bin/gcc &amp;&amp; \
#ln -sf /usr/local/gcc9/bin/c&#43;&#43; /usr/bin/c&#43;&#43; &amp;&amp; \
#ln -sf /usr/local/gcc9/bin/cc /usr/bin/cc &amp;&amp; \
#rm -rf /tmp/gcc*
```

## libstdc&#43;&#43;

```bash
## ubuntu
ln -sfn /usr/local/gcc14/lib64/libstdc&#43;&#43;.so /usr/lib/x86_64-linux-gnu/libstdc&#43;&#43;.so.6

## centos
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-14-gcc14-%E6%BA%90%E4%BB%A3%E7%A0%81%E5%AE%89%E8%A3%85/  

