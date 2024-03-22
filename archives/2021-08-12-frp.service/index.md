# frp.service


```bash
[Unit]
Description=frp network service
After=network.target network-online.target

[Service]
Type=forking
Restart=always
RestartSec=5
ExecStart=/root/tools/frp_0.37.0_linux_amd64/start.sh
ExecReload=/root/tools/frp_0.37.0_linux_amd64/start.sh
ExecStop=/root/tools/frp_0.37.0_linux_amd64/start.sh

[Install]
WantedBy=multi-user.target
```

```bash
#!/usr/bin/env bash

## 1.kill
ps aux |grep frpc  |awk &#39;{print $2}&#39; |xargs kill -9

## 2.start
nohup /root/tools/frp_0.37.0_linux_amd64/frpc -c /root/tools/frp_0.37.0_linux_amd64/frpc.ini &amp;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-08-12-frp.service/  

