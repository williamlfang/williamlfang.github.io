# docker in docker




&lt;!--more--&gt;

## airflow-in-docker

&gt; 千万不能用 `previlleged` ，这个会导致无法 `mount /var/run/docker.socket`



```bash
## root 执行
## 不能用 previlleged，·普通用户也可以
docker run -dit \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/bin/docker \
--name=airflow \
--pull=always \
-p 18080:8080 \
10.32.111.107:5000/airflow:v1.0
```

如果是 `dockerfile` （本质上是普通用户，所以不用 root）不用完 `previlleged`

```docker-compose
version: &#34;3&#34;

services:
  airflow:
    container_name: airflow
    image: 10.32.111.107:5000/airflow:v1.0
    ## 不能用 previlleged，·普通用户也可以, 为了 /var/run/docker.socket
    privileged: false
    tty: true
    volumes:
      - ~:/mnt
      - /var/run/docker.sock:/var/run/docker.sock ## docker-in-docker
      - /usr/bin/docker:/bin/docker ## docker 可执行，如果有 so 也需要 mount
      - /mnt/cephfs:/root/cephfs                  ## 可以在 docker-in-docker 使用 cephs
      - ~/git/jobs/dags:/app/dags ## for dags
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

## DAG 使用 DockerOperator

注意，在 `airflow` 处于 `docker-in-docker` 的情况下，这时候我们需要特殊处理 `DockerOperator`

1. `docker_url`: `&#34;unix://var/run/docker.sock&#34;`
2. `network_mode`: `host`，应该为 outside 的 host 网络
3. `mounts`: 这个最重要，决定了 `docker-in-docker` 能够有读取相关路径的权限，需要注意的是，这时候我们需要把 `dockeroperator` 理解成在 `host` 机器运行，所以的路径对应的是 `host` 的路径

```python
from docker.types import Mount

qry_ctp = DockerOperator(
    task_id        = &#39;docker_qry_ctp&#39;,
    docker_url     = &#34;unix://var/run/docker.sock&#34;,
    image          = &#39;10.32.111.107:5000/tradingops/myctp.sx1:stable&#39;,
    container_name = &#39;task___qry_ctp&#39;,
    api_version    = &#39;auto&#39;,
    auto_remove    = &#39;success&#39;,  ## &#39;success&#39;, &#39;force&#39;, &#39;never&#39;
    network_mode   = &#34;host&#34;,
    command        = &#34;&#34;,
    mounts         = [
        Mount(
            source=&#39;/mnt/cephfs&#39;,      ## 这个是 host 的路径
            target=&#39;/root/cephfs&#39;,     ## 这个是 Docker-in-Docker 的路径
            type=&#39;bind&#39;
            ),
        ],
    mount_tmp_dir = False,
    )
```

当然，如果有 `commnad`，我们可以使用

- 单个命令，直接 comnand
- 多个命令，使用 `/bin/bash -c &#39;&lt;command1&gt; &lt;command2&gt;&#39;`

```python
rsync_tora = &#34;&#34;&#34;
    rsync --progress -avPzr --exclude=&#39;*&#39;.log \
        Colo114:/home/ops/tora.qry/log&#39;*&#39; \
        /root/cephfs/ops/data/PublicInfo/Daily/PreTrading/InfoFromTORA
    &#34;&#34;&#34;
rysnc_xele_sh = &#34;&#34;&#34;
    rsync --progress -avPzr --exclude=&#39;*&#39;.log \
        Colo109:/home/ops/xeleq.qry/log&#39;*&#39; \
        /root/cephfs/ops/data/PublicInfo/Daily/PreTrading/InfoFromXELEQ/SH
    &#34;&#34;&#34;
rysnc_xele_sz = &#34;&#34;&#34;
    rsync --progress -avPzr --exclude=&#39;*&#39;.log \
        Colo110:/home/ops/xeleq.qry/log&#39;*&#39; \
        /root/cephfs/ops/data/PublicInfo/Daily/PreTrading/InfoFromXELEQ/SZ
    &#34;&#34;&#34;
rsync_info = DockerOperator(
    task_id        = &#39;docker_rsync_info&#39;,
    docker_url     = &#34;unix://var/run/docker.sock&#34;,
    image          = &#39;10.32.111.107:5000/r7:v1.0&#39;,
    container_name = &#39;task_rsync_info&#39;,
    api_version    = &#39;auto&#39;,
    auto_remove    = &#39;success&#39;,  ## &#39;success&#39;, &#39;force&#39;, &#39;never&#39;
    network_mode   = &#34;host&#34;,
    mount_tmp_dir  = False,
    mounts         = [
        Mount(
            source=&#39;/mnt/cephfs&#39;,      ## 这个是 host 的路径
            target=&#39;/root/cephfs&#39;,     ## 这个是 Docker-in-Docker 的路径
            type=&#39;bind&#39;
            ),
        ],
    command = f&#34;&#34;&#34;
        /bin/bash -c
        &#39;
            {rsync_tora}
            {rysnc_xele_sh}
            {rysnc_xele_sz}
        &#39;
        &#34;&#34;&#34;
    )
```





## DAG 使用 BashOperator

如果使用 `BashOperator`，这相对简单，直接调用 `docker run` 即可

```bash
qry_ctp = BashOperator(
    task_id      = &#39;docker_qry_ctp&#39;,
    bash_command = &#34;&#34;&#34;
        docker run --pull=always --privileged=true \
        --name=myctp.sx1 --rm=true \
        10.32.111.107:5000/tradingops/myctp.sx1:stable
        &#34;&#34;&#34;
    )
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-17-docker-in-docker/  

