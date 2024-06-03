# Linux 设置 cpu 高性能performance模式



通过设置 `cpu` 的运行模式，可以调整机器性能。

&lt;!--more--&gt;

## 常用模式

- ondemand：系统默认的超频模式，按需调节，内核提供的功能，不是很强大，但有效实现了动态频率调节，平时以低速方式运行，当系统负载提高时候自动提高频率。以这种模式运行不会因为降频造成性能降低，同时也能节约电能和降低温度。一般官方内核默认的方式都是 ondemand。
- interactive：交互模式，直接上最高频率，然后看 CPU 负荷慢慢降低，比较耗电。Interactive 是以 CPU 排程数量而调整频率，从而实现省电。InteractiveX 是以 CPU 负载来调整 CPU 频率，不会过度把频率调低。所以比 Interactive 反应好些，但是省电的效果一般。
- conservative：保守模式，类似于 ondemand，但调整相对较缓，想省电就用他吧。Google 官方内核，kang 内核默认模式。
- smartass：聪明模式，是 I 和 C 模式的升级，该模式在比 interactive 模式不差的响应的前提下会做到了更加省电。
- **performance**：性能模式！只有最高频率，从来不考虑消耗的电量，性能没得说，但是耗电量。
- powersave 省电模式，通常以最低频率运行。
- userspace：用户自定义模式，系统将变频策略的决策权交给了用户态应用程序，并提供了相应的接口供用户态应用程序调节 CPU 运行频率使用。也就是长期以来都在用的那个模式。可以通过手动编辑配置文件进行配置
- Hotplug：类似于 ondemand, 但是 cpu 会在关屏下尝试关掉一个 cpu，并且带有 deep sleep，比较省电。

## 安装软件

```bash
## centos
sudo yum install cpufreq-utils

## ubuntu
sudo apt-get install cpufrequtils
sudo apt-get install sysfsutils

## centos 查看频率信息
cpupower frequency-info
## ubuntu 查看 CPU 状态
cpufreq-info

## 把 cpu 调整到性能模式
## centos
sudo cpupower -c all frequency-set -g performance
## ubuntu
sudo cpufreq-set -g performance

## 通过设置默认模式，防止重启后恢复
sudo vim  /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
## 填写
performance

## 或者全局设置
sudo vim /etc/default/cpufrequtils
GOVERNOR=&#34;performance&#34;


## 重启配置生效
systemctl restart cpufrequtils
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-06-18-linux-%E8%AE%BE%E7%BD%AE-cpu-%E9%AB%98%E6%80%A7%E8%83%BDperformance%E6%A8%A1%E5%BC%8F/  

