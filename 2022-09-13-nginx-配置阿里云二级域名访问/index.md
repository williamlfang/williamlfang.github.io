# nginx 配置阿里云二级域名访问


通过配置，运行直接在浏览器访问网站二级域名，实现对指定端口的服务程序的访问。

&lt;!--more--&gt;

## 服务程序

假设我们有一项服务程序，如 [RssHub](https://github.com/DIYgod/RSSHub)

可以参考 [官网教程](https://docs.rsshub.app/install/#docker-jing-xiang)

```bash
sudo yum install docker docker-compose
sudo systemctl start docker

wget https://raw.githubusercontent.com/DIYgod/RSSHub/master/docker-compose.yml
## 配置
vim docker-compose.yml  # 也可以是你喜欢的编辑器

docker volume create redis-data
docker-compose up -d

## 访问
curl 127.0.0.1:1200
```

为了可以通过访问阿里云的二级域名，即在浏览器直接打开可以通过访问：https://rss.wuyacapital.com/

## 设置阿里云访问

```bash
systemctl restart firewalld.service
firewall-cmd --zone=public --add-port=1200/tcp --permanent
systemctl stop firewalld.service
```

- 然后需要在阿里云-【安全组】-选择开放 1200 端口访问。
- 接着设置阿里云域名解析
  - 记录类型：A
  - 主机记录：rss （.wuyacapital.com）
  - 记录值：阿里IP（不带端口，需要通过nginx配置）

## 配置 nginx

```bash
cd /etc/nginx
vim nginx.conf

## 尽量在前面添加
## 在 htpp {} 里面
server {
    listen 80;
    server_name  rss.wuyacapital.com;

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass http://127.0.0.1:1200;
    }
}

systemctl restart nginx
nginx -s reload
```

- 在 `http{}` 里面增加一个 `server` 配置
- `server_name` 指定阿里云二级域名：rss.wuyacapital.com
- 在`location` 填写指定代理转发的服务程序端口 1200：`proxy_pass http://127.0.0.1:1200`

现在可以通过访问：https://rss.wuyacapital.com/

## 添加 https

certbot


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-nginx-%E9%85%8D%E7%BD%AE%E9%98%BF%E9%87%8C%E4%BA%91%E4%BA%8C%E7%BA%A7%E5%9F%9F%E5%90%8D%E8%AE%BF%E9%97%AE/  

