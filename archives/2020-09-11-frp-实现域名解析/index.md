# frp 实现域名解析


使用 frp 配合 godday 实现内网服务直接解析成二级域名。
&lt;!--more--&gt;

# godday 域名解析

`godaddy` 提供了**泛域名解析**，即通过二级域名即可匹配在服务器特定端口运行的后台服务，如 `8080` 对应的 `gitlab` 端口服务。

使用 godaddy 的 DNS Management 面板，增加一条域名

|      |      |               |              |      |
| :--- | :--- | :------------ | :----------- | :--- |
| 类型 | 名称 | 值            | TTL          | 操作 |
| A    | @    | Parked        | 600 秒       | 编辑 |
| A    | *    | 80.251.219.73 | 999999999 秒 |      |

![godaddy 域名解析](./godaddy.png &#34;godaddy 域名解析&#34;)

# vps 开启 80,443,7500 端口

为了能够在浏览器支持直接打开网页地址，我们需要通过 vps 上运行的 frp `80` 端口去自动匹配相关的转发端口。这样，在客户端，只需要记住相应的二级域名即可。

```bash
systemctl start firewalld.service

## http
firewall-cmd --zone=public --add-port=80/tcp --permanent
## https
firewall-cmd --zone=public --add-port=443/tcp --permanent
## frp 管理端口
firewall-cmd --zone=public --add-port=7500/tcp --permanent

systemctl stop firewalld.service
```

# frps 设置

在服务器上面，设置 `frps.ini`

```bash
[common]
# A literal address or host name for IPv6 must be enclosed
# in square brackets, as in &#34;[::1]:80&#34;, &#34;[ipv6-host]:http&#34; or &#34;[ipv6-host%zone]:80&#34;
bind_addr = 0.0.0.0
bind_port = 7000

# udp port to help make udp hole to penetrate nat
#bind_udp_port = 9001

# udp port used for kcp protocol, it can be same with &#39;bind_port&#39;
# if not set, kcp is disabled in frps
#kcp_bind_port = 9000

# specify which address proxy will listen for, default value is same with bind_addr
# proxy_bind_addr = 127.0.0.1

# if you want to support virtual host, you must set the http port for listening (optional)
# Note: http port and https port can be same with bind_port
vhost_http_port = 80
vhost_https_port = 433

# response header timeout(seconds) for vhost http server, default is 60s
# vhost_http_timeout = 60

# set dashboard_addr and dashboard_port to view dashboard of frps
# dashboard_addr&#39;s default value is same with bind_addr
# dashboard is available only if dashboard_port is set
dashboard_addr = 0.0.0.0
dashboard_port = 7500

# dashboard user and passwd for basic auth protect, if not set, both default value is admin
dashboard_user = *********
dashboard_pwd = *********

# dashboard assets directory(only for debug mode)
# assets_dir = ./static
# console or real logFile path like ./frps.log
#log_file = ./frps.log

# trace, debug, info, warn, error
log_level = trace

log_max_days = 3

# disable log colors when log_file is console, default is false
disable_log_color = false

# auth token
token = *********

# heartbeat configure, it&#39;s not recommended to modify the default value
# the default value of heartbeat_timeout is 90
# heartbeat_timeout = 90

# only allow frpc to bind ports you list, if you set nothing, there won&#39;t be any limit
#allow_ports = 5000-5010,8080

# pool_count in each proxy will change to max_pool_count if they exceed the maximum value
max_pool_count = 10

# max ports can be used for each client, default value is 0 means no limit
max_ports_per_client = 0

# if subdomain_host is not empty, you can set subdomain when type is http or https in frpc&#39;s configure file
# when subdomain is test, the host used by routing is test.frps.com
subdomain_host = williamlfang.com

# if tcp stream multiplexing is used, default is true
tcp_mux = true

# custom 404 page for HTTP requests
# custom_404_page = /path/to/404.html

[plugin.user-manager]
#addr = 127.0.0.1:9000
#path = /handler
#ops = Login

[plugin.port-manager]
#addr = 127.0.0.1:9001
#path = /handler
#ops = NewProxy
```



然后运行

```bash
nohup ./frps -c frps.ini &amp;
```

现在，我们便可以登录网址：http://frp.williamlfang.com:7500/ ，可视化的管理 frp 窗口了。

![frp管理界面](./frp管理界面.png &#34;frp管理界面&#34;)


# frpc 设置

在客户端设置 `frpc`

```bash
[common]
server_addr = frp.williamlfang.com
server_port = 7000
token =

[ssh135]
type = tcp
local_ip = 192.168.1.135
local_port = 22
remote_port = 6135

[ssh199]
type = tcp
local_ip = 192.168.1.199
local_port = 22
remote_port = 6199

[ssh135_gitlab]
type = http
local_ip = 192.168.1.135
local_port = 58080
subdomain = gitlab

[ssh135_docker]
type = http
local_ip = 192.168.1.135
local_port = 5000
subdomain = docker

[ssh135_docker_web]
type = http
local_ip = 192.168.1.135
local_port = 5001
subdomain = dockerweb
```

这里的关键步骤是，我们需要把远程的 ``server_addr` 设置成 `frp.williamlfang.com`，这个是一级域名，然后通过底下的二级域名 `gitlab` 找到对应的端口服务。

可以试着打开 `http://gitlab.williamlfang.com/`，发现不需要记住端口，即可访问服务器的 `gitlab` 服务项目了。

# gitlab 如何 clone

由于 `gitlab` 是处理当前内部网络，无法直接通过 `ssh` 进行 ` git clone`，我们可以指定 `https` 的形式，把相应的端口转发出来。这里，`http://192.168.1.135:58080/fl/myctp.git` 对应的是 `http://gitlab.williamlfang.com/fl/myctp.git`

```bash
git clone http://gitlab.williamlfang.com/fl/myctp.git
```

然后可以通过 `.git/config` 设置账户密码，下次就不用再输入了

```bash
vim .git/config

[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote &#34;origin&#34;]
	url = http://用户名:密码@gitlab.williamlfang.com/fl/myctp.git
	fetch = &#43;refs/heads/*:refs/remotes/origin/*
[branch &#34;master&#34;]
	remote = origin
	merge = refs/heads/master
```

# Docker 访问

类似的，我们也可以设置 docker 的访问

```bash
## 编辑 /etc/docker/daemon.json
## 添加 &#34;insecure-registries&#34; 里面的 &#34;docker.williamlfang.com&#34;
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
    &#34;docker.williamlfang.com&#34;
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
docker pull docker.williamlfang.com/testing
```



# 参考链接

-   [frp内网穿透服务器搭建及免费frp服务器提供](http://iytc.net/wordpress/?p=3299)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-09-11-frp-%E5%AE%9E%E7%8E%B0%E5%9F%9F%E5%90%8D%E8%A7%A3%E6%9E%90/  

