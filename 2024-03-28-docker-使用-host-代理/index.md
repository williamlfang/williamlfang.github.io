# docker 使用 host 代理



host 宿主机已经配置 vpn 代理，为了可以让 `Docker` 虚拟机能够共享宿主机的代理服务，我们需要修改相关的配置。

&lt;!--more--&gt;


## 修改 ~/.docker/config.json

```json
{
    &#34;proxies&#34;: {
        &#34;default&#34;: {
            &#34;httpProxy&#34;: &#34;socks5://127.0.0.1:1086&#34;,
            &#34;httpsProxy&#34;: &#34;socks5://127.0.0.1:1086&#34;,
            &#34;noProxy&#34;: &#34;127.0.0.0/8&#34;
        }
    }
}
```

## 修改 Docker Compose

需要设置网络模式 `network_mode: host`，这样使得虚拟机可以直接使用宿主机的网络代理服务.

```yaml
version: &#34;3&#34;

services:
  pyrdev:
    hostname: pyrdev
    container_name: pyrdev
    image: 192.168.1.162:5000/pyrdev:v1.0
    privileged: true
    network_mode: host
    shm_size: &#39;8gb&#39;
    command:
      - /bin/bash
      - -c
      - |
        /usr/sbin/init
    pull_policy: always
    restart: always
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-28-docker-%E4%BD%BF%E7%94%A8-host-%E4%BB%A3%E7%90%86/  

