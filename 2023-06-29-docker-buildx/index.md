# docker buildx


`Docker` 提供了一些新功能，这些只有通过 `buildx` 插件才能完成。

```bash
  - [X] 处理Snail6Ops使用 Docker plugin 更新要求 buildx 插件升级的问题 (2023-06-29 19:42:10)
    - [X] docker ERROR: BuildKit is enabled but the buildx component is missing or broken (2023-06-29 19:42:56)
    - [X] export DOCKER_BUILDKIT=1 (2023-06-29 19:43:20)
```

&lt;!--more--&gt;

# airflow

```bash
## 需要安装插件
## ref: https://docs.docker.com/engine/install/centos/

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-buildx-plugin docker-compose-plugin
```

另外在 `docker-compose.yaml` 配置

```yaml
  airflow:
    hostname: airflow
    container_name: airflow
    image: 192.168.1.162:5000/airflow:v1.0
    ## 不能用 previlleged，·普通用户也可以, 为了 /var/run/docker.socket
    privileged: false
    tty: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock ## docker-in-docker
      - /run/buildkit/buildkitd.sock:/run/buildkit/buildkitd.sock ## docker-in-docker
      - /run/containerd/containerd.sock:/run/containerd/containerd.sock
      - /usr/bin/docker:/bin/docker               ## docker 可执行，如果有 so 也需要 mount
      - ~:/mnt
      - /data:/data
      - /fs:/fs                                   ## /fs in docker-in-docker
      - /mnt/cephfs:/root/cephfs                  ## 可以在 docker-in-docker 使用 cephs
      - ~/git/jobs/dags:/app/dags                 ## for dags
      # - ~/mysql:/var/lib/mysql ## for mysql
    ports:
      - &#34;18080:8080&#34; ## web
    command:
      - /bin/bash
      - -c
      - |
        /usr/sbin/init
    pull_policy: always
    restart: always
```

# docker buildx

```bash
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

DOCKER_BUILDKIT=1 docker build ...
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-06-29-docker-buildx/  

