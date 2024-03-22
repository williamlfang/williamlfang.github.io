# docker 安装 RabbitMQ


在 `Docker` 环境安装 `RabbitMQ`

&lt;!--more--&gt;

```dockerfile
version: &#34;3&#34;

services:
  rabbitmq:
    container_name: rabbitmq
    image: docker.io/rabbitmq:3.11-management
    privileged: true
    shm_size: &#39;8gb&#39;
    environment:
      - SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
      - RABBITMQ_DEFAULT_USER=william
      - RABBITMQ_DEFAULT_PASS=**********
    volumes:
      - ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}
      - /home/william:/mnt
    ports:
      - &#34;5672:5672&#34;
      - &#34;15672:15672&#34; ## web
    #pull_policy: always
    restart: always
```

1. 可以访问网站：[rabbitmq](https://hub.docker.com/_/rabbitmq) 查看不同的版本，这里我们选择带有 `management` 的版本，这个提供了 `web gui` 的管理界面
2. 可以在 `docker-compose` 配置用户与密码
3. 配置端口转发
4. 可以访问 `IP:15672`（如 `http://127.0.0.1:15672/` ）进入管理界面


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-29-docker-%E5%AE%89%E8%A3%85-rabbitmq/  

