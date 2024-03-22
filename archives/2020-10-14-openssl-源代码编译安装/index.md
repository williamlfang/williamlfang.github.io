# OpenSSL 源代码编译安装




# 下载

到[官网](https://www.openssl.org/source/old/)下载

```bash
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1g.tar.gz
```



# 安装

```bash
tar -xvf openssl-1.1.1g.tar.gz
cd openssl-1.1.1

./config --prefix=/home/lfang/opt --libdir=lib no-shared zlib-dynamic
make
make install
```

# 设置

```bash
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
echo &#34;export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64&#34; &gt;&gt; ~/.bashrc
```

# 版本

```bash
openssl version -a
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-10-14-openssl-%E6%BA%90%E4%BB%A3%E7%A0%81%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85/  

