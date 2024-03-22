# Docker 无法运行 systemctl




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

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-08-04-docker-%E6%97%A0%E6%B3%95%E8%BF%90%E8%A1%8C-systemctl/  

