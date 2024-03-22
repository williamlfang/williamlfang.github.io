# Linux 多网卡 bond


`bond` 可以将多个网卡绑定到一起，可以让两个或多个接口作为一个接口，同时提高带宽，并提供网络链路的冗余，当有其中一块网卡故障的时候，不会中断服务器的业务。

# 查看系统 bond

```bash
###bond模块常用信息
## 查看bond模块信息
modinfo bonding

## 查看bond模块是否加载
lsmod | grep bonding

## 加载bond模块
modprobe --first-time bonding        ##临时加载，重启失效
modprobe bonding                     ##永久加载

## 可以卸载模块
modprobe -r bonding
```

# 设置网卡bond

`CentOS7` 的网卡配置位于 ``/etc/sysconfig/network-scripts`

```bash
cd /etc/sysconfig/network-scripts

-rw-r--r--. 1 root root   363 Mar 23 07:52 ifcfg-em1
-rw-r--r--. 1 root root   100 Mar 26 05:56 ifcfg-em2
-rw-r--r--. 1 root root   100 Mar 26 05:56 ifcfg-em3
-rw-r--r--. 1 root root   275 Mar 20 02:45 ifcfg-em4
-rw-r--r--. 1 root root   254 Aug 24  2018 ifcfg-lo
-rw-r--r--. 1 root root   281 Mar 22 08:42 ifcfg-p1p1
-rw-r--r--. 1 root root   312 Mar 25 06:27 ifcfg-p1p2
lrwxrwxrwx. 1 root root    24 Mar 20 02:42 ifdown -&gt; ../../../usr/sbin/ifdown
-rwxr-xr-x. 1 root root   654 Aug 24  2018 ifdown-bnep
-rwxr-xr-x. 1 root root  6532 Aug 24  2018 ifdown-eth
-rwxr-xr-x. 1 root root  6190 Oct 30  2018 ifdown-ib
-rwxr-xr-x. 1 root root   781 Aug 24  2018 ifdown-ippp
-rwxr-xr-x. 1 root root  4540 Aug 24  2018 ifdown-ipv6
lrwxrwxrwx. 1 root root    11 Mar 20 02:42 ifdown-isdn -&gt; ifdown-ippp
-rwxr-xr-x. 1 root root  2130 Aug 24  2018 ifdown-post
-rwxr-xr-x. 1 root root  1068 Aug 24  2018 ifdown-ppp
-rwxr-xr-x. 1 root root   870 Aug 24  2018 ifdown-routes
-rwxr-xr-x. 1 root root  1456 Aug 24  2018 ifdown-sit
-rwxr-xr-x. 1 root root  1621 Mar 17  2017 ifdown-Team
-rwxr-xr-x. 1 root root  1556 Mar 17  2017 ifdown-TeamPort
-rwxr-xr-x. 1 root root  1462 Aug 24  2018 ifdown-tunnel
lrwxrwxrwx. 1 root root    22 Mar 20 02:42 ifup -&gt; ../../../usr/sbin/ifup
-rwxr-xr-x. 1 root root 12415 Aug 24  2018 ifup-aliases
-rwxr-xr-x. 1 root root   910 Aug 24  2018 ifup-bnep
-rwxr-xr-x. 1 root root 13475 Aug 24  2018 ifup-eth
-rwxr-xr-x. 1 root root 10114 Oct 30  2018 ifup-ib
-rwxr-xr-x. 1 root root 12075 Aug 24  2018 ifup-ippp
-rwxr-xr-x. 1 root root 11893 Aug 24  2018 ifup-ipv6
lrwxrwxrwx. 1 root root     9 Mar 20 02:42 ifup-isdn -&gt; ifup-ippp
-rwxr-xr-x. 1 root root   650 Aug 24  2018 ifup-plip
-rwxr-xr-x. 1 root root  1064 Aug 24  2018 ifup-plusb
-rwxr-xr-x. 1 root root  4997 Aug 24  2018 ifup-post
-rwxr-xr-x. 1 root root  4154 Aug 24  2018 ifup-ppp
-rwxr-xr-x. 1 root root  2001 Aug 24  2018 ifup-routes
-rwxr-xr-x. 1 root root  3303 Aug 24  2018 ifup-sit
-rwxr-xr-x. 1 root root  1755 Mar 17  2017 ifup-Team
-rwxr-xr-x. 1 root root  1876 Mar 17  2017 ifup-TeamPort
-rwxr-xr-x. 1 root root  2711 Aug 24  2018 ifup-tunnel
-rwxr-xr-x. 1 root root  1836 Aug 24  2018 ifup-wireless
-rw-r--r--. 1 root root  2206 Mar 26 05:50 inactive
-rwxr-xr-x. 1 root root  5419 Aug 24  2018 init.ipv6-global
-rw-r--r--. 1 root root 20671 Aug 24  2018 network-functions
-rw-r--r--. 1 root root 31027 Aug 24  2018 network-functions-ipv6
```

可以看到，当前系统有4个 `em` 千兆网卡，已经2个 `p1` 万兆网卡，接下来我们把 `em2` 和 `em3` bond 到一个虚拟网卡上。注意，最好先备份网卡配置信息，因为我们做 bond 的时候不需要网卡 `mac` 地址，所以原来的信息会被删除，备份一个原来的文件比较安全。

说明：把原有的配置 ip 信息去掉，把 BOOTPROTO 修改成 none，然后新加 MASTER=bond0，SLAVE=yes 即可

```bash
## 网卡 em2，不需要 mac 地址，绑定到 bond0
vim ifcfg-em2

