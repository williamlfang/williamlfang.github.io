# 设置 coredump 文件路径


设置 `coredump` 保存的文件路径。

&lt;!--more--&gt;

 ```bash
## echo 后面内容最好不要带上引号，有的系统会把引号也带入
## 通过设置 core 文件的名称以及路径，程序 coredump 的时候就会在指定路径按照指定的规则命名生成 core 文件。
## 可以在 core_pattern 模板中使用变量见下面的列表：
## - %% 单个 % 字符
## - %p 所 dump 进程的进程 ID
## - %u 所 dump 进程的实际用户 ID
## - %g 所 dump 进程的实际组 ID
## - %s 导致本次 core dump 的信号
## - %t core dump 的时间 (由 1970 年 1 月 1 日计起的秒数)
## - %h 主机名
## - %e 程序文件名

## 临时修改
echo /usr/core_log/core_%e_%t_%p &gt; /proc/sys/kernel/core_pattern
## 永久修改在 /etc/sysctl.conf
## 在该文件的最后加上两行：
kernel.core_pattern = /var/core_log/core_%e_%t_%p
kernel.core_uses_pid = 0
## 可以使用以下命令，使修改结果马上生效。
/usr/sbin/sysctl -p

## 临时修改
ulimit-c unlimited
## 永久修改：打开 /etc/security/limits.conf  文件，在该文件的最后加上两行
## 配置好后，放回原目录，重启 reboot。
## 下面是我的配置
@root soft core unlimited
@root hard core unlimited
 ```

gdb 打开 core 文件时，有显示没有调试信息，因为之前编译的时候没有带上 -g 选项，没有调试信息是正常的，实际上它也不影响调试 core 文件。因为调试 core 文件时，符号信息都来自符号表，用不到调试信息。
查看堆栈使用 bt 或者 where 命令
此时，frame addr(帧数) 或者简写如上，f 1 跳转到 core 堆栈的第 1 帧。因为第 0 帧是 libc 的代码，已经不是我们自己代码了。
当然，现实环境中，coredump 的场景肯定远比这个复杂，都是逻辑都是一样的，我们需要先找到 coredump 的位置，再结合代码以及 core 文件推测 coredump 的原因。


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-03-10-%E8%AE%BE%E7%BD%AE-coredump-%E6%96%87%E4%BB%B6%E8%B7%AF%E5%BE%84/  

