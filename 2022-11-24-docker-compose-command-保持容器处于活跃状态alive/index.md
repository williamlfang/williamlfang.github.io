# docker compose command 保持容器处于活跃状态alive


通过添加 `tail -f /dev/null` 保持刷新，使得容器始终处于活跃状态（alive），否则一旦命令执行完成，就会立即停止了。这样对于一些任务，我们往往想要其保持状态，方便进去容器内部进行调试。

&lt;!--more--&gt;

```Dockerfile
version: &#34;3&#34;

services:
  mon.machine:
    container_name: mon.machine
    image: 10.32.111.107:5000/pydev:v1.0
    privileged: false
    shm_size: &#39;8gb&#39;
    environment:
      - SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
    volumes:
      - ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}
    ports:
      - &#34;31022:22&#34;
    command:
      - /bin/bash
      - -c
      - |
        git clone git@192.168.1.171:lfang/jobs.git ~/git/jobs
        tail -f /dev/null
    pull_policy: always
    restart: always
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-24-docker-compose-command-%E4%BF%9D%E6%8C%81%E5%AE%B9%E5%99%A8%E5%A4%84%E4%BA%8E%E6%B4%BB%E8%B7%83%E7%8A%B6%E6%80%81alive/  

