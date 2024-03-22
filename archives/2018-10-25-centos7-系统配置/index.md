# CentOS7 系统配置


在服务器操作系统领域，`Linux` 绝对是独领风骚的佼佼者，拥有开放兼容的社区神态、功能强大的开发环境以及持续高效的运行性能。而作为 `Linux` 的重要分支，`CentOS` 则凭借稳定的性能，占领了大部分的大型企业级别服务器操作市场。因此，目前几乎所有的企业均在服务器上部署了 `CentOS` 操作系统。我们公司目前所有的服务器均安装 `CentOS7`，这是目前最新的版本，有足够强大的社区技术支持，同时也适合采用更加强大的新技术。


&lt;!--more--&gt;

接下来，我将根据开发经验，从安装操作系统开始，到如何配置相关文件，设定操作环境，到最后，我们将搭建一套强大的操作系统，用于开发并运行程序化交易系统。该过程将全部使用脚本进行操作，从而保证在任何一台服务器上，都达到完全一样的配置环境。

## 安装



## 配置

最近公司以我个人的名义采购了一台阿里云服务器，具体的云服务器配置如下：

- 单核CPU
- 2Gb Memory
- 40Gb SSD 存储空间
- 1Mb 专用下载网络

这个配置其实算比较低档次的，不过用于平时接收`CTP`行情数据倒是也可以够用。毕竟，价格优惠明显摆在那儿：三年使用期限，总共花费 279元。算是业内的良心价格了。

下面就要开始配置服务器了。对于 `CentOS7` 系统，这个配置过程基本类似，所以我就把以前写的一篇博客拿过来使用了。

### 设置远程服务器 root 密码

- 选择管理控制台，点击 `ECS`
- 选择 `实例`，然后找到 `更多`，点击 `重置密码`
- 修改完成密码后，记得需要点击选择 `重启` 才能够生效。我是在这一步忘记重启，结果掉坑里了。还好后来找到出口爬了出来。

### 增加用户/组

```bash
# 增加用户 trader
adduser trader

# 设置密码
passwd trader
```

### 设置固定(静态)IP

```bash
[root@localhost ~]# cd /etc/sysconfig/network-scripts/
[root@localhost network-scripts]# pwd
/etc/sysconfig/network-scripts
[root@localhost network-scripts]# ls -l ifcfg*
-rw-------. 1 root root 363 Dec 10 21:22 ifcfg-em1
-rw-------. 1 root root 449 Dec 10 21:21 ifcfg-em1.bak
-rw-r--r--. 1 root root 276 Dec 10 21:22 ifcfg-em2
-rw-r--r--. 1 root root 275 Dec 10 20:29 ifcfg-em3
-rw-r--r--. 1 root root 275 Dec 10 20:29 ifcfg-em4
-rw-r--r--. 1 root root 254 Aug 24 06:23 ifcfg-lo
[root@localhost network-scripts]#

vim ifcfg-em1

BOOTPROTO=static        //原是dhcp，改为static
ONBOOT=yes              //开机自启动
IPV6_PRIVACY=no
IPADDR=192.168.1.199    //设置固定IP
PREFIX=24
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=202.96.134.133
DNS2=202.96.128.68
PEERDNS=no
DNS3=202.96.134.33
ZONE=public
NM_CONTROLLED=no // 新增
DNS88=8.8.8.8 // 新增
DNS99=8.8.4.4 // 新增

## 重启网络
systemctl restart network
```

### 增加 `swap` 空间

