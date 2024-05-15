# rinetd 实现端口转发


通过 `rinetd` 部署简易的端口转发功能，方便集中管理。

&lt;!--more--&gt;

## 安装

```bash
git clone https://github.com/samhocevar/rinetd.git

cd rinetd
./bootstrap
./configure --prefix=/usr/bin --sysconfdir=/etc
make -j &amp;&amp; make install

## 需要手动拷贝一份
cp rinetd /usr/bin/
```

## 配置

```bash
vim /etc/rinetd.conf

#
# forwarding rules come here
#
# you may specify allow and deny rules after a specific forwarding rule
# to apply to only that forwarding rule
#
# bindadress  bindport  connectaddress  connectport  options...
# 0.0.0.0     80        192.168.1.2     80
# ::1         80        192.168.1.2     80
# 0.0.0.0     80        fe80::1         80
# 127.0.0.1   4000      127.0.0.1       3000
# 127.0.0.1   4000/udp  127.0.0.1       22           [timeout=1200]
# 127.0.0.1   8000/udp  192.168.1.2     8000/udp     [src=192.168.1.2,timeout=1200]
## vim /usr/local/v2ray/config.json 配置端口，允许外部访问
## 然后本地直接访问 127.0.0.1, 如 proxychains4
127.0.0.1   1086      192.168.1.82      1086

# logging information
logfile /var/log/rinetd.log
```

## systemd

编辑 `rinetd.service`

```bash
[Unit]
Description=rinetd
After=syslog.target network.target
Wants=network.target

[Service]
Type=forking
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/rinetd -c /etc/rinetd.conf

[Install]
WantedBy=multi-user.target
```

启动服务

```bash
systemctl daemon-reload
systemctl enable rinetd.service
systemctl restart rinetd.service
systemctl status rinetd.service

● rinetd.service - rinetd
     Loaded: loaded (/etc/systemd/system/rinetd.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2024-05-15 14:23:07 CST; 6min ago
    Process: 3694050 ExecStart=/usr/bin/rinetd -c /etc/rinetd.conf (code=exited, status=0/SUCCESS)
   Main PID: 3694053 (rinetd)
      Tasks: 1 (limit: 76689)
     Memory: 676.0K
     CGroup: /system.slice/rinetd.service
             └─3694053 /usr/bin/rinetd -c /etc/rinetd.conf

May 15 14:23:07 xps systemd[1]: Starting rinetd...
May 15 14:23:07 xps rinetd[3694053]: starting redirections...
May 15 14:23:07 xps systemd[1]: Started rinetd.
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-15-rinetd-%E5%AE%9E%E7%8E%B0%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91/  

