# Dockerfile 使用 ssh


在 `Dockerfile` 使用 `ssh` 秘钥，可以访问相应权限的项目

&lt;!--more--&gt;

## Dockerfile

```dockerfile
# syntax=docker/dockerfile:experimental
FROM william-centos7-gcc9:v1.0
MAINTAINER William
LABEL Remarks=&#34;DataMgr @WuyaCapital&#34;

# add credentials on build
RUN mkdir -p -m 0700 ~/.ssh &amp;&amp; \
    ssh-keyscan 192.168.1.171 &gt;&gt; ~/.ssh/known_hosts

# ADD ./requirements.txt /app/requirements.txt
# RUN pip install -r requirements.txt

RUN --mount=type=ssh \
    mkdir -p git &amp;&amp; cd git &amp;&amp; \
    git clone git@192.168.1.171:lfang/wepy.git &amp;&amp; \
    echo `ls -alh`

CMD [&#34;/usr/sbin/init&#34;]
```

这里需要注意：

- 在开头添加

  ```dockerfile
  # syntax=docker/dockerfile:experimental
  ```

- 在 `RUN` 命令后面添加 `--mount=type=ssh `，之后是正常的 `bash` 命令语句



## Docker 命令执行

```bash
DOCKER_BUILDKIT=1 docker build --ssh default -t
```

如果出现了以下的报错，先不要慌，可能是网络解析不通畅：

```bash
 =&gt; ERROR resolve image config for docker.io/docker/dockerfile:experimental
0.1s
------
 &gt; resolve image config for docker.io/docker/dockerfile:experimental:
------
failed to solve with frontend dockerfile.v0: failed to solve with frontend gateway.v0: unexpected status code https://docker.mirrors.ustc.edu.cn/v2/docker/dockerfile/manifests/experimental: 403 Forbidden
```



## Docker-compose 执行



## 结果查看

```bash
[&#43;] Building 277.1s (10/12)
 =&gt; [internal] load build definition from Dockerfile                                                                                                                                                                                                                                                                                                                                      0.0s
 =&gt; =&gt; transferring dockerfile: 38B                                                                                                                                                                                                                                                                                                                                                       0.0s
 =&gt; [internal] load .dockerignore                                                                                                                                                                                                                                                                                                                                                         0.0s
 =&gt; =&gt; transferring context: 2B                                                                                                                                                                                                                                                                                                                                                           0.0s
 =&gt; resolve image config for docker.io/docker/dockerfile:experimental                                                                                                                                                                                                                                                                                                                     1.6s
 =&gt; CACHED docker-image://docker.io/docker/dockerfile:experimental@sha256:600e5c62eedff338b3f7a0850beb7c05866e0ef27b2d2e8c02aa468e78496ff5                                                                                                                                                                                                                                                0.0s
 =&gt; [internal] load build definition from Dockerfile                                                                                                                                                                                                                                                                                                                                      0.0s
 =&gt; =&gt; transferring dockerfile: 38B                                                                                                                                                                                                                                                                                                                                                       0.0s
 =&gt; [internal] load metadata for docker.io/library/william-centos7-gcc9:v1.0                                                                                                                                                                                                                                                                                                              0.0s
 =&gt; [1/5] FROM docker.io/library/william-centos7-gcc9:v1.0                                                                                                                                                                                                                                                                                                                                0.0s
 =&gt; =&gt; resolve docker.io/library/william-centos7-gcc9:v1.0                                                                                                                                                                                                                                                                                                                                0.0s
 =&gt; [internal] load build context                                                                                                                                                                                                                                                                                                                                                         0.0s
 =&gt; =&gt; transferring context: 38B                                                                                                                                                                                                                                                                                                                                                          0.0s
 =&gt; [2/5] RUN mkdir -p -m 0700 ~/.ssh &amp;&amp;     ssh-keyscan 192.168.1.171 &gt;&gt; ~/.ssh/known_hosts                                                                                                                                                                                                                                                                                              0.5s
 =&gt; [3/5] ADD ./requirements.txt /app/requirements.txt                                                                                                                                                                                                                                                                                                                                    0.1s
 =&gt; [4/5] RUN pip3 install -r requirements.txt
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-22-dockerfile-%E4%BD%BF%E7%94%A8-ssh/  

