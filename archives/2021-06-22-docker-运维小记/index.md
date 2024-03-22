# Docker 运维小记


# 安装 Docker

## 删除旧版本

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

&lt;!--more--&gt;

## 添加软件源

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update
```

## 安装

```bash
sudo yum install docker.io
```

或者使用国内 daocloud 一键安装命令：

```bash
## daocloud
curl -sSL https://get.daocloud.io/docker | sh
```



# 搭建私有 DockerHub

## 建立 registry

```bash
## 使用 docker 进行 registry2 进行管理
docker pull registry
## 建立一个目录存放 docker 镜像, 默认是存放在 /tmp/registry
## 为了防止不小心删掉，我们将其挂载到 /data/Docker/registry 这个目录下
mkdir -p /data/Docker/registy
docker run --name docker.registry \
	-d -p 5000:5000 \
	-v /data/Docker/registy:/tmp/registry \
	registry

docker ps -a
## 开启防火墙5000端口
systemctl restart firewalld.service
firewall-cmd --zone=public --permanent--add-port=5000/tcp
firewall-cmd --reload

## 如果出现错误
## -i docker0: iptables: no chain/target/match by that name.
## Ref:https://blog.csdn.net/xujiamin0022016/article/details/108124725
systemctl restart docker

## 测试访问
curl http://127.0.0.1:5000/v2/
## 返回 {} 说明正常运行了
```

## 配置

需要配置 `daemon.json` 允许访问本地使用 DockerHub

```bash
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
    &#34;docker.mirrors.ustc.edu.cn&#34;,
    &#34;192.168.1.183:5000&#34;
  ],
  &#34;debug&#34; : true,
  &#34;experimental&#34; : true,
  &#34;log-driver&#34;: &#34;json-file&#34;,
  &#34;log-opts&#34;: {
    &#34;max-size&#34;: &#34;1m&#34;,
    &#34;max-file&#34;: &#34;10&#34;
  }
}
```

这里需要注意需要重启 docker 服务

```bash
systemctl restart docker
```

## 测试

```bash
## 查看当前有哪些 images
docker image ls

docker tag hello-world 192.168.1.183:5000/testing
docker push 192.168.1.183:5000/testing
docker push 192.168.1.183:5000/testing

## 可以看一下是不是有这个 repo 了
curl http://192.168.1.183:5000/v2/_catalog
```



# 常用命令



# 编写 Dockerfile

## Centos7.9

可以使用一下的模板来编写一个测试使用的 `CentOS7` 开发环境

&gt; 查看 centos https://hub.docker.com/_/centos?tab=tags&amp;page=1&amp;ordering=last_updated

```bash
FROM centos:centos7.9.2009

MAINTAINER WuyaCapital
LABEL Remarks=&#34;CentOS7.9 Develop&amp;Testing Environment @WuyaCapital&#34;

RUN yum -y install \
	sudo vim git make cmake htop\
    gcc gcc-c&#43;&#43; kernel-devel \
    openssl-devel libcurl-devel
RUN mkdir -p /shared/trading /data

ENV PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
ENV LANG=en_US.UTF-8
ENV BASH_ENV=~/.bashrc  \
    ENV=~/.bashrc \
    PROMPT_COMMAND=&#34;source ~/.bashrc&#34;

EXPOSE 22 80
WORKDIR /home
CMD /bin/bash
```

命令说明：

- `CMD`

  指定容器启动时执行的命令，注意，和RUN的区别是：RUN是在打包过程中执行的命令。镜像中只能有一条CMD指令，**如果有多个CMD指令**，则以最后一条为准，所以我们可以覆盖基础镜像中定义的CMD指令。CMD指令支持三种格式：

  - `CMD [&#34;executable&#34;, &#34;param1&#34;, &#34;param2&#34;]` 使用exec执行，这是使用*CMD*的首选方法
  - `CMD command param1 param2` 使用`/bin/sh -c`执行
  - `CMD [&#34;param1&#34;, &#34;param2&#34;]` 提供给ENTRYPOINT的默认参数

  注意，指定了`CMD`命令以后，`docker container run`命令就不能附加命令了（比如前面的`/bin/bash`），否则它会覆盖`CMD`命令。

- `ENTRYPOINT`

  容器启动入口，即容器启动后执行的命令，不会被CMD指令覆盖，如果存在ENTRYPOINT，那么CMD指令会充当ENTRYPOINT的参数。



## 搭建

```bash
docker build -t wuya-centos7:v1.0 .

docker image ls

## 使用 REPOSITORY:TAG
## 使用 -v 可以挂载主机文件
docker run --name mycentos7 --net=host -dit wuya-centos7:v1.0

## 启动实例
docker exec -it mycentos7 /bin/bash
```

# 发布 Docker

## 打包一个容器

```bash
docker commit -a &#34;william&#34; -m &#34;wuya-centos7:v1.0&#34; [container_id] image_id:version
```

当然，也可以直接打包成一个压缩包

```bash
## 打包
docker save wuya-centos7:v1.0 &gt; mycetnos7.tar

## 加载
docker load -i mycetnos7.tar
```

我们也可以选择发布到 Dockerhub

```bash
docker tag wuya-centos7:v1.0 192.168.1.183:5000/wuya/centos7:v1.0
docker push 192.168.1.183:5000/wuya/centos7:v1.0
docker pull 192.168.1.183:5000/wuya/centos7:v1.0

curl http://192.168.1.183:5000/v2/_catalog
curl http://192.168.1.183:5000/v2/wuya/centos7/tags/list
```

这样，我们可以建立一个新的容器了

```bash
## 记得修改 vim  /etc/docker/daemon.json
docker pull 192.168.1.183:5000/wuya/centos7:v1.0
docker image ls
docker run -dit --name testing 192.168.1.183:5000/wuya/centos7:v1.0
docker ps -a
docker exec -it testing /bin/bash
```

# Q&amp;A

## build 的时候无法使用 pip 直接安装程序

&gt; 这个是因为 Docker 的 DNS 没有识别到，需要处理一下。

Ref:[[Can&#39;t install pip packages inside a docker container with Ubuntu](https://stackoverflow.com/questions/28668180/cant-install-pip-packages-inside-a-docker-container-with-ubuntu)](https://stackoverflow.com/questions/28668180/cant-install-pip-packages-inside-a-docker-container-with-ubuntu)

```bash
## 编辑
sudo vim /etc/default/docker
## 添加 DNS
DOCKER_OPTS=&#34;--dns 8.8.8.8&#34;

## 重启
sudo systemctl restart docker
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-06-22-docker-%E8%BF%90%E7%BB%B4%E5%B0%8F%E8%AE%B0/  

