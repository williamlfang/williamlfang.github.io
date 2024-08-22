# docker 镜像失败，添加临时方案


在使用 `docker:experimental` 时，出现报错信息为：

```bash
failed to solve with frontend dockerfile.v0: failed to solve with frontend gateway.v0: unexpected status code [manifests 1.0.0-experimental]: 403 Forbidden

error pulling image configuration: download failed after attempts=6: dial tcp 75.126.150.210:443: i/o timeout
```

需要添加临时镜像: `https://docker.1panel.live`

&lt;!--more--&gt;

```
{
  &#34;registry-mirrors&#34; : [
    &#34;http://ovfftd6p.mirror.aliyuncs.com&#34;,
    &#34;http://registry.docker-cn.com&#34;,
    &#34;http://docker.mirrors.ustc.edu.cn&#34;,
    &#34;https://docker.1panel.live&#34;,
    &#34;http://hub-mirror.c.163.com&#34;
  ],
  &#34;insecure-registries&#34; : [
    &#34;registry.docker-cn.com&#34;,
    &#34;docker.mirrors.ustc.edu.cn&#34;,
    &#34;192.168.1.183:5000&#34;,
    &#34;192.168.1.162:5000&#34;
  ],
  &#34;debug&#34; : true,
  &#34;experimental&#34; : true,
  &#34;log-driver&#34;: &#34;json-file&#34;,
  &#34;log-opts&#34;: {
    &#34;max-size&#34;: &#34;1m&#34;,
    &#34;max-file&#34;: &#34;10&#34;
  }
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-08-14-docker-%E9%95%9C%E5%83%8F%E5%A4%B1%E8%B4%A5%E6%B7%BB%E5%8A%A0%E4%B8%B4%E6%97%B6%E6%96%B9%E6%A1%88/  

