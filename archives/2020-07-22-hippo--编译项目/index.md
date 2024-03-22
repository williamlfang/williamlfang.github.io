# Hippo: 编译项目


# 安装 clang9

```bash
wget https://releases.llvm.org/9.0.0/clang%2bllvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
tar -xvf clang&#43;llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
cd clang&#43;llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04
sudo mkdir /usr/lib/llvm-9
sudo cp -r ./* /usr/lib/llvm-9
```
&lt;!--more--&gt;

# ProtoBuf

```bash
sudo apt-get install autoconf automake libtool -y
git clone https://github.com/google/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh
./configure
make
make check
sudo make install
sudo ldconfig
```





# gRPC 编译

参考官网 [quick-start](https://grpc.io/docs/languages/cpp/quickstart/)

- 需要指定版本号 `v1.20.0`
- `configure` 需要进行打包配置(package)，这个需要参考



```bash
## 安装依赖包
sudo apt-get install golang
sudo apt install autoconf automake libtool shtool

git clone --recurse-submodules -b v1.20.0 https://github.com/grpc/grpc
cd grpc

## ---------------------------------------------------
## 使用 gcc6.2
set(CMAKE_CXX_COMPILER &#34;/usr/local/packages/gcc/bin/g&#43;&#43;&#34;)
set(CMAKE_C_COMPILER &#34;/usr/local/packages/gcc/bin/gcc&#34;)
set(CMAKE_CXX_STANDARD 11)

cmake -DgRPC_INSTALL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DgRPC_BUILD_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=/home/lfang/opt \
    -DgRPC_SSL_PROVIDER=package \
    ../..
## ---------------------------------------------------

mkdir -p ./cmake/build
cd ./cmake/build
cmake -DgRPC_INSTALL=ON \
	  -DgRPC_BUILD_TESTS=OFF \
	  -DgRPC_PROTOBUF_PROVIDER=package \
	  -DgRPC_ZLIB_PROVIDER=package \
	  -DgRPC_CARES_PROVIDER=package \
	  -DgRPC_SSL_PROVIDER=package \
	  -DCMAKE_BUILD_TYPE=Release \
	  ../..

make -j
sudo make install
```

# libcurl

```bash
git clone https://github.com/curl/curl.git
cd curl
./buildconf
./configure --without-ssl --without-libidn2 --without-zlib
make -j
sudo make install
cd include # ONLY install the include folder (with curl.h, etc)
make install
```

# pistache

```bash
git clone https://github.com/oktal/pistache.git
cd pistache
mkdir build
cd build
cmake -G &#34;Unix Makefiles&#34; -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install
```

# hiredis

```bash
git clone https://github.com/redis/hiredis.git

make USE_SSL=1
```



# OpenSSL 编译

访问[官网](https://www.openssl.org/source/old/)，下载对应版本号

```bash
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1.tar.gz
tar -xzvf openssl-1.1.1.tar.gz
cd openssl-1.1.1
./config --prefix=/usr/local --openssldir=/usr/local/openssl
make -j &amp;&amp; make install
```

# RabbitMQ

## 安装 Erlang

```bash
wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -

## Ubuntu 20.04:
echo &#34;deb https://packages.erlang-solutions.com/ubuntu focal contrib&#34; | sudo tee /etc/apt/sources.list.d/rabbitmq.list

## Ubuntu 18.04:
echo &#34;deb https://packages.erlang-solutions.com/ubuntu bionic contrib&#34; | sudo tee /etc/apt/sources.list.d/rabbitmq.list

sudo apt update
sudo apt install erlang
```



## 安装 rabbitmq-c

使用 [rabbitmq-c](https://github.com/alanxz/rabbitmq-c)

```bash
sudo apt-get install libssl-dev

git clone https://github.com/alanxz/rabbitmq-c
cd rabbitmq-c
mkdir build
cd build
cmake ..
cmake --build .
make -j
sudo make install
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-07-22-hippo--%E7%BC%96%E8%AF%91%E9%A1%B9%E7%9B%AE/  

