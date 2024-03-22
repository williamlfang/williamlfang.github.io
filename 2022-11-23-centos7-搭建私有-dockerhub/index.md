# CentOS7 搭建私有 DockerHub


搭建企业内部使用的仓库。

&lt;!--more--&gt;


# 安装 Docker Register

```bash
## 使用 docker 进行 registry2 进行管理
docker pull registry

## 建立一个目录存放 docker 镜像, 默认是存放在 /tmp/registry
mkdir -p /data/Docker/registy
docker run --name docker.registry -d -p 5000:5000 -v /data/Docker/registy:/tmp/registry --restart unless-stopped  registry

docker update --restart=always &lt;contaier_id&gt;

docker ps -a

## 开启防火墙5000端口
systemctl restart firewalld.service
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --reload

## 测试访问
curl http://192.168.1.135:5000/v2/
```

# 使用

```bash
## 测试
docker tag hello-world 192.168.1.135:5000/testing
docker push 192.168.1.135:5000/testing

## 查看所有镜像
curl http://10.32.111.107:5000/v2/_catalog
## 查看镜像的所有tag
curl http://10.32.111.107:5000/v2/william-centos7-gcc9/tags/list
```

# 远程

如果出现报错

```bash
http: server gave HTTP response to HTTPS client
```

对于 `CentOS` 需要修改：

```bash
vim /usr/lib/systemd/system/docker.service

## 添加 --insecure-registry 10.32.111.107:5000
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock  --insecure-registry 10.32.111.107:5000
```

或者可以直接修改（如果是空的，需要创建）

```bash
## 编辑 /etc/docker/daemon.json
## 添加 &#34;insecure-registries&#34; 里面的 &#34;docker.williamlfang.com:58080&#34;
sudo vim /etc/docker/daemon.json

{
  &#34;registry-mirrors&#34; : [
    &#34;https://mirror.baidubce.com&#34;,
    &#34;http://ovfftd6p.mirror.aliyuncs.com&#34;,
    &#34;http://registry.docker-cn.com&#34;,
    &#34;http://hub-mirror.c.163.com&#34;
  ],
  &#34;insecure-registries&#34; : [
    &#34;registry.docker-cn.com&#34;,
    &#34;docker.mirrors.ustc.edu.cn&#34;,
    &#34;docker.williamlfang.com:58080&#34;,
    &#34;192.168.1.88:5000&#34;,
    &#34;192.168.1.183:5000&#34;,
    &#34;10.32.111.107:5000&#34;
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


# 添加账户密码认证

## 安装 htpasswd

```bash
sudo yum install -y httpd-tools
mkdir /etc/docker/auth
htpasswd -Bbn tradeops passwd &gt; /etc/docker/auth/htpasswd

## 测试是否需要认证
curl http://192.168.1.88:5000/v2/
{&#34;errors&#34;:[{&#34;code&#34;:&#34;UNAUTHORIZED&#34;,&#34;message&#34;:&#34;authentication required&#34;,&#34;detail&#34;:null}]}
```

## login

```bash
docker login -u tradeops 192.168.1.88:5000
docker logout 192.168.1.88:5000
```

## 添加 insecure

```bash
{
    &#34;registry-mirrors&#34;: [
        &#34;http://hub-mirror.c.163.com&#34;,
        &#34;https://docker.mirrors.ustc.edu.cn&#34;,
        &#34;https://registry.docker-cn.com&#34;
    ],
    &#34;insecure-registries&#34; : [
        &#34;192.168.1.162:5000&#34;,
        &#34;10.32.111.107:5000&#34;
    ]
}
```

## airflow 处理 docker 问题

```bash
## 需要在 airflow 执行

docker logout 192.168.1.88:5000
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-23-centos7-%E6%90%AD%E5%BB%BA%E7%A7%81%E6%9C%89-dockerhub/  

