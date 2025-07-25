# Docker 修改 DNS:resolv.conf


为了在 `Docker` 中使用指定 `DNS`，我们需要相应修改 `/etc/resolv.conf`。现在遇到的问题是

&gt; 无法在 Dockerfile 里“永久”覆盖 /etc/resolv.conf；
&gt; 无论 Classic 还是 BuildKit，Docker 都会在启动阶段把运行时生成的 resolv.conf 挂到容器里，覆盖镜像中原有内容。

因此，我们需要在 `build` 阶段，把 `DNS` 「传送」到 `docker` 里面。下面介绍具体的方法。

&lt;!--more--&gt;

# 使用宿主机

让 builder 使用宿主机网络（简单，但依赖宿主机 DNS

## 修改宿主机 DNS

这里我们添加了 `nameserver 10.32.255.254`

```bash
cat /etc/resolv.conf
```

```
# This file is managed by man:systemd-resolved(8). Do not edit.
#
# This is a dynamic resolv.conf file for connecting local clients directly to
# all known uplink DNS servers. This file lists all configured search domains.
#
# Third party programs must not access this file directly, but only through the
# symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a different way,
# replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 10.32.255.254
nameserver 114.114.114.114
nameserver 8.8.8.8
nameserver 192.168.10.1
```

## 重新编译 buildx
只要宿主机的 /etc/resolv.conf 正确即可。

```bash
docker buildx rm mybuilder 2&gt;/dev/null
docker buildx create \
  --name mybuilder \
  --driver docker-container \
  --driver-opt network=host \
  --bootstrap --use

docker buildx build -t myimage .
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-07-25-docker-%E4%BF%AE%E6%94%B9-dns-resolv.conf/  

