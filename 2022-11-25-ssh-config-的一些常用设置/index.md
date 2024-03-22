# ssh config 的一些常用设置


一些常用的 `~/.ssh/config` 设置

&lt;!--more--&gt;

```bash
Host *
    ServerAliveInterval 60
    IdentitiesOnly=yes
    StrictHostKeyChecking=no

## ==========================================
Host lfang.r8
    HostName 192.168.1.xxxx
    Port 22
    User lfang
```

- `ServerAliveInterval 60` 保持 60 秒持续向服务器发送心跳，从而保持 `ssh` 持续连接状态
- `StrictHostKeyChecking=no` 去掉严格检查，如果一些服务器的 IP 发生了变化，可以通过 `ssh-keygen -R xx.xx.xx.xx` 去掉，或者修改 `~/.ssh/known_hosts`，而这个则通过设置，直接忽略相关的报警，可以迅速的进行重新匹配。


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-25-ssh-config-%E7%9A%84%E4%B8%80%E4%BA%9B%E5%B8%B8%E7%94%A8%E8%AE%BE%E7%BD%AE/  

