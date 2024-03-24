# docker 搭建 TTRSS


使用 Docker 搭建一个简易的 RSS 服务，根据自己的兴趣订阅消息源。我现在使用的是 `Awesome TinyTinyRSS`。

{{&lt; link
    href=&#34;https://ttrss.henry.wang/zh/#%E9%80%9A%E8%BF%87-docker-compose-%E9%83%A8%E7%BD%B2&#34;
    content=&#34;Awesome TTRSS&#34;
    title=&#34;通过 docker-compose 部署&#34;
    card=true
&gt;}}

&lt;!--more--&gt;

## Awesome TTRSS

使用 Dockder-compose 安装，集成相关的服务。

- 创建目录 `~/ttrss`, 下载 [docker-compose.yaml](https://github.com/HenryQW/Awesome-TTRSS/blob/main/docker-compose.yml)

    ```bash
    mkdir -p ~/ttrss/ &amp;&amp; cd ~/ttrss
    mkdir -p feed-icons
    mkdir -p db
    chmod -R 777 ./feed-icons
    ## 启动服务
    docker-compose up -d

    ## 后续更新
    docker-compose down
    # 关闭 Docker 容器
    docker pull wangqiru/ttrss:latest
    docker pull wangqiru/mercury-parser-api:latest
    docker pull wangqiru/opencc-api-server:latest
    docker pull sameersbn/postgresql:latest
    # 更新镜像
    docker-compose up -d
    # 重新启动 Docker 容器
    ```

- 默认账户是 admin，登录后及时修改

    - 默认账户：admin
    - 默认密码：password

- 根据实际情况修改端口、密码等

    ```yaml
    version: &#34;3&#34;
    services:
      service.rss:
        image: wangqiru/ttrss:latest
        container_name: ttrss
        ports:
          - 3894:80     ## change port
        environment:
          - SELF_URL_PATH=https://rss.wuyacapital.com/ # please change to your own domain
          - DB_PASS=xxxxxxxxxxxx                       # use the same password defined in `database.postgres`
          - PUID=1000
          - PGID=1000
          - ENABLE_PLUGINS=auth_internal,fever,api_feedreader,api_newsplus,
        # auth_internal is required. Plugins enabled here will be enabled for all users as system plugins
        volumes:
          - ./feed-icons:/var/www/feed-icons/
        networks:
          - public_access
          - service_only
          - database_only
        stdin_open: true
        tty: true
        restart: always

      service.mercury: # set Mercury Parser API endpoint to `service.mercury:3000` on TTRSS plugin setting page
        image: wangqiru/mercury-parser-api:latest
        container_name: mercury
        networks:
          - public_access
          - service_only
        restart: always

      service.opencc: # set OpenCC API endpoint to `service.opencc:3000` on TTRSS plugin setting page
        image: wangqiru/opencc-api-server:latest
        container_name: opencc
        environment:
          - NODE_ENV=production
        networks:
          - service_only
        restart: always

      database.postgres:
        image: postgres:13-alpine
        container_name: postgres
        environment:
          - POSTGRES_PASSWORD=xxxxxxxxx # feel free to change the password
        volumes:
          - ./db/:/var/lib/postgresql/data # persist postgres data to ~/postgres/data/ on the host
        networks:
          - database_only
        restart: always

      # utility.watchtower:
      #   container_name: watchtower
      #   image: containrrr/watchtower:latest
      #   volumes:
      #     - /var/run/docker.sock:/var/run/docker.sock
      #   environment:
      #     - WATCHTOWER_CLEANUP=true
      #     - WATCHTOWER_POLL_INTERVAL=86400
      #   restart: always

    networks:
      public_access: # Provide the access for ttrss UI
      service_only: # Provide the communication network between services only
        internal: true
      database_only: # Provide the communication between ttrss and database only
        internal: true
    ```

![mercury](./mercury.png &#34;mercury 用于获取RSS全文&#34;)

## 数据备份

```bash
## 备份数据库
docker exec postgres pg_dumpall -c -U postgres &gt; export.sql

## 恢复数据库
cat export.sql | docker exec -i postgres psql -U postgres

## 可以设置定期备份
0 1 * * * cd /root/ttrss &amp;&amp; docker exec postgres pg_dumpall -c -U postgres &gt; export.sql
```

## Ref

- [Awesome TTRSS](https://ttrss.henry.wang/zh/#关于)
- [docker compose 部署配置 Awesome TTRSS 教程](https://www.ioiox.com/archives/81.html)
- [Docker系列 安装个人RSS服务TTRSS 手机完美适配](https://blognas.hwb0307.com/linux/docker/788)
- [博客：十年之约](https://www.foreverblog.cn/)


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-24-docker-%E6%90%AD%E5%BB%BA-ttrss/  

