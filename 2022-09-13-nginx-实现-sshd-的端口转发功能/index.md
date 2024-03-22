# nginx 实现 sshd 的端口转发功能


通过 nginx 实现端口转发

&lt;!--more--&gt;

# 安装 nginx with stream

```bash
## 如果是从源代码安装，需要在编译时候配置
 ./configure  --prefix=/opt/apps/nginx --with-stream
 make &amp;&amp; make install

## 或者直接用下面的命令安装
#执行下面的命令，根据提示完成安装
wget https://raw.githubusercontent.com/helloxz/nginx-cdn/master/nginx.sh &amp;&amp; bash nginx.sh

#安装完成后执行下面的命令让环境变量生效
source /etc/profile

#执行下面的命令查看nginx信息
nginx -V

## 在版本 1.9 以上会出现 --with-stream，即可证明可以用 sshd 断隧道功能了
```

# 配置端口转发

```bash
cd /etc/nginx
vim nginx.conf


## stream 是与 http 通级别的

#... ...
#... ...
events {
    use epoll;
    worker_connections  65535;
}
#stream配置
stream {
    #将12345端口转发到192.168.1.23的3306端口
    server {
        listen 12345;
        proxy_connect_timeout 1h;
        proxy_timeout 1h;
        proxy_pass 192.168.1.23:3306;
    }
    #将tcp 1022端口转发到192.168.1.23 22端口
    server {
        listen 1022 reuseport;
        proxy_timeout 1h;
        proxy_pass 192.168.1.23:22;
    }
    #将udp 53端口转发到192.168.1.23 53端口
    server {
        listen 53 udp reuseport;
        proxy_timeout 1h;
        proxy_pass 192.168.1.23:53;
    }
    #ipv4转发到ipv6
    server {
        listen 9135;
        proxy_connect_timeout 10s;
        proxy_timeout 30s;
        proxy_pass [2607:fcd0:107:3cc::1]:9135;
    }
}
http {
#... ...
#... ...
}
```

- listen：后面填写源端口（也就是当前服务器端口），默认协议为TCP，可以指定为UDP协议
- proxy_connect_timeout：连接超时时间
- proxy_timeout：超时时间
- proxy_pass：填写转发目标的IP及端口号

这样，我们可以访问 `nginx` 所在网络的指定端口，去访问目标机器

```bash
nginx -s reload

ssh -p 1022 user@127.0.0.1
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-nginx-%E5%AE%9E%E7%8E%B0-sshd-%E7%9A%84%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91%E5%8A%9F%E8%83%BD/  

