# Linux coredump 设置


注意：需要有普通用户写入权限的路径。

```bash
## 查看当前配置
cat /proc/sys/kernel/core_pattern

## 临时
echo &#34;/tmp/core-%e-%p-%t&#34; &gt; /proc/sys/kernel/core_pattern

## 使用 sysctl 设置
sysctl -w kernel.core_pattern=/tmp/core-%e-%p-%t
```

- %% 单个%字符
- %p 所dump进程的进程ID
- %u 所dump进程的实际用户ID
- %g 所dump进程的实际组ID
- %s 导致本次core dump的信号
- %t core dump的时间 (由1970年1月1日计起的秒数)
- %h 主机名
- %e 程序文件名

&lt;!--more--&gt;

# Ref

- [CoreDump设置方式](https://www.jianshu.com/p/f5c3134072d2)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-08-02-linux-coredump-%E8%AE%BE%E7%BD%AE/  

