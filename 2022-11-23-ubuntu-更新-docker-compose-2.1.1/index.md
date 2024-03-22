# Ubuntu 更新 docker compose 2.1.1


由于在 `Dockerfile` 里面需要支持新的语法规则（`experimental`以支持 `–mount=`），我们需要同步更新 `docker-compose` 到 `v2` 版本。

&lt;!--more--&gt;

```bash
wget  &#34;https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s)-$(uname -m)&#34;

sudo cp docker-compose-Linux-x86_64 /usr/local/bin/docker-compose

Docker Compose version v2.1.1
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-23-ubuntu-%E6%9B%B4%E6%96%B0-docker-compose-2.1.1/  

