# docker 使用 sytemctl


允许一个 `Docker container` 获取主机的 `systemctl` 权限。

&lt;!--more--&gt;

## 使用 Docker run

```bash
docker run --name mon.machine -dit \
--privileged=true \
-v /:/mnt \
-v /run/dbus/system_bus_socket:/run/dbus/system_bus_socket:ro \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-p 31022:22 \
--shm-size=20gb \
10.32.111.107:5000/pydev:v1.0 /sbin/init
```

## 使用 Docker-compose

```dockerfile
version: &#34;3&#34;

services:
  mon.machine:
    container_name: mon.machine
    image: 10.32.111.107:5000/pydev:v1.0
    privileged: true
    shm_size: &#39;8gb&#39;
    environment:
      - SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
    volumes:
      - ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}
      - /home/william:/mnt
    ports:
      - &#34;22222:22&#34;
    command:
      - /bin/bash
      - -c
      - |
        cat /mnt/.ssh/id_rsa.pub &gt;&gt; ~/.ssh/authorized_keys
        git clone git@192.168.1.171:lfang/jobs.git ~/git/jobs
        /usr/sbin/init
    pull_policy: always
    restart: always
```

这里需要注意：

1. 配置 `privileged: true`

2. 在 `command` 需要先初始化，然后再执行其他的命令

   ```dockerfile
       privileged: true
       command:
         - /bin/bash
         - -c
         - |
           cat /mnt/.ssh/id_rsa.pub &gt;&gt; ~/.ssh/authorized_keys
           git clone git@192.168.1.171:lfang/jobs.git ~/git/jobs
           /usr/sbin/init
   ```




---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-25-docker-%E4%BD%BF%E7%94%A8-sytemctl/  

