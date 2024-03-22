# Dockerfile 使用 ssh 下载私有 git 项目


为了在 `Docker` 镜像里面下载私有 `git ` 项目代码，我们需要告诉 `Dockerfile` 如何调用主机的 `ssh` 公钥。

&lt;!--more--&gt;



## Dockerfile

```dockerfile
#syntax=docker/dockerfile:1.0.0-experimental

## 假设私有 git 网站是：192.168.1.171，
## 如果是 github，替换成 github.com
RUN mkdir -p ~/.ssh &amp;&amp; \
    chmod 700 ~/.ssh &amp;&amp; \
    ssh-keyscan 192.168.1.171 &gt;&gt; ~/.ssh/known_hosts &amp;&amp; \

RUN --mount=type=ssh &amp;&amp; \
    mkdir -p ~/git &amp;&amp; cd ~/git &amp;&amp; \
    git clone git@192.168.1.171:lfang/wepy.git &amp;&amp; \
    cd wepy &amp;&amp; \
    bash ./install.venv.sh &amp;&amp; \
    rm -rf ~/git/wepy
```

这里需要注意：

- 在 `Dockerfile` **第一行**（前面不能有其他注释）添加

  ```dockerfile
  #syntax=docker/dockerfile:1.0.0-experimental
  ```

- 添加 `ssh-keyscan` 避免 `unknown host` 错误

- 使用 `Run --mount=type=ssh XXX` 执行需要的命令

- 另外，我们在上层的 `Dockerfile` 不能有以下命令，这个会干扰 `git` 的权限问题

  ```dockerfile
  echo &#34;Host *&#34;                       &gt;&gt; ~/.ssh/config &amp;&amp; \
  echo &#34;    ServerAliveInterval 60&#34;   &gt;&gt; ~/.ssh/config &amp;&amp; \
  echo &#34;    ServerAliveInterval 60&#34;   &gt;&gt; ~/.ssh/config &amp;&amp; \
  ```



## Docker build

```bash
## ----------------------------------------------------------------------------
## build
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
# DOCKER_BUILDKIT=1 proxychains4 docker build --ssh default -t datamgr:v1.0 .
DOCKER_BUILDKIT=1 docker build --ssh default -t datamgr:v1.0 .
## ----------------------------------------------------------------------------
```

这里需要注意：

- 使用 ``DOCKER_BUILDKIT=1` 开启实验性功能（`–mount`）


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-24-dockerfile-%E4%BD%BF%E7%94%A8-ssh-%E4%B8%8B%E8%BD%BD%E7%A7%81%E6%9C%89-git-%E9%A1%B9%E7%9B%AE/  

