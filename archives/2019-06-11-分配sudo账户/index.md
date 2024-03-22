# 分配sudo账户


sudo是linux系统管理指令，是允许系统管理员让普通用户执行一些或者全部的root命令的一个工具，如halt、reboot、su等等。

&lt;!--more--&gt;

我们可以把某个账户设置成为一个默认拥有「sudo」权限，同时不需要输入密码，这对于需要使用特殊权限才能执行的命令而言，是十分有必要的。

```bash
sudo usermod -aG wheel trader
vim /etc/sudoers

## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
trader  ALL=(ALL) NOPASSWD: ALL

## Allows people in group wheel to run all commands
%wheel  ALL=(ALL) NOPASSWD: ALL

:wq!
```

如果你想设置只有某些命令可以sudo的话，

```bash
your_user_name   ALL= (root) NOPASSWD: /bin/rm, (root) NOPASSWD: /usr/bin/make, (root) NOPASSWD: /bin/ln, (root) NOPASSWD: /bin/sh, (root) NOPASSWD: /bin/mv, (root) NOPASSWD: /bin/chown
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-06-11-%E5%88%86%E9%85%8Dsudo%E8%B4%A6%E6%88%B7/  

