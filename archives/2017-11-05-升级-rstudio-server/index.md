# 升级 Rstudio Server



在 CentOS 操作系统更新 Rstudio-Server 软件，并进行相关的端口设置。
&lt;!--more--&gt;

# 强大的 `R IDE`

`Rstudio` 是非常强大的、专注于 `R` 统计语言编程环境的 `IDE`，基本取代了原生的操作界面而成为目前使用范围最广泛、功能最强大的编程软件。一般而言，我们在桌面 PC 操作系统，直接安装使用 `Rstudio` 即可实现代码编写、测试运行、画图等操作；而对于服务器，我们则需要安装 `Rstudio-Server` 这个版本，通过网页登录来模拟桌面的 `IDE`，实现完全无缝连接地使用我们最爱的 `R` 编辑与测试环境。

![通过网页访问 Rstudio](./fig01.png &#34;通过网页访问 Rstudio&#34;)

新版的 `Rstudio-Server` 还为我们贴心的提供了通过网页访问服务器 `Terminal` 的端口，即我们现在即可以在网页访问到 `R`，在上面进行编程、显示画图、测试运行，又可以通过终端进行 `shell` 命令操作，类似于实现了访问服务器终端的功能。

![新版提供了直接访问服务器终端的功能](./fig02.png &#34;新版提供了直接访问服务器终端的功能&#34;)

因此，我们决定对原来的 `CentOS` 操作系统安装的旧版进行省级。以下简要记录升级过程。

---

# 升级过程

## 下载新版软件

首先需要到 Rstudio 的官网下载最新版本的 Rstudio-server，记得选择 CentOS/RHEL


```bash
cd /tmp

## 下载最新版本号
wget https://download2.rstudio.org/rstudio-server-rhel-1.1.383-x86_64.rpm

## 使用管理员权限安装软件
sudo yum install --nogpgcheck rstudio-server-rhel-1.1.383-x86_64.rpm

sudo yum install -y initscripts
```

## 测试是否安装成功

安装完成后，默认的配置端口号为 `8787`，我们可以直接在浏览器输入：`192.168.1.166:8787`。


## 异常排查

如果没有意外的话，我们是可以直接在网页打开 Rstudio 界面的。不过，如果我们的更新的过程中，不小心把原来的程序关闭了，这时候需要重启端口


```bash
## 尝试重启服务
sudo rstudio-server restart
# initctl: Unknown instance
# rsession no process restart

## 增加远程访问 Rstudio 8787 端口
# 1.FirewallD防火墙开放8787端口
firewall-cmd --zone=public --add-port=8787/tcp --permanent
# 2.重启防火墙
systemctl restart firewalld.service

## 使用以下三个步骤来重新配置 8787 端口

## 1) check the process that used 8787
sudo fuser 8787/tcp

## 2) with the -k option to kill all process
sudo fuser -k 8787/tcp

## 3) start rstudio-server
sudo rstudio-server start
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2017-11-05-%E5%8D%87%E7%BA%A7-rstudio-server/  

