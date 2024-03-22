# R:4.0 源代码安装


`R4.0` 正式发布上线了。新版本的代码在性能和编程方面均有出色的提升。本文将介绍如何通过源代码的方式安装程序，并在 `Rstudio` 当中指定可执行路径。



# 获取最新本 R



可以通过[官网](https://cran.rstudio.com/src/base/R-4/)找到相应的源代码压缩包。

```bash
cd ~/Downloads
wget https://cran.rstudio.com/src/base/R-4/R-4.0.0.tar.gz
tar -xvf R-4.0.0.tar.gz
cd R-4.0.0
```

关于 `BLAS`

&gt; The BLAS libraries are not part of the open source R binaries, but they speed up calculations that are common in many analytic methods. If you are going through the effort of building R from source you probably want to take advantage of the performance benefits that are enabled by the BLAS libraries.



# 安装



参考这篇博客来安装依赖包：[Compiling R-3.4.2 on CentOS 6 with GNU](https://linuxcluster.wordpress.com/2017/10/29/compiling-r-3-4-2-on-centos-6-with-gnu/)



## 安装 zlib

```bash
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxvf zlib-1.2.11
cd zlib-1.2.11
configure --prefix=/usr/local/zlib-1.2.11
make -j 
make install
export LD_LIBRARY_PATH=/usr/local/zlib-1.2.11/lib:$LD_LIBRARY_PATH
```



## 安装 bzip

```bash
wget https://sourceforge.net/projects/bzip2/files/bzip2-1.0.6.tar.gz
tar -xvf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
make -f Makefile-libbz2_so
make clean
make -n install PREFIX=/usr/local/R4.0
make install PREFIX=/usr/local/R4.0

## 或者直接安装
yum -y install cmake bzip2 htop tldr pigz pbzip2
```



## 安装 liblzma or xz



````bash
wget http://tukaani.org/xz/xz-5.2.3.tar.gz --no-check-certificate
tar xzvf xz-5.2.3.tar.gz
cd xz-5.2.3
./configure --prefix=/usr/local/xz-5.2.3
make -j8
make install
export LD_LIBRARY_PATH=/usr/local/xz-5.2.3/lib:$LD_LIBRARY_PATH
````



## 安装  pcre2

[**pcre2简介**](http://blog.fpliu.com/it/software/pcre2)

```bash
## Ubuntu
sudo apt-get install -y pcre2-utils libpcre2-dev
## CentOS
sudo yum install -y pcre2-tools pcre2-devel
```



## 处理环境变量

```bash
export CFLAGS=&#34;-I/usr/local/zlib-1.2.11/include -I/usr/local/xz-5.2.3/include&#34;
export LDFLAGS=&#34;-L/usr/local/zlib-1.2.11/lib -L/usr/local/bzip2-1.0.6/lib -L/usr/local/xz-5.2.3/lib -L/usr/local/xz-5.2.3/lib&#34;
```



## 安装 R



```bash

## --prefix 指定路径，如果没有，会自动创建
## Note that the –enable-R-shlib option is required in order to 
## make the underlying R shared library available to RStudio Server.
## link to the system BLAS libraries rather than use the R internal versions
sudo ./configure --prefix=/usr/local/R4.0 --enable-R-shlib --with-blas --with-lapack --enable-utf8 LDFLAGS=&#34;-L/usr/local/zlib-1.2.11/lib -L/usr/local/bzip2-1.0.6/lib -L/usr/local/xz-5.2.3/lib -L/usr/local/xz-5.2.3/lib&#34; CFLAGS=&#34;-I/usr/local/zlib-1.2.11/include -I/usr/local/xz-5.2.3/include&#34;

make -j
## 不管以前的错误，直接安装
make install
```

## 启动

```bash
/usr/local/R4.0/bin/R

install.packages(&#34;https://github.com/jeroen/curl/archive/master.tar.gz&#34;, repos = NULL)
```

![](/images/2020-05-14-R-4.0-源代码安装/R4.0.png)

---

> 作者:   
> URL: https://williamlfang.github.io/archives/r4.0-%E6%BA%90%E4%BB%A3%E7%A0%81%E5%AE%89%E8%A3%85/  

