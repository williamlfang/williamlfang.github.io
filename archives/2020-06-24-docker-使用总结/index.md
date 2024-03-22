# Docker 使用总结



`Docker` 一些实用技巧。
&lt;!--more--&gt;

# 安装



## Ubuntu

`Ubuntu` 操作系统的安装步骤可以参考[官网说明](https://docs.docker.com/engine/install/ubuntu/)

1. 卸载旧版本

    ```bash
    sudo apt-get remove docker docker-engine docker.io containerd runc

    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    Package &#39;docker-engine&#39; is not installed, so not removed
    Package &#39;docker&#39; is not installed, so not removed
    Package &#39;containerd&#39; is not installed, so not removed
    Package &#39;docker.io&#39; is not installed, so not removed
    Package &#39;runc&#39; is not installed, so not removed
    0 upgraded, 0 newly installed, 0 to remove and 43 not upgraded.
    ```

2. 添加软件源

    ```bash
    sudo apt-get update

    sudo apt-get install \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg-agent \
       software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    echo $(lsb_release -cs)
    Linux Mint Releases
    Version	Codename	Package base
    19.1	Tessa	Ubuntu Bionic
    19	Tara	Ubuntu Bionic
    18.3	Sylvia	Ubuntu Xenial
    18.2	Sonya	Ubuntu Xenial

    # sudo add-apt-repository &#34;deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable&#34;
    sudo add-apt-repository &#34;deb [arch=amd64] https://download.docker.com/linux/ubuntu Bionic stable&#34;
    ```



3. 开始安装

    ```bash
    sudo apt-get update
    sudo apt install docker.io
    ```

4. 设置启动服务

    ```bash
    sudo systemctl start docker

    ## 添加开机启动
    sudo systemctl enable docker
    ```

5. 查看 `Docker` 版本

    ```bash
    docker --version

    Docker version 19.03.6, build 369ce74a3c
    ```

6. `Docker` 后台服务需要具有 `sudo` 权限。为了避免每次命令都输入`sudo`，可以把用户加入 Docker 用户组（[官方文档](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user)）。

    ```bash
    ## 建立 docker 组
    sudo groupadd docker
    ## 把当前用户添加到 docker 组
    sudo usermod -aG docker $USER
    ```

    然后先退出账户(logout)，再次登录(login)即可使用 `docker` 命令了

7. 运行试试看

    ```bash
    docker run hello-world

    Unable to find image &#39;hello-world:latest&#39; locally

    latest: Pulling from library/hello-world
    0e03bdcc26d7: Pull complete
    Digest: sha256:d58e752213a51785838f9eed2b7a498ffa1cb3aa7f946dda11af39286c3db9a9
    Status: Downloaded newer image for hello-world:latest

    Hello from Docker!
    This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
    1. The Docker client contacted the Docker daemon.
    2. The Docker daemon pulled the &#34;hello-world&#34; image from the Docker Hub.
       (amd64)
    3. The Docker daemon created a new container from that image which runs the
       executable that produces the output you are currently reading.
    4. The Docker daemon streamed that output to the Docker client, which sent it
       to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
    $ docker run -it ubuntu bash

    Share images, automate workflows, and more with a free Docker ID:
    https://hub.docker.com/

    For more examples and ideas, visit:
    https://docs.docker.com/get-started/
    ```

    如果还有出现以下的报错，需要修改权限

    ```bash
    WARNING: Error loading config file: /home/william/.docker/config.json: stat /home/william/.docker/config.json: permission denied

    sudo chown william:william /home/william/.docker -R
    ```



8. 由于某些原因，国内访问 `Docker` 的软件源速度是比较慢的。幸好，我们可以更改指定的源，使用国内阿里云或者网易可以大大的加速访问速度。

    ```bash
    ## 修改 docker 配置文件
    sudo vim /etc/docker/daemon.json

    {
     &#34;registry-mirrors&#34; : [
       &#34;http://ovfftd6p.mirror.aliyuncs.com&#34;,
       &#34;http://registry.docker-cn.com&#34;,
       &#34;http://docker.mirrors.ustc.edu.cn&#34;,
       &#34;http://hub-mirror.c.163.com&#34;
     ],
     &#34;insecure-registries&#34; : [
       &#34;registry.docker-cn.com&#34;,
       &#34;docker.mirrors.ustc.edu.cn&#34;
     ],
     &#34;debug&#34; : true,
     &#34;experimental&#34; : true
    }

    sudo systemctl restart docker.service
    ```

## CentOS



1. 删除旧版本

    ```bash
    sudo yum remove docker \
                     docker-client \
                     docker-client-latest \
                     docker-common \
                     docker-latest \
                     docker-latest-logrotate \
                     docker-logrotate \
                     docker-engine
    ```

2. 添加软件源

    ```bash
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    sudo yum update
    ```

3. 安装

    ```bash
    sudo yum install docker.io
    ```

4. 也可以使用国内 daocloud 一键安装命令：

    ```
    ## 阿里
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

    ## daocloud
    curl -sSL https://get.daocloud.io/docker | sh
    ```

5. 加入 docker 用户组命令

    ```bash
    sudo usermod -aG docker trader
    ```

6. 添加启动

    ```bash
    sudo systemctl enable docker
    sudo systemctl start docker
    ```

7. 运行测试

    ```bash
    sudo docker run hello-world
    ```



# 基础概念

# 编写 Dockerfile

可以使用一下的模板来编写一个测试使用的 `CentOS7` 开发环境

```dockerfile
FROM centos:7

MAINTAINER WilliamFang
LABEL Remarks=&#34;CentOS7.5 Develop&amp;Testing Environment&#34;

RUN yum -y install vim git sudo &amp;&amp; yum -y install make &amp;&amp; \
    yum -y install gcc gcc-c&#43;&#43; kernel-devel &amp;&amp; \
    yum -y install cmake bzip2 htop tldr pigz pbzip2 &amp;&amp; \
    yum -y install bzip2-devel.x86_64 &amp;&amp; \
    yum -y install libxslt-devel libffi-devel openssl-devel libcurl-devel

ENV PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
ENV LANG=en_US.UTF-8
ENV BASH_ENV=~/.bashrc  \
    ENV=~/.bashrc  \
    PROMPT_COMMAND=&#34;source ~/.bashrc&#34;
```

然后使用命令开始搭建

```bash
sudo docker build -t myctp:v1.0 .
```

然后就可以看到

```bash
docker image ls

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
myctp               v1.0                91b0c32f2935        2 minutes ago       564MB
centos              7                   b5b4d78bc90c        7 weeks ago         203MB
```

现在，我们就可以愉快的使用 `Docker` 进行测试了

```bash
## 查看当前运行的 docker container
docker ps -a

CONTAINER ID    IMAGE    COMMAND    CREATED    STATUS    PORTS    NAMES
```

说明当前还没有生成相应的实例。我们可以启动使用命令启动

```bash
## 使用 REPOSITORY:TAG
## 使用 -v 可以挂载主机文件
docker run -dit -v /home/william:/mnt myctp:v1.0 /bin/bash

CONTAINER ID    IMAGE       COMMAND         CREATED         STATUS          PORTS   NAMES
2b40845d0309    myctp:v1.0  &#34;/bin/bash&#34;     4 seconds ago   Up 3 seconds            upbeat_montalcini

docker run --name rshiny -dit -e USER=rshiny -e PASSWORD=ilovewuya -p 58787:8787 -p 53838:3838 wuya-centos7:v1.0
## 添加用户，需要进入 docker 添加用户
docker exec -it rshiny /bin/bash
sudo adduser tester
sudo passwd tester
```

然后开始启动

```bash
## 挂载到实例
docker exec -it b3c220b3c9c6 /bin/bash

[root@b3c220b3c9c6 /]# whoami
root

[root@b3c220b3c9c6 /]# gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/libexec/gcc/x86_64-redhat-linux/4.8.5/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-bootstrap --enable-shared --enable-threads=posix --enable-checking=release --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-linker-hash-style=gnu --enable-languages=c,c&#43;&#43;,objc,obj-c&#43;&#43;,java,fortran,ada,go,lto --enable-plugin --enable-initfini-array --disable-libgcj --with-isl=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/isl-install --with-cloog=/builddir/build/BUILD/gcc-4.8.5-20150702/obj-x86_64-redhat-linux/cloog-install --enable-gnu-indirect-function --with-tune=generic --with-arch_32=x86-64 --build=x86_64-redhat-linux
Thread model: posix
gcc version 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC)
[root@b3c220b3c9c6 /]#
```

退出会依然可以看到程序在运行中

```bash
CONTAINER ID    IMAGE       COMMAND         CREATED         STATUS          PORTS   NAMES
b3c220b3c9c6    myctp:v1.0  &#34;/bin/bash&#34;     2 minutes ago   Up 2 minutes            gallant_bell
```

## 删除

```bash
## 列出所有
docker ps -aq
#＃ 删除指定 id
docker rm
## 删除 image
docker rmi
```



列出所有容器 ID

```
docker ps -aq
```

查看所有运行或者不运行容器

```
docker ps -a
```

停止所有的 container（容器），这样才能够删除其中的 images：

```
docker stop $(docker ps -a -q) 或者 docker stop $(docker ps -aq)
```

如果想要删除所有 container（容器）的话再加一个指令：

```
docker rm $(docker ps -a -q) 或者 docker rm $(docker ps -aq)
```

查看当前有些什么 images

```
docker images
```

删除 images（镜像），通过 image 的 id 来指定删除谁

```
docker rmi &lt;image id&gt;
```

想要删除 untagged images，也就是那些 id 为的 image 的话可以用

```
docker rmi $(docker images | grep &#34;^&lt;none&gt;&#34; | awk &#34;{print $3}&#34;)
```

要删除全部 image（镜像）的话

```
docker rmi $(docker images -q)
```

强制删除全部 image 的话

```
docker rmi -f $(docker images -q)
```

从容器到宿主机复制

```
docker cp tomcat：/webapps/js/text.js /home/admin
 docker  cp 容器名:  容器路径       宿主机路径
```

从宿主机到容器复制

```
docker cp /home/admin/text.js tomcat：/webapps/js
 docker cp 宿主路径中文件      容器名  容器路径
```

删除所有停止的容器

```
docker container prune
```

删除所有不使用的镜像

```
docker image prune --force --all或者docker image prune -f -a
```

停止、启动、杀死、重启一个容器

```
docker stop Name或者ID
docker start Name或者ID
docker kill Name或者ID
docker restart name或者ID
```



# 发布 docker

为了方便移植，`Docker` 允许我们通过两个方式来分享配置好的运行环境。

## Docker Hub

通过使用 `Docker Hub` 来发布。

## 提交

```bash
docker commit -a &#34;william&#34; -m &#34;myctp:v0.1&#34; -p myctp.new myctp:v0.1
```

## 导出

```bash
docker save -o myctp.v0.1.tar myctp:v0.1
```

## 导入

```bash
docker run -d --name myctp -it -v /home/william:/mnt myctp:v0.1 /bin/zsh
```



## 运行

````bash
docker exec -it myctp.new /bin/zsh
````

## 提交 Docker Hub

```bash
docker login
UserName: williamlfnag
Password: ************

## 标记需要处理的image
docker tag myctp:v0.1.2 williamlfang/myctp


REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
myctp                v0.1.2              9c41f991a440        13 minutes ago      4.57GB
williamlfang/myctp   latest              9c41f991a440        13 minutes ago      4.57GB
myctp                v0.1.1              59c7bc923b02        3 days ago          4.02GB
myctp                v0.1                e8a31774a8c6        4 days ago          2.49GB
centos               7                   b5b4d78bc90c        8 weeks ago         203MB

docker push williamlfang/myctp

docker pull williamlfang/myctp
```

# 使用 `williamlfang`

```bash
## 显示当前可用镜像
docker image ls

## 如果没有 williamlfang/myctp
docker pull williamlfang/myctp

## 再次确认已经下载到本地
docker image ls

## 基于此镜像生成 container
docker run -d --name myctp.dockerhub -it williamlfang/myctp /bin/zsh
## 查看 docker 目前的所有 container
docker ps -a


CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS                       PORTS               NAMES
dcc7924f4c1a        williamlfang/myctp   &#34;/bin/zsh&#34;          4 seconds ago       Up 3 seconds                                     myctp.dockerhub
c57d4de5205b        f03a8c4cf617         &#34;/bin/zsh&#34;          12 days ago         Exited (255) 4 minutes ago                       myctp
b50399b23d5b        myctp:v0.1           &#34;/bin/zsh&#34;          13 days ago         Exited (137) 13 days ago                         myctp.test
11953e12a6b5        e2c0099752c8         &#34;/bin/zsh&#34;          13 days ago         Exited (137) 13 days ago                         myctp.new

## 进入 container 操作
docker exec -it myctp.dockerhub /bin/zsh
```

以下就是进入我们的操作系统后的截图显示

```bash
⚡ root@centos7  /  j myctp
anaconda-post.log  bin  data  dev  etc  home  lib  lib64  log  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

/root/myCTP
build  CMakeLists.txt  config  CTP踩坑记.md  data  deps  include  libs  log  scripts  src

⚡ root@centos7  myCTP  ll
build  CMakeLists.txt  config  CTP踩坑记.md  data  deps  include  libs  log  scripts  src

total 64K
drwxr-xr-x 11 root root 4.0K Jul  4 17:06 .
dr-xr-x---  1 root root 4.0K Jul 13 17:27 ..
drwxr-xr-x  4 root root 4.0K Jul  4 16:59 build
-rw-r--r--  1 root root 5.6K Jul  4 16:51 CMakeLists.txt
drwxr-xr-x  2 root root 4.0K Jul  4 16:37 config
-rw-r--r--  1 root root 5.0K Jul  4 16:37 CTP踩坑记.md
drwx------  3 root root 4.0K Jul  4 17:06 data
drwxr-xr-x  5 root root 4.0K Jul  4 16:42 deps
drwxr-xr-x 10 root root 4.0K Jul  4 16:37 include
drwxr-xr-x 11 root root 4.0K Jul  4 16:59 libs
drwx------  4 root root 4.0K Jul  4 17:06 log
drwxr-xr-x  2 root root 4.0K Jul  4 16:39 scripts
drwxr-xr-x 10 root root 4.0K Jul  4 16:37 src
```



# 使用技巧

可以执行变量名称

```bash
## 增加额外运行参数
docker run -d \
	--name ctpmd -it \
	--restart=always \
	--log-driver json-file \
	--log-opt max-size=1000m \
	--log-opt max-file=30 \
	--network=&#34;host&#34; \
	--ipc=&#34;host&#34; \
	-e ACCOUNT=local_simnow \
	-v /home/william/mkdata:/data \
	registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

## 重新打 tag
docker tag 8557026cb47e[原来的image id] registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

## 报错无法删除
## Ref: https://stackoverflow.com/questions/38118791/can-t-delete-docker-image-with-dependent-child-images
docker rmi $(docker images --filter &#34;dangling=true&#34; -q --no-trunc)
docker rmi c565603bc87f

# 设置日志文件

docker tag 29db0d77705f  registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

docker push registry.corp.highfortfunds.com/highfort/ctpmd:v0.1
docker pull registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

docker run -d \
	--name ctpmd -it \
	--restart=always \
	--log-driver json-file \
	--log-opt max-size=1000m \
	--log-opt max-file=30 \
	--network=&#34;host&#34; \
	--ipc=&#34;host&#34; \
	-e ACCOUNT=colo_gtja \
	-v /data:/data \
	registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

docker run -d \
	--name ctpmd -it \
	--restart=always \
	--log-driver json-file \
	--log-opt max-size=1000m \
	--log-opt max-file=30 \
	--network=&#34;host&#34; \
	--ipc=&#34;host&#34; \
	-e ACCOUNT=local_hf \
	-v /data:/data \
	registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

docker run -d \
	--name ctpmd -it \
	--restart=always \
	--log-driver json-file \
	--log-opt max-size=1000m \
	--log-opt max-file=30 \
	--network=&#34;host&#34; \
	--ipc=&#34;host&#34; \
	-e ACCOUNT=local_zz \
	-v /data:/data \
	registry.corp.highfortfunds.com/highfort/ctpmd:v0.1

docker exec -it ctpmd /bin/bash
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-06-24-docker-%E4%BD%BF%E7%94%A8%E6%80%BB%E7%BB%93/  

