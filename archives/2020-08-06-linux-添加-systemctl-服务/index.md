# Linux 添加 systemctl 服务


# 方法

## 新建一个服务文件

```bash
cd /usr/lib/systemd/system

$ls -alh
EasyMonitor.service  xtp_md.service

total 16K
drwxr-xr-x  2 root root 4.0K Aug  6 13:37 ./
drwxr-xr-x 10 root root 4.0K Jun  8 16:25 ../
-rw-r--r--  1 root root  998 Jan  7  2020 EasyMonitor.service
-rwxr-xr-x  1 root root  292 Aug  6 13:54 xtp_md.service*
```
&lt;!--more--&gt;

设置 `xtp_md.sevice` 服务内容

```bash
[Unit]
Description=XTP mkdata
After=network.target network-online.target

[Service]
Type=forking
Restart=always
RestartSec=5
ExecStart=/home/william/workspace/highfort/xtp_md_start.sh
ExecReload=/home/william/workspace/highfort/xtp_md_restart.sh
ExecStop=/home/william/workspace/highfort/xtp_md_stop.sh

[Install]
WantedBy=multi-user.target
```

## 编写相应的执行文件

### xtp_md_start.sh

```bash
#!/bin/bash

export LD_LIBRARY_PATH=/home/william/workspace/highfort/hippo/external/exch/XTP:/usr/lib/x86_64-linux-gnu:/usr/local/lib:$LD_LIBRARY_PATH
cd /home/william/workspace/highfort/hippo/build/install/bin
nohup ./md /home/william/workspace/highfort/hippo/app/gw/xtp_gw/config/xtp_test_william.conf &amp;
```

### xtp_md_stop.sh

```bash
#!/bin/bash

ps aux | grep &#34;xtp_test_william.conf&#34; | grep -v color | awk &#39;{print $2}&#39; | xargs kill -9
```

### xtp_md_restart.sh

```bash
#!/bin/bash

export LD_LIBRARY_PATH=/home/william/workspace/highfort/hippo/external/exch/XTP:/usr/lib/x86_64-linux-gnu:/usr/local/lib:$LD_LIBRARY_PATH
cd /home/william/workspace/highfort/hippo/build/install/bin
nohup ./md /home/william/workspace/highfort/hippo/app/gw/xtp_gw/config/xtp_test_william.conf &amp;
```

# 添加执行

```bash
## 重新载入
sudo systemctl daemon-reload

sudo systemctl enable xtp_md
sudo systemctl start xtp_md
sudo systemctl status xtp_md
sudo systemctl stop xtp_md

## 显示所有服务
sudo systemctl --type=service
```

![systemctl](/images/2020-08-06-Linux-添加-systemctl-服务/systemctl_status.png &#34;systemctl&#34;)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-08-06-linux-%E6%B7%BB%E5%8A%A0-systemctl-%E6%9C%8D%E5%8A%A1/  

