# docker 更改存储目录




&lt;!--more--&gt;

```bash
docker info |grep -i dir
## 默认存储在 /var/lib/docker
## Docker Root Dir: /var/lib/docker

## 创建磁盘
mkdir -p /data/docker
cp -r /var/lib/docker /data/docker

## 修改路径
vim /etc/docker/daemon.json
## 设置到目标路径
{
    &#34;data-root&#34;: &#34;/data/docker&#34;
}

sudo systemctl daemon-reload
sudo systemctl restart docker
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-11-20-docker-%E6%9B%B4%E6%94%B9%E5%AD%98%E5%82%A8%E7%9B%AE%E5%BD%95/  

