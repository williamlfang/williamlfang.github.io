# docker 配置在pull阶段使用 proxy


最近一些不可描述的会议导致了整个国内互联网的大瘫痪，顺带牵连了 `Docker` 镜像的同步功能。所以说不能相信国内互联网这群人，动不动就听话干事。

由此，我在部署 `docker` 时就遇到了网络连接超时的问题，甚至是 `hello world` 都无法跑得通（天哪，这些不可描述的会议研究的是开放互联网，却是大张旗鼓的搞瘫整个互联网）。所以想到需要使用梯子来加速pull。

&lt;!--more--&gt;

`Docker` 的服务是由 `dockerd` 提供，这本身是一个 `systemd` 任务。所以我们可以在 `daemon` 修改，使其走 proxy 模式

## 修改 daemon

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo vim /etc/systemd/system/docker.service.d/proxy.conf
## ------------------------------------------------------

[Service]
Environment=&#34;HTTP_PROXY=socks5://192.168.1.82:1086&#34;
Environment=&#34;HTTPS_PROXY=socks5://192.168.1.82:1086&#34;
Environment=&#34;NO_PROXY=localhost,127.0.0.1,.example.com&#34;

## ------------------------------------------------------
## 重启服务即可
sudo systemctl daemon-reload
sudo systemctl restart docker
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-17-docker-%E9%85%8D%E7%BD%AE%E5%9C%A8pull%E9%98%B6%E6%AE%B5%E4%BD%BF%E7%94%A8-proxy/  

