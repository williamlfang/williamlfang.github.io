# 在古早 CentOS7.6 机器安装 Docker



公司有一台退役的古早机器安装的操作系统是 `CentOS7.6`，软件源已经几年没有更新了，基本上已经到达无法使用的地步了。现在需要在这上面搞交易运维（tmd真抠），所以要安装 Docker，以适应新的软件开发环境。

&lt;!--more--&gt;


## 安装依赖包

需要的 `rpm` 可以在这里找到: https://mirrors.aliyun.com/centos-vault/7.9.2009/extras/x86_64/Packages/

```bash
wget https://mirrors.aliyun.com/centos-vault/7.9.2009/extras/x86_64/Packages/slirp4netns-0.4.3-4.el7_8.x86_64.rpm
wget https://linuxsoft.cern.ch/cern/centos/7/extras/x86_64/Packages/fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm

yum localinstall fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm
yum localinstall slirp4netns-0.4.3-4.el7_8.x86_64.rpm
```

## Docker

```bash

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo sed -i &#39;s/download.docker.com/mirrors.aliyun.com\/docker-ce/g&#39; /etc/yum.repos.d/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io

## 启动服务
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker

## 建立 docker 组
sudo groupadd docker
## 把当前用户添加到 docker 组
sudo usermod -aG docker $USER

## 牛刀小试
docker run hello-world
```

## 赠送一份可以用的 CentOS-Base.repo

```bash
yum clean all
yum makecache
yum update
```

```
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-7.6.1810 - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-7.6.1810 - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-7.6.1810 - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-7.6.1810 - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#contrib - packages by Centos Users
[contrib]
name=CentOS-7.6.1810 - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-17-%E5%9C%A8%E5%8F%A4%E6%97%A9-centos7.6-%E6%9C%BA%E5%99%A8%E5%AE%89%E8%A3%85-docker/  

