# Linux cpu 隔核设置




# 设置

```bash
## 查看多少个 cpu 核
cat /proc/cpuinfo |grep &#34;model name&#34;

## 修改 grub
vim /etc/default/grub

## 找到 GRUB_CMDLINE_LINUX 增加
## 隔离 1-2， 7-8
## 从 0 开始计数
ioslcpus=1-2,7-8

## 更新配置
grub2-mkconfig -o /boot/grub2/grub.cfg

## 重启生效
reboot

## 查看是否生效
cat /proc/cmdline
```
&lt;!--more--&gt;


# 直接修改 ``/boot/grub2/grub.cfg`



```bash
vim /boot/grub2/grub.cfg

linux16 /vmlinuz-3.10.0-1160.6.1.el7.x86_64 root=UUID=f11d0edd-f9a9-4b29-9811-eaafe33f61d5 ro crashkernel=auto rhgb quiet LANG=en_US.UTF-8

## 修改成
linux16 /vmlinuz-3.10.0-1160.6.1.el7.x86_64 root=UUID=f11d0edd-f9a9-4b29-9811-eaafe33f61d5 ro crashkernel=auto rhgb quiet LANG=en_US.UTF-8 intel_idle.max_cstate=0 processor.max_cstate=0 idle=poll pcie_aspm.policy=performance mce=ignore_ce nmi_watchdog=0 transparent_hugepage=never hpet=disable irqaffinity=0 noht nohz=on nosoftlockup isolcpus=1-15 rcu_nocbs=1-15 nohz_full=1-15
```





# 参考链接

1. [Linux 如何隔离CPU核心 isolcpus=0-2](https://blog.csdn.net/Rong_Toa/article/details/116533692)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-05-24-linux-cpu-%E9%9A%94%E6%A0%B8%E8%AE%BE%E7%BD%AE/  

