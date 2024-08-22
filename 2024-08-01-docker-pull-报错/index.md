# docker pull 报错


在使用 `Docker` 拉取镜像时，出现域名解析错误

&lt;!--more--&gt;

```bash
Error response from daemon: Get &#34;https://registry-1.docker.io/v2/&#34;: dial tcp: lookup registry-1.docker.io on [::1]:53: read udp [::1]:55479-&gt;[::1]:53: read: connection refused
```

需要修改 `/etc/resolv.conf`

```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

然后执行

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-08-01-docker-pull-%E6%8A%A5%E9%94%99/  

