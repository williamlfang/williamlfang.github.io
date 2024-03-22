# systemd 多个端口转发之模板


`systemd` 可以制作端口转发（`secure-tunnel`，也称作 `port-forwarding`），如[systemd 实现端口转发](https://williamlfang.github.io/post/2022-04-16-systemd-%E5%AE%9E%E7%8E%B0%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91/)。但是这个只能支持单个任务；当然，如果是多个任务，我们可以多写几个 `service` 文件即可。但是，这个不是最优选择，因为存在大量的重复配置。那么自然而然地，我们想到使用模板来进行配置，这样可以把共同的部分抽象出来，实现模板化操作。

&lt;!--more--&gt;

## 建立服务模板

到目录下面进行操作

```bash
-rw-r--r--. 1 root root  416 Jan 19 15:04 port-forwarding@.service
-rw-r--r--. 1 root root   85 Jan 19 14:49 port-forwarding@ops.r7
-rw-r--r--. 1 root root   86 Jan 19 15:01 port-forwarding@ops.r13
```

```bash
cd /usr/lib/systemd/system
```

首先建立一个 service 文件，里面通过配置模板，运行多开服务

```bash
vim port-forwarding@.service
```

这个服务模板的内容如下：

```bash
[Unit]
Description=Setup Port-Forwarding to %I
After=network.target

[Service]
## 使用用户执行命令
User=william
Environment=&#34;LOCAL_ADDR=localhost&#34;
EnvironmentFile=/usr/lib/systemd/system/port-forwarding@%i
ExecStart=/usr/bin/ssh -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes ${TARGET} ${CMD1} ${CMD2} ${CMD3} ${CMD4} ${CMD5}

# Restart every &gt;5 seconds to avoid StartLimitInterval failure
Restart=always
# Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

这里，我们指定了 `EnvironmentFile=/usr/lib/systemd/system/port-forwarding@%i`，这是一个模板化的参数

## 服务配置

接下来，我们只需要编写服务配置即可

```bash
## cat port-forwarding@ops.r7

TARGET=R7
CMD1=&#39;-R *:62114:127.0.0.1:22&#39;
CMD2=&#39;-R *:63115:127.0.0.1:22&#39;
CMD3=
CMD4=
CMD5=

## 注意，这种模板只能配置一个端口转发，可以理解成只监控一个端口的活跃状态
```

## 启动服务

```bash
systemctl daemon-reload

## 启动某个服务
systemctl enable port-forwarding@ops.r7.service
systemctl enable port-forwarding@ops.r13.service

systemctl list-units |grep port

systemctl start port-forwarding@ops.r7.service
systemctl start port-forwarding@ops.r13.service

systemctl status  port-forwarding@ops.r7.service
● port-forwarding@ops.r7.service - Setup Port-Forwarding to ops.r7
   Loaded: loaded (/usr/lib/systemd/system/port-forwarding@.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2023-01-19 15:05:03 CST; 16min ago
 Main PID: 16980 (ssh)
   CGroup: /docker/72915ff761ba3a0adee44ce36ae26f124f87a73aad3456a2bb515c0ca54e7a4f/system.slice/system-port\x2dforwarding.slice/port-forwarding@ops.r7.service
           └─16980 /usr/bin/ssh -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -L 127.0.0.1:60178:192.168.1.177:22 R7
           ‣ 16980 /usr/bin/ssh -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -L 127.0.0.1:60178:192.168.1.177:22 R7

Jan 19 15:05:03 mon.machine systemd[1]: Started Setup Port-Forwarding to ops.r7.

systemctl status  port-forwarding@ops.r13.service
● port-forwarding@ops.r13.service - Setup Port-Forwarding to ops.r13
   Loaded: loaded (/usr/lib/systemd/system/port-forwarding@.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2023-01-19 15:05:00 CST; 16min ago
 Main PID: 16894 (ssh)
   CGroup: /docker/72915ff761ba3a0adee44ce36ae26f124f87a73aad3456a2bb515c0ca54e7a4f/system.slice/system-port\x2dforwarding.slice/port-forwarding@ops.r13.service
           └─16894 /usr/bin/ssh -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -L 127.0.0.1:60183:192.168.1.183:22 R13
           ‣ 16894 /usr/bin/ssh -NT -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -L 127.0.0.1:60183:192.168.1.183:22 R13

Jan 19 15:05:00 mon.machine systemd[1]: Started Setup Port-Forwarding to ops.r13.
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-01-18-systemd-%E5%A4%9A%E4%B8%AA%E7%AB%AF%E5%8F%A3%E8%BD%AC%E5%8F%91%E4%B9%8B%E6%A8%A1%E6%9D%BF/  

