# CentOS7:gcc7.3源代码编译升级


# 准备

把需要下载和解压的文件都放在一个目录

```bash
mkdir -p ~/gcc7
cd gcc7

## 下载 gcc7.3
wget https://mirrors.ustc.edu.cn/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz

## 下载依赖包
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2
wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz
wget https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
```

# 安装

```bash
tar -xvf gcc-7.3.0.tar.gz

## 依赖包都放进去
cp gmp-6.1.0.tar.bz2 ./gcc-7.3.0
cp mpc-1.0.3.tar.gz ./gcc-7.3.0
cp mpfr-3.1.4.tar.bz2 ./gcc-7.3.0

## 进入 gcc编译目录，把需要的依赖包解压到这一层次
tar jxvf gmp-6.1.0.tar.bz2
tar zxvf mpc-1.0.3.tar.gz
tar jxvf mpfr-3.1.4.tar.bz2

## 建立链接
ln -s gmp-6.1.0 gmp
ln -s mpfr-3.1.4 mpfr
ln -s mpc-1.0.3 mpc

## 开始编译，由于不是 root, 需要通过 --prefix 指定路径
./configure --disable-multilib --prefix=/home/trader/opt

## 开始安装，不要用 -j，可能会导致错误
make
make install
```

# 添加环境变量

```bash
export PATH=/home/trader/opt/bin:$PATH
export LD_LIBRARY_PATH=/home/trader/opt/lib:/usr/lib:$LD_LIBRARY_PATH
```



---

> 作者:   
> URL: https://williamlfang.github.io/archives/centos7gcc7.3%E6%BA%90%E4%BB%A3%E7%A0%81%E7%BC%96%E8%AF%91%E5%8D%87%E7%BA%A7/  

