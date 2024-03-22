# lbzip2 多线程并行压缩、解压



lbzip2 实现了多线程进行压缩、解压。

# 安装

```bash
wget https://launchpad.net/ubuntu/&#43;archive/primary/&#43;sourcefiles/lbzip2/2.5-2/lbzip2_2.5.orig.tar.bz2

tar -xvf lbzip2_2.5.orig.tar.bz2
cd lbzip2-2.5

sudo ./configure --prefix=/usr
sudo make -j
sudo make install
```
&lt;!--more--&gt;

# 对比

演示文件信息

```bash
-rw-r--r--.  1 1001 1001  5.2G Apr 14 15:15 20200414.csv
-rw-r--r--.  1 root hy   1007M Apr 15 10:58 20200414.tar.bz2
```



## lbzip2

```bash
time tar -cvf - 20200414.csv | lbzip2  &gt; 20200414.tar.bz2

real    0m19.618s
user    9m48.298s
sys     0m22.568s
```

## pbzip2

```bash
time tar -cvf - 20200414.csv | pbzip2  &gt; 20200414.tar.bz2

real    0m52.157s
user    21m41.673s
sys     0m32.150s

```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-15-lbzip2-%E5%A4%9A%E7%BA%BF%E7%A8%8B%E5%B9%B6%E8%A1%8C%E5%8E%8B%E7%BC%A9%E8%A7%A3%E5%8E%8B/  

