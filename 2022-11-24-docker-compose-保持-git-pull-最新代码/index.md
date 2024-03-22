# docker compose 保持 git pull 最新代码


由于 `Dockerfile` 使用了多层构建的方式，对于没有改动的命令行，就不会在执行重新构建了。如果我们需要在 `Dockerfile` 保持更新 `git pull`，可以有两种方式

1. `docker build` 的时候使用 `--no-cache` 选项，但是这个是全局范围的配置，一旦设置，需要全部重新构建，往往显得十分臃肿
2. `docker-compose` 还支持提供 `--build-arg` 的选项，可以把一些参数传递到 `Dockerfile` 里面。

&lt;!--more--&gt;

这里有一个小技巧，如果我们每次构建的时候，传递的参数是一个与时间相关的，则在每次构建的时候都会传递不同的参数，从而保证了在该参数之后的构建是会保持更新与构建的。

```bash
## ensure latest wepy
ARG BUILD_DATE
RUN --mount=type=ssh \
    mkdir -p ~/git &amp;&amp; cd ~/git &amp;&amp; \
    git clone git@192.168.1.171:lfang/wepy.git &amp;&amp; \
    cd ~/git/wepy &amp;&amp; \
    bash ./install.venv.sh &amp;&amp; \
    rm -rf ~/git/wepy
```

```bash
## ----------------------------------------------------------------------------
## build
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
DOCKER_BUILDKIT=1 docker build \
    --ssh default \
    --build-arg BUILD_DATE=$(date -u &#43;&#39;%Y-%m-%dT%H:%M:%S&#39;) \
    -t pydev:v1.0 .
## ----------------------------------------------------------------------------
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-24-docker-compose-%E4%BF%9D%E6%8C%81-git-pull-%E6%9C%80%E6%96%B0%E4%BB%A3%E7%A0%81/  

