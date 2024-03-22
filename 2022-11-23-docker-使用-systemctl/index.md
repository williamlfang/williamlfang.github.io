# Docker 使用 systemctl


在一个 `Docker` 里面调用系统命令 `systemctl`

&lt;!--more--&gt;

```bash
## 启动的时候添加 /sbin/init
## 不是 /usr/sbin/init/ 因为有可能找不到
docker run --name rshiny -dit --privileged=true -p 58787:8787 -p 53838:3838 -p50022:22 wuya-centos7-r4.0:v1.0 /sbin/init

docker run --name rshiny -dit --privileged=true -p 58787:8787 -p 53838:3838 -p50022:22 192.168.1.88:5000/wuya/centos7-r4.0:v1.0 /sbin/init

## 运行的时候添加 bash
docker exec -it rshiny bash

sudo systemctl start rstudio-server
sudo systemctl start shiny-server
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-23-docker-%E4%BD%BF%E7%94%A8-systemctl/  

