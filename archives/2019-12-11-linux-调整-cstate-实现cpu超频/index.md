# Linux 调整 cstate 实现cpu超频


随着技术的发展，现在主流的 Intel CPU 的主频都能达到 3GHz 以上，而且还支持超频技术。为了最大的获取 CPU 的性能，我们可以对 `cstate` 进行调整。

# Ubuntu 设置

与开机项有关的参数设置在 `/etc/default/grub`，可以对其进行调整

```bash
cat /etc/default/grub

# If you change this file, run &#39;update-grub&#39; afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n &#39;Simple configuration&#39;

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR=`lsb_release -i -s 2&gt; /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT=&#34;quiet splash&#34;
GRUB_CMDLINE_LINUX=&#34;&#34;

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM=&#34;0x01234567,0xfefefefe,0x89abcdef,0xefefefef&#34;

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `vbeinfo&#39;
#GRUB_GFXMODE=640x480

# Uncomment if you don&#39;t want GRUB to pass &#34;root=UUID=xxx&#34; parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY=&#34;true&#34;

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE=&#34;480 440 1&#34;
```

然后找到 `GRUB_CMDLINE_LINUX_DEFAULT` 所在的那行，增加配置

- processor.max_cstate=0
- intel_idle.max_cstate=0

```bash
sudo vim /etc/default/grub

GRUB_CMDLINE_LINUX_DEFAULT=&#34;quiet splash  processor.max_cstate=0 intel_idle.max_cstate=0&#34;
```

然后更新 `grub`

```bash
sudo update-grub
```

另外可以设置CPU的scale-governor

```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor


## 设置CPU模式, 分别根据CPU 0-n 的编号进行设置
echo performance &gt; /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance &gt; /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance &gt; /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance &gt; /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

systemctl disable ondemand
/etc/rc.local

cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
```


重启后即可实现超频。

```bash
sudo reboot now
```

使用命令

- `cpufreq-info` 查看当前 CPU 运行
- `cpufreq-set` 也可以进行单独设置
- `cpufreq-aperf` 用于计算一段时间内的平均频率

```bash
sudo apt install cpufrequtils

## 查看当前运行
cpufreq-info

cpufrequtils 008: cpufreq-info (C) Dominik Brodowski 2004-2009
Report errors and bugs to cpufreq@vger.kernel.org, please.
analyzing CPU 0:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  maximum transition latency: 4294.55 ms.
  hardware limits: 800 MHz - 3.60 GHz
  available cpufreq governors: performance, powersave
  current policy: frequency should be within 800 MHz and 3.60 GHz.
                  The governor &#34;performance&#34; may decide which speed to use
                  within this range.
  current CPU frequency is 1.52 GHz.
analyzing CPU 1:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 1
  CPUs which need to have their frequency coordinated by software: 1
  maximum transition latency: 4294.55 ms.
  hardware limits: 800 MHz - 3.60 GHz
  available cpufreq governors: performance, powersave
  current policy: frequency should be within 800 MHz and 3.60 GHz.
                  The governor &#34;performance&#34; may decide which speed to use
                  within this range.
  current CPU frequency is 2.66 GHz.
analyzing CPU 2:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 2
  CPUs which need to have their frequency coordinated by software: 2
  maximum transition latency: 4294.55 ms.
  hardware limits: 800 MHz - 3.60 GHz
  available cpufreq governors: performance, powersave
  current policy: frequency should be within 800 MHz and 3.60 GHz.
                  The governor &#34;performance&#34; may decide which speed to use
                  within this range.
  current CPU frequency is 960 MHz.
analyzing CPU 3:
  driver: intel_pstate
  CPUs which run at the same hardware frequency: 3
  CPUs which need to have their frequency coordinated by software: 3
  maximum transition latency: 4294.55 ms.
  hardware limits: 800 MHz - 3.60 GHz
  available cpufreq governors: performance, powersave
  current policy: frequency should be within 800 MHz and 3.60 GHz.
                  The governor &#34;performance&#34; may decide which speed to use
                  within this range.
  current CPU frequency is 1.05 GHz.
```



# CentOS 设置

