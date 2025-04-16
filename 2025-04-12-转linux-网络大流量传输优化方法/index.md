# (转)Linux 网络大流量传输优化方法


提升 `Linux` 性能。

&lt;!--more--&gt;

## 内核参数调优

###  网络缓冲区调整


```bash
# 增加TCP读写缓冲区范围
echo &#34;net.ipv4.tcp_rmem = 4096 87380 16777216&#34; &gt;&gt; /etc/sysctl.conf
echo &#34;net.ipv4.tcp_wmem = 4096 65536 16777216&#34; &gt;&gt; /etc/sysctl.conf

# 增加最大缓冲区大小
echo &#34;net.core.rmem_max = 16777216&#34; &gt;&gt; /etc/sysctl.conf
echo &#34;net.core.wmem_max = 16777216&#34; &gt;&gt; /etc/sysctl.conf

# 增加默认缓冲区大小
echo &#34;net.core.rmem_default = 1048576&#34; &gt;&gt; /etc/sysctl.conf
echo &#34;net.core.wmem_default = 1048576&#34; &gt;&gt; /etc/sysctl.conf
```

### 连接处理优化

```bash
# 增加最大连接数
echo &#34;net.core.somaxconn = 32768&#34; &gt;&gt; /etc/sysctl.conf

# 增加等待连接队列大小
echo &#34;net.ipv4.tcp_max_syn_backlog = 8192&#34; &gt;&gt; /etc/sysctl.conf

# 启用TCP快速打开
echo &#34;net.ipv4.tcp_fastopen = 3&#34; &gt;&gt; /etc/sysctl.conf
```

### 拥塞控制算法

```bash
# 查看可用算法
sysctl net.ipv4.tcp_available_congestion_control

# 设置拥塞控制算法(推荐使用bbr或cubic)
echo &#34;net.ipv4.tcp_congestion_control = bbr&#34; &gt;&gt; /etc/sysctl.conf
```

## 文件系统优化

### 大文件传输优化

```bash
# 增加文件描述符限制
echo &#34;fs.file-max = 1000000&#34; &gt;&gt; /etc/sysctl.conf
ulimit -n 1000000

# 使用更高效的文件传输工具(如bbcp、rsync with --partial等)
```

## 网络协议栈优化

### TCP参数调整


```bash
# 启用时间戳
echo &#34;net.ipv4.tcp_timestamps = 1&#34; &gt;&gt; /etc/sysctl.conf

# 启用选择性确认
echo &#34;net.ipv4.tcp_sack = 1&#34; &gt;&gt; /etc/sysctl.conf

# 调整keepalive时间
echo &#34;net.ipv4.tcp_keepalive_time = 300&#34; &gt;&gt; /etc/sysctl.conf
echo &#34;net.ipv4.tcp_keepalive_probes = 5&#34; &gt;&gt; /etc/sysctl.conf
echo &#34;net.ipv4.tcp_keepalive_intvl = 15&#34; &gt;&gt; /etc/sysctl.conf
```

## 硬件和驱动优化

### 中断亲和性设置

```bash
# 查看网络接口的中断
cat /proc/interrupts | grep eth

# 设置中断亲和性(根据CPU核心数调整)
# 例如将eth0的中断绑定到CPU0
echo 1 &gt; /proc/irq/[中断号]/smp_affinity
```

### 启用巨帧(如果网络支持)

```bash
ifconfig eth0 mtu 9000
```

## 应用层优化

### 使用高效传输工具

-   **rsync**: `rsync -avz --partial --progress source destination`
-   **bbcp**: 专为高速网络设计的点对点拷贝工具
-   **iperf3**: 用于测试网络性能 `iperf3 -c server_ip`

### 多线程传输

```bash
# 使用axel多线程下载工具
axel -n 10 http://example.com/largefile.iso

# 使用parallel-rsync进行并行rsync传输
```

## 应用后验证

```bash
# 应用所有sysctl设置
sysctl -p

# 验证当前TCP参数
sysctl -a | grep tcp
```

### 监控网络性能

```bash
iftop -n -i eth0
nload eth0
```

## 注意事项

1.  根据实际硬件配置和网络环境调整参数值
2.  修改前备份原始配置文件
3.  生产环境建议先在测试环境验证
4.  不同Linux发行版可能有细微差异
5.  对于云环境，部分参数可能受限于云服务商设置

这些优化可以显著提高Linux系统在大流量传输场景下的性能，但最佳配置需要根据具体应用场景和硬件环境进行测试和调整。


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-04-12-%E8%BD%AClinux-%E7%BD%91%E7%BB%9C%E5%A4%A7%E6%B5%81%E9%87%8F%E4%BC%A0%E8%BE%93%E4%BC%98%E5%8C%96%E6%96%B9%E6%B3%95/  