NAME=em2
DEVICE=em2
TYPE=Ethernet
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
MASTER=bond0
SLAVE=yes

## 网卡 em3，不需要 mac 地址，绑定到 bond0
vim ifcfg-em3

NAME=em3
DEVICE=em3
TYPE=Ethernet
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
MASTER=bond0
SLAVE=yes

## 开始设置 bond0，设置模式 6：负载均衡
vim ifcfg-bond0

DEVICE=bond0
TYPE=Ethernet
BOOTPROTO=static
BONDING_MASTER=yes
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS=&#34;mode=6 miimon=100&#34;  ## 配置此项就无需创建modprobe.conf文件
IPADDR=192.168.1.213
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=114.114.114.114
```

现在，我们可以重启网络

```bash
# 重启网络
systemctl restart network

## 如果报错 Failed to start LSB: Bring up/down networking
## 可能跟 NetworkManager 服务有冲突
systemctl stop NetworkManager
chkconfig NetworkManager off

# 查看bond信息
cat /proc/net/bonding/bond0
```

看到，目前的模式已经是 `adaptive load balancing`

```bash
Bonding Mode: adaptive load balancing
Primary Slave: None
Currently Active Slave: em2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: em2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 2c:ea:7f:ea:9b:29
Slave queue ID: 0

Slave Interface: em3
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 2c:ea:7f:ea:9b:2a
Slave queue ID: 0
```

我们可以查看一下当前 bond0 的网络配置，看出来网卡已经可以使用叠加后的网速了

```bash
ethtool bond0
Settings for bond0:
        Supported ports: [ ]
        Supported link modes:   Not reported
        Supported pause frame use: No
        Supports auto-negotiation: No
        Supported FEC modes: Not reported
        Advertised link modes:  Not reported
        Advertised pause frame use: No
        Advertised auto-negotiation: No
        Advertised FEC modes: Not reported
        Speed: 13000Mb/s
        Duplex: Full
        Port: Other
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: off
        Link detected: yes
```





# bond 的配置参数详解

```bash
miimon    指定链路监控频率，单位毫秒，默认值为0(关闭),一般设置100以上

mode      指定一种绑定策略，默认值为0(balance-rr)轮询。
    0    balance-rr    轮询策略(round-robin)
    1    active-backup 主备策略(当主网卡不可用时，启动备用)
    2    balance-xor   XOR策略
    3    broadcast     广播策略
    4    802.3ad       动态链接聚合,创建具有相同速度的聚合组和双工设置
    5    balance-tlb   发送负载均衡
    6    balance-alb   收发负载均衡(各个网络实现负载均衡，我们选择此模式)

max_bonds    指定创建bond的数量，默认1

更多帮助查看/usr/share/doc/iputils-20160308/README.bonding
```

# 常用命令

```
ifdown em1
ifup em1

ethtool em1

ethtool bond0

cat /proc/net/bonding/bond0
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-03-27-linux-%E5%A4%9A%E7%BD%91%E5%8D%A1-bond/  

