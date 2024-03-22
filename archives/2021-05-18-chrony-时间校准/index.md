# chrony 时间校准


# 安装

```bash
yum -y install chrony
```
&lt;!--more--&gt;

# 配置

```bash
## 配置文件修改
vim /etc/chrony.conf

## 把不需要的 server 注释掉
## 然后增加需要时间对准的服务器IP
server ntp2.xtp.com iburst
server 10.228.39.1 iburst

driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
## 如果是服务器，需要开启这个允许IP接入
## allow 10.36.0.0/16
logdir /var/log/chrony
```

# 服务

```bash
systemctl enable chronyd.service
systemctl start chronyd.service
systemctl status chronyd.service -l

#确认同步来源的状态
chronyc activity

#立即手工同步
chronyc -a makestep

#查看时间同步源
chronyc sources -v

#查看时间同步源状态
chronyc sourcestats -v

#校准时间服务器
chronyc tracking -v

#硬件时间默认为UTC
timedatectl set-local-rtc 1
```

查看结果

```bash
chronyc sources -v
210 Number of sources = 1

  .-- Source mode  &#39;^&#39; = server, &#39;=&#39; = peer, &#39;#&#39; = local clock.
 / .- Source state &#39;*&#39; = current synced, &#39;&#43;&#39; = combined , &#39;-&#39; = not combined,
| /   &#39;?&#39; = unreachable, &#39;x&#39; = time may be in error, &#39;~&#39; = time too variable.
||                                                 .- xxxx [ yyyy ] &#43;/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================

^* 10.228.39.1                   1   6     7     2   -574us[ &#43;411us] &#43;/- 1500ms
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-05-18-chrony-%E6%97%B6%E9%97%B4%E6%A0%A1%E5%87%86/  

