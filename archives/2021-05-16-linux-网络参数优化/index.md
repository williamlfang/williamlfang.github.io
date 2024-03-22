# Linux 网络参数优化




# 设置 sysctl

```bash
## 如果出现报错 sysctl: cannot stat /proc/sys/–p: No such file or directory
## 则需要执行以下命令

modprobe br_netfilter
ls /proc/sys/net/bridge
## 记得输入该命令及时生效
sysctl -p
```
&lt;!--more--&gt;

``/etc/sysctl.conf``文件是一个允许你改变正在运行中的[Linux](http://www.ttlsa.com/linux/)系统的接口。它包含一些TCP/IP堆栈和虚拟内存系统的高级选项，可用来控制Linux网络配置，由于/proc/sys/net目录内容的临时性，建议把TCPIP参数的修改添加到``/etc/sysctl.conf`文件, 然后保存文件，使用命令“/sbin/sysctl –p”使之立即生效。具体修改方案参照上文：



# 设置网络参数

可以先查看网络参数

```bash
cat /proc/sys/net/core/rmem_max

## 128MB=134217728
## 1GB	=1073741824
```

接着修改/proc/sys/net/core/rmem_max 以及rmem_default数值到128M大小，命令如下

```bash
sysctl –w net.core.rmem_default=”134217728” #128M
sysctl –w net.core.rmem_max=”134217728” #128M
sysctl –w net.core.wmem_default=”134217728” #128M
sysctl –w net.core.wmem_max=”134217728” #128M
sysctl –w net.ipv4.udp_mem=” 134217728 134217728 268435456”
sysctl –w net.ipv4.udp_rmem_min=” 134217728” #128M
sysctl –w net.ipv4.udp_wmem_min=” 134217728” #128M
```

然后保存修改 `/etc/sysctl.conf`

```bash
vim /etc/sysctl.conf

# 添加下面的参数
## 允许送到队列的数据包的最大数目
net.core.netdev_max_backlog=262144
## 用来限制监听(LISTEN)队列最大数据包的数量
net.core.somaxconn=4096
## 修改内核缓存大小
net.core.rmem_default=134217728		## 128M
net.core.rmem_max=134217728			## 128M
net.core.wmem_default=134217728		## 128M
net.core.wmem_max=134217728			## 128M

#内核分配给TCP连接的内存，单位是Page，1 Page = 4096 Bytes，可用命令查看：
#getconf PAGESIZE
#第一个数字表示，当 tcp 使用的 page 少于 1048576 时，kernel 不对其进行任何的干预
#第二个数字表示，当 tcp 使用了超过 1310720 的 pages 时，kernel 会进入 “memory pressure” 压力模式
#第三个数字表示，当 tcp 使用的 pages 超过 1572864 时（相当于1.6GB内存），就会报：Out of socket memory
## net.ipv4.tcp_mem = 1048576 1310720 1572864
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.ipv4.udp_mem = 134217728 134217728 268435456	## 128M
net.ipv4.udp_rmem_min = 134217728		## 128M
net.ipv4.udp_wmem_min = 134217728		## 128M

## 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭
net.ipv4.tcp_tw_reuse=1
## 表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭
net.ipv4.tcp_tw_recycle=1
## keepalive的保持时间
net.ipv4.tcp_keepalive_time=300
## 表示如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2状态的时间（可改为30，一般来说FIN-WAIT-2的连接也极少）
net.ipv4.tcp_fin_timeout=30
## 示那些尚未收到客户端确认信息的连接（SYN消息）队列的长度，默认为1024，加大队列长度为819200，可以容纳更多等待连接的网络连接数。
net.ipv4.tcp_max_syn_backlog=819200
## 表示系统同时保持TIME_WAIT套接字的最大数量，如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印告警信息。默认为180000，更改为8192000.对于Apache，Nginx等服务器，上几行参数可以很好的减少TIME_WAIT套接字数量，但是对于Squid，效果不大。此项参数可以控制TIME_WAIT套接字的最大数量，避免Squid服务器被大量的TIME_WAIT套接字拖死
net.ipv4.tcp_max_tw_buckets = 8192000
## 该参数用于设定系统中最多允许存在多少tcp套接字不被关联到任何一个用户文件句柄上。如果超过这个数字，没有与用户文件句柄关联的tcp套接字符将立即被复位，同时给出警告信息。这个限制只是为了防止简单的DoS工具。一般在系统内存比较充足的情况下，可以增大这个参数的赋值：
net.ipv4.tcp_max_orphans=3276800
## 管理TCP的选择性应答，允许接收端向发送端传递关于字节流中丢失的序列号，减少了段丢失时需要重传的段数目，当段丢失频繁时，sack是很有益的。
net.ipv4.tcp_sack=1
## 支持更大的TCP窗口. 如果TCP窗口最大超过65535(64K), 必须设置该数值为1
net.ipv4.tcp_window_scaling=1
## tcp_synack_retries 显示或设定 Linux 核心在回应 SYN 要求时会尝试多少次重新发送初始 SYN,ACK 封包后才决定放弃。这是所谓的三段交握 (threeway handshake) 的第二个步骤。即是说系统会尝试多少次去建立由远端启始的 TCP 连线。tcp_synack_retries 的值必须为正整数，并不能超过 255。因为每一次重新发送封包都会耗费约 30 至 40 秒去等待才决定尝试下一次重新发送或决定放弃。tcp_synack_retries 的缺省值为 5，即每一个连线要在约 180 秒 (3 分钟) 后才确定逾时.
net.ipv4.tcp_synack_retries = 1

## kernel 相关
## 由于linux下的程序有时候需要根据core文件来判断出错的
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

##　文件系统相关
fs.file-max=65535
fs.inotify.max_user_instances=8192
```

执行命令保存**永久修改**

```bash
## 永久修改，配置后需要执行sysctl -p生效
sysctl -p
```

最后，需要把 /proc/sys/net/core/netdev_max_backlog 调整到4000

```bash
cat /proc/sys/net/core/netdev_max_backlog

vim /proc/sys/net/core/netdev_max_backlog

## 设置为
4000
```

设置 `rx/tx` 大小

```bash
ethtool -g ifname
ethtool -G ifname rx/tx 4096
```





# 参考链接

1. [Linux下TCP/IP内核参数优化](http://www.ttlsa.com/linux/the-tcp-ip-kernel-parameter-optimization-of-linux/)
2. [Linux内核socket优化项](https://www.cnblogs.com/tangshengwei/p/5566606.html)
3. [ethtool原理介绍和解决网卡丢包排查思路](https://zhuanlan.zhihu.com/p/150086151)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-05-16-linux-%E7%BD%91%E7%BB%9C%E5%8F%82%E6%95%B0%E4%BC%98%E5%8C%96/  