```bash
sudo vim /etc/default/grub

## 找到 GRUB_CMDLINE_LINUX_DEFAULT
## 然后增加 processor.max_cstate=1 intel_idle.max_cstate=0
GRUB_CMDLINE_LINUX_DEFAULT=&#34;${GRUB_CMDLINE_LINUX_DEFAULT:&#43;$GRUB_CMDLINE_LINUX_DEFAULT }\$tuned_params processor.max_cstate=1 intel_idle.max_cstate=0&#34;

## 更新配置
sudo grub2-mkconfig –o /boot/grub2/grub.cfg

## 重启即可，有可能会报警 CPU 温度过热，在启动项里忽略即可运行
sudo reboot now
```

查看当前运行情况

```bash
sudo cpupower monitor -m Idle_Stats
    |Idle_Stats
CPU | POLL | C1-S | C1E- | C3-S | C6-S | C7s- | C8-S | C9-S | C10-
   0|  0.00| 99.39|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   1|  0.00| 98.98|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   2|  0.00| 95.21|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   3|  0.00| 97.58|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   4|  0.00| 99.88|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   5|  0.00| 99.38|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00

sudo cpupower frequency-info
analyzing CPU 0:
 driver: intel_pstate
 CPUs which run at the same hardware frequency: 0
 CPUs which need to have their frequency coordinated by software: 0
 maximum transition latency:  Cannot determine or is not supported.
 hardware limits: 800 MHz - 4.10 GHz
 available cpufreq governors: performance powersave
 current policy: frequency should be within 800 MHz and 4.10 GHz.
                 The governor &#34;performance&#34; may decide which speed to use
                 within this range.
 current CPU frequency: 3.54 GHz (asserted by call to hardware)
 boost state support:
   Supported: yes
   Active: yes

## 查看当前cpu模式
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
performance
performance
performance
performance
performance
performance

## 设置CPU模式, 分别根据CPU 0-n 的编号进行设置
echo performance &gt; /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

# c-state 各种状态表


| mode   | Name                  | What id does                                                 | CPUs                                                         |
| :----- | :-------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| C1     | Operating State       | CPU fully turned on                                          | All CPUs                                                     |
| C1E    | Halt                  | Stops CPU main internal clocks via software; bus interface unit and APIC are kept running at full speed | 486DX4 and above                                             |
| C1E    | Enhanced Halt         | Stops CPU main internal clocks via software and reduces CPU voltage; bus interface unit and APIC are kept running at full speed | All socket 775 CPUs                                          |
| C1E    | --                    | Stops all CPU internal clocks                                | Turion 64, 65-nm Athlon X2 and Phenom CPUs                   |
| C2     | Stop Grant            | Stops CPU main internal clocks via hardware; bus interface unit and APIC are kept running at full speed | 486DX4 and above                                             |
| C2     | Stop Clock            | Stops CPU internal and external clocks via hardware          | Only 486DX4, Pentium, Pentium MMX, K5, K6, K6-2, K6-III      |
| C2E    | Extended Stop Grant   | Stops CPU main internal clocks via hardware and reduces CPU voltage; bus interface unit and APIC are kept running at full speed | Core 2 Duo and above (Intel only)                            |
| C3     | Sleep                 | Stops all CPU internal clocks                                | Pentium II, Athlon and above, but not on Core 2 Duo E4000 and E6000 |
| C3     | Deep Sleep            | Stops all CPU internal and external clocks                   | Pentium II and above, but not on Core 2 Duo E4000 and E6000; Turion 64 |
| C3     | AltVID                | Stops all CPU internal clocks and reduces CPU voltage        | AMD Turion 64                                                |
| C4     | Deeper Sleep          | Reduces CPU voltage                                          | Pentium M and above, but not on Core 2 Duo E4000 and E6000 series; AMD Turion 64 |
| C4E/C5 | Enhanced Deeper Sleep | Reduces CPU voltage even more and turns off the memory cache | Core Solo, Core Duo and 45-nm mobile Core 2 Duo only         |
| C6     | Deep Power Down       | Reduces the CPU internal voltage to any value, including 0 V |                                                              |


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-11-linux-%E8%B0%83%E6%95%B4-cstate-%E5%AE%9E%E7%8E%B0cpu%E8%B6%85%E9%A2%91/  

