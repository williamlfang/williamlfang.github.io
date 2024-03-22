# CentOS7 搭建私有 DockerHub


# 安装 Docker Register

```bash
## 使用 docker 进行 registry2 进行管理
docker pull registry

## 建立一个目录存放 docker 镜像, 默认是存放在 /tmp/registry
mkdir -p /data/Docker/registy
docker run --name docker.registry -d -p 5000:5000 -v /data/Docker/registy:/tmp/registry registry

docker ps -a

## 开启防火墙5000端口
systemctl restart firewalld.service
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --reload

## 测试访问
curl http://192.168.1.135:5000/v2/
```

&lt;!--more--&gt;

# 使用

```bash
## 测试
docker tag hello-world 192.168.1.135:5000/testing
docker push 192.168.1.135:5000/testing
```

# 远程

```bash
## 编辑 /etc/docker/daemon.json
## 添加 &#34;insecure-registries&#34; 里面的 &#34;docker.williamlfang.com:58080&#34;
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
    &#34;docker.williamlfang.com:58080&#34;
  ],
  &#34;debug&#34; : true,
  &#34;experimental&#34; : true,
  &#34;log-driver&#34;: &#34;json-file&#34;,
  &#34;log-opts&#34;: {
    &#34;max-size&#34;: &#34;1m&#34;,
    &#34;max-file&#34;: &#34;10&#34;
  }
}

sudo systemctl restart docker

## 获取镜像
docker pull docker.williamlfang.com:58080/testing

Using default tag: latest
latest: Pulling from testing
Digest: sha256:90659bf80b44ce6be8234e6ff90a1ac34acbeb826903b02cfa0da11c82cbc042
Status: Downloaded newer image for docker.williamlfang.com:58080/testing:latest
docker.williamlfang.com:58080/testing:latest
```





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-09-06-centos7-%E6%90%AD%E5%BB%BA%E7%A7%81%E6%9C%89-dockerhub/  

