# ssh 反向代理


# 服务器端

假设服务器[京东云]ip是：`123.123.111.111`

```bash
## 启动 firewalld 服务，添加端口 6666
fuser -k 6666/tcp

systemctl restart firewalld.service
firewall-cmd --zone=public --add-port=6666/tcp --permanent
systemctl stop firewalld.service

## 开启代理，通过外部访问 6666 转发到 6166(即内网服务器端口)
ssh -fNCL *:6666:localhost:6166 localhost
```
&lt;!--more--&gt;

# 客户端

```bash
## 开启 6166，任何访问外网的端口会自动转发到 22，即 ssh 服务
ssh -4 -fNCR 6166:localhost:22 -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -o ExitOnForwardFailure=True -p 22 root@123.123.111.111
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-12-19-ssh-%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86/  

