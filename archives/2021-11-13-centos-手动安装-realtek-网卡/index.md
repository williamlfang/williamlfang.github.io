# Centos 手动安装 Realtek 网卡


由于 CentOS7 无法识别最新的 Realtek 网卡，我们需要通过单独安装一个内核程序才能使用网卡。

&lt;!--more--&gt;

## 安装依赖

- elrepo-release-7.0-5.el7.elrepo.noarch.rpm
- kernel-3.10.0-1160.el7.x86_64.rpm
- kmod-r8125-9.003.05-1.el7_8.elrepo.x86_64.rpm
- linux-firmware-20200421-79.git78c0348.el7.noarch.rpm

```
rpm -Uvh .*rpm

reboot
```

## 识别网卡

```
nmtui
```

# Reference
- 这个更简单：[Centos安装拓展PCIe网卡驱动](https://alanfanh.github.io/2020/05/24/Centos%E5%AE%89%E8%A3%85pcie%E7%BD%91%E5%8D%A1%E9%A9%B1%E5%8A%A8/)
- [超贴心）Centos7 安装 2.5G 网卡驱动（Realtek 3000）_音程的博客](https://blog.csdn.net/qq_43391414/article/details/120602456)
- [CentOS 添加网卡 没有对应网卡配置文件解决方法](https://www.cnblogs.com/wdyjt/p/14159155.html)


---

> 作者: william  
> URL: http://localhost:1313/archives/2021-11-13-centos-%E6%89%8B%E5%8A%A8%E5%AE%89%E8%A3%85-realtek-%E7%BD%91%E5%8D%A1/  

