# Docker 运行 rstudio




&lt;!--more--&gt;

&gt; 参考链接：https://github.com/rocker-org/rocker/issues/206
&gt; https://hub.docker.com/r/rocker/rstudio



```bash
## 新建 Docker
docker run -d --name rstudio -v $HOME:/home/`whoami` -e USER=lfang -e PASSWORD=****** -p 58787:8787 rocker/tidyverse

docker exec -it rstudio /bin/bash
```

- 用户：lfang
- 密码：******
- 端口：58787

```bash
## 添加用户，需要进入 docker 添加用户
docker exec -it rstudio /bin/bash
sudo adduser tester
sudo passwd tester
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-23-docker-%E8%BF%90%E8%A1%8C-rstudio/  

