# rss 与信息获取


`RSS` 提供了订阅式的信息获取机制，我们可以按照自己感兴趣的话题，订阅高质量的博客网站。对比于推送式（系统推荐），这能够拓展我们的信息边界，而不是陷入信息茧房。

&lt;!--more--&gt;

# RSS

## Chrome 工具

### RSS Finder

[Rss Finder](https://chrome.google.com/webstore/detail/rss-finder/ijdgeedipkpmcliidjhbemmlgibfnaff)

### slick-rss

[slick-rss](https://github.com/gandf/slick-rss)

## Thunderbird

## RssHub

[RssHub](https://github.com/DIYgod/RSSHub)

### 安装

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

### 设置阿里云访问

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

### 配置 nginx

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

现在可以通过访问：https://rss.wuyacapital.com/

### 添加 https

certbot

# 常用的 RSS 资源

-

[Chrome 工具](#chrome-工具)[RSS Finder](#rss-finder)[slick-rss](#slick-rss)[Thunderbird](#thunderbird)[RssHub](#rsshub)[安装](#安装)[设置阿里云访问](#设置阿里云访问)[配置 nginx](#配置-nginx)[添加 https](#添加-https)


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-rss-%E4%B8%8E%E4%BF%A1%E6%81%AF%E8%8E%B7%E5%8F%96/  