&gt; 参考文章:[在阿里云CentOS 7创建swap分区](https://blog.tanteng.me/2016/03/aliyun-centos-7-swap/)

```bash
# 查看内存使用情况
free -h

# 增加 swap 空间
# 一般为系统配置内存的同等大小

# 1. 创建分区
dd if=/dev/zero of=/home/swap bs=1024 count=1048576

# 2. 格式化 swap 分区
mkswap /home/swap

# 3. 启动
swapon /home/swap

# 4.swap分区自动挂载
vim /etc/fstab

# 在文件末尾加上

/home/swap swap swap default 0 0
```

### 时间校准

[简单几步让CentOS系统时间同步](https://blog.csdn.net/z_dianjun/article/details/51819450)

```bash
yum install -y ntpdate

cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate us.pool.ntp.org

crontab -e
0-59/10 * * * * /usr/sbin/ntpdate us.pool.ntp.org | logger -t NTP
```

### 增加常用 yum 源

```bash
## 配置下centos的DNS
## 一个国内,一个国外
vim /etc/resolv.conf

nameserver 114.114.114.114
nameserver 8.8.8.8

# 备份
cd /etc/yum.repos.d/
mkdir repo_bk
mv *.repo repo_bk/

# 添加阿里源
wget http://mirrors.aliyun.com/repo/Centos-7.repo

## 网易yum源:
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum clean all
yum makecache

## 阿里云yum源:
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

## epel源
yum -y install epel-release
yum clean all
yum makecache

ls

# 清除系统所有的yum缓存
yum clean all

# 生成yum缓存
yum makecache

# 安装 EPEL
yum install -y epel-release

# 下载阿里开源镜像的epel源文件
wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo

ls

# 再次清除系统yum缓存，并重新生成新的yum缓存
yum clean all &amp;&amp; yum makecache
```

### 安装常用软件包

```bash
yum install -y cmake bzip2 htop

yum -y install gcc gcc-c&#43;&#43; kernel-devel  git cmake
## -----------------------------------------------
## sudo apt-get install libboost-all-dev
## apt search boost
## sudo apt install libboost-all-dev
## -----------------------------------------------
yum -y install python-devel libxslt-devel libffi-devel openssl-devel
yum -y install python-pip

# 完成 CMAKE 配置
yum install gcc-c&#43;&#43;

# 安装 mysql
yum install mysql
yum install mariadb-server mariadb
yum install mysql-devel

## 启动 mariadb.service 引擎
systemctl start|stop|restart mariadb.service
```


## 运维

### `MySQL/MariaDB` 数据库管理

#### 安装 `MariaDB` 引擎

```bash
# 安装 mysql
yum install mysql
yum install mariadb-server mariadb
yum install mysql-devel

## 启动 mariadb.service 引擎
systemctl start|stop|restart mariadb.service
```

#### 增加远程访问端口 `3306`

```bash
## 增加远程访问 MySQL 3306 端口

# 1.FirewallD防火墙开放3306端口
firewall-cmd --zone=public --add-port=3306/tcp --permanent

# 2.重启防火墙
systemctl restart firewalld.service
```

centos7 使用的是FirewallD防火墙。FirewallD 是 iptables 的前端控制器，用于实现持久的网络流量规则。它提供命令行和图形界面，在大多数 Linux 发行版的仓库中都有。

- `--zone`：作用域
- `--add-port=3306/tcp`：添加端口，格式为：端口/通讯协议
- `--permanent`：永久生效，没有此参数重启后失效


#### 设置允许访问的最大连接数

连接 `MySQL` 数据库后，会自动分配一个连接点，并在关闭该连接后进行注销。但是，如果由于用户忘记关闭，或者程序错误导致没有把之前分配的连接点注销，长期以往，则可能超过当前允许的最大连接数量，导致新开连接失败。这时候数据库会报错：

```bash
&#34;SQL Error 1040: Too Many Connection&#34;
```

解决的思路当然是尽量调高系统运行的最大连接数。有两种方法可以完成。

##### 临时增加最大连接数
&gt; Ref: https://stackoverflow.com/questions/14331032/mysql-error-1040-too-many-connection/34176072

这种方法只是临时改变 最大连接数, 真正重启 MySQL 后还是恢复成默认的连接数。

```sql
show variables like &#34;max_connections&#34;;
set global max_connections = 2000;
```

##### 永久增加最大连接数
&gt; Ref: https://www.cnblogs.com/kevingrace/p/6226324.html

这种方法通过修改操作系统的参数，达到永久改变最大连接数的目的。

```bash
## 1. 这是由于mariadb有默认打开文件数限制。-----------------------------------------
## 可以通过配置/usr/lib/systemd/system/mariadb.service来调大打开文件数目。

vim /usr/lib/systemd/system/mariadb.service

[Service]
## mysql
LimitNOFILE=10000
LimitNPROC=10000

##重新加载系统服务，并重启mariadb服务
systemctl --system daemon-reload
systemctl restart mariadb.service

## 2. 配置/etc/my.cnf ----------------------------------------------------------
## 修改 my.cnf 配置文件

vim /etc/my.cnf

[mysqld]
max_connections = 10000

## 重启后生效
systemctl restart mariadb.service
```

再次查看一下，确认已经修改成较大的连接数了。

```sql
show variables like &#34;max_connections&#34;;
show variables like &#39;%open_files_limit%&#39;;
```

#### 修改 `root` 账户密码

```sql
## 更改 root 密码
mysqladmin -u root password MyNewPassword

mysql -u root
UPDATE mysql.user SET Password=PASSWORD(&#39;MyNewPassHere&#39;) WHERE User=&#39;root&#39;;
FLUSH PRIVILEGES;
quit;

mysql -u root -pMyNewPassHere
```

#### 数据库用户管理

```sql
## 增加用户
create user &#39;trader&#39;@&#39;localhost&#39; identified by &#39;************&#39;;

## 分配数据库权限
grant all/select/write on dbName.tbName to &#39;userID&#39;@&#39;%&#39; identified by &#39;userPassword&#39;;

## 收回用户权限
```

#### 设置密码安全
&gt; Ref:
&gt;
&gt; -   [myTask](https://github.com/williamlfang/myTask/blob/master/Tasks/20180121-20180127-%E4%BA%A4%E6%98%93%E7%B3%BB%E7%BB%9F%E4%BC%98%E5%8C%96.todo)
&gt; -   http://blog.csdn.net/kuluzs/article/details/51924374

在 `MySQL 5.5` 以后，强化了对账户密码安全性的检查。对于一般的*弱密码*，可能无法通过检验。不过，我们可以进行相关的配置。

```sql
set global validate_password_policy=0;
set global validate_password_mixed_case_count=0;
set global validate_password_number_count=3;
set global validate_password_special_char_count=0;
set global validate_password_length=3;
```

#### 彻底解决mysql中文乱码

```bash
## Ref: https://blog.csdn.net/u012410733/article/details/61619656

vim /etc/my.cnf

## 增加以下字段

[mysqld]
character-set-server=utf8
[client]
default-character-set=utf8
[mysql]
default-character-set=utf8
```


### 安装 `Boost 1.55`

`Boost.Python` 提供了通过 `Python` 调用 `C/C&#43;&#43;` 的方法，通过封装 `C/C&#43;&#43;` 给 `Python` 函数调用。

```bash
cd temp

## 下载文件
wget -O boost_1_55_0.tar.bz2 http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F1.55.0%2F&amp;ts=1385953406&amp;use_mirror=softlayer-ams

## 检查完整性
file boost_1_55_0.tar.bz2

## 解压
tar jxvf boost_1_55_0.tar.bz2

ls

## 开始编译、并安装软件包
cd boost_1_55_0

./bootstrap.sh

./b2 &amp;&amp; ./b2 install
```

有一个很奇怪的错误，在执行 `./b2` 的时候，会报错

```bash
libs/iostreams/src/bzip2.cpp:20:56: fatal error: bzlib.h: No such file or directory
```

这是因为没有安装 `bzip2`。可以使用命令来查找

```bash
[root@localhost boost_1_55_0]# yum search bzip2
Loaded plugins: fastestmirror, langpacks
Repository base is listed more than once in the configuration
Repository updates is listed more than once in the configuration
Repository extras is listed more than once in the configuration
Repository centosplus is listed more than once in the configuration
Repository contrib is listed more than once in the configuration
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * epel: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
========================================================================== N/S matched: bzip2
===========================================================================
bzip2-devel.i686 : Libraries and header files for apps which will use bzip2
bzip2-devel.x86_64 : Libraries and header files for apps which will use bzip2
bzip2-libs.i686 : Libraries for applications using bzip2
bzip2-libs.x86_64 : Libraries for applications using bzip2
lbzip2.x86_64 : Fast, multi-threaded bzip2 utility
lbzip2-utils.x86_64 : Utilities for working with bzip2 compressed files
mingw32-bzip2.noarch : 32 Bit version of bzip2 for Windows
mingw32-bzip2-static.noarch : Static library for mingw32-bzip2 development
mingw64-bzip2.noarch : 64 Bit version of bzip2 for Windows
mingw64-bzip2-static.noarch : Static library for mingw64-bzip2 development
pbzip2.x86_64 : Parallel implementation of bzip2
perl-Compress-Raw-Bzip2.x86_64 : Low-level interface to bzip2 compression library
bzip2.x86_64 : A file compression utility
python2-bz2file.noarch : Read and write bzip2-compressed files

Name and summary matches only, use &#34;search all&#34; for everything.

yum -y install bzip2-devel.x86_64
```

然后重新运行 `./b2 &amp;&amp; ./b2 install` 即可安装 `boost`。


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-10-25-centos7-%E7%B3%BB%E7%BB%9F%E9%85%8D%E7%BD%AE/  

