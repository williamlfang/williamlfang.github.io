# Linux 内存调优的两个重要参数


今天在看这篇介绍 **Linux 性能调优** 的博客([Linux Performance: Almost Always Add Swap Space](https://linuxblog.io/linux-performance-almost-always-add-swap-space/))，其中涉及到如何调整内核内存的调整机制。主要的参数有

- [ ] `swappiness`: This control is used to define how aggressively the kernel will swap memory pages. Higher values will increase aggressiveness; lower values decrease the amount of swap. (default = 60, recommended values between 1 and 60) Remove your swap for 0 value, but it is usually not recommended in most cases.
- [ ] `vfs_cache_pressure`: Controls the kernel’s tendency to reclaim the memory, which is used for caching of directory and inode objects. (default = 100, recommend value 50 to 200)

&lt;!--more--&gt;

我的理解是

- [ ] `swappiness`: 内核处理 swap 的激进程度。越小代表越不要进行 swap，尽可能把进程都存放在内存。这有利于提升性能。
- [ ] `vfs_cache_pressure`: 内核回收 `cache` 的激进程度。越小代表越不要回收 `cache`，尽可能保留所有的缓存在内存。这有利于提升性能。

一般而言，我们可以这样配置

```bash
cat &lt;&lt;EOF &gt;&gt;/etc/sysctl.conf
vm.swappiness=10
vm.vfs_cache_pressure=50
EOF

sysctl -p
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-03-29-linux-%E5%86%85%E5%AD%98%E8%B0%83%E4%BC%98%E7%9A%84%E4%B8%A4%E4%B8%AA%E9%87%8D%E8%A6%81%E5%8F%82%E6%95%B0/  

