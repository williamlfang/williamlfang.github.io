# linux 设置超级用户程序


通过在 `Linux` 系统配置一个超级用户程序，获取 `root` 权限

&lt;!--more--&gt;

# c程序

&gt; 一定要使用普通用户

```c
// super.c
// --------
#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;sys/types.h&gt;
#include &lt;unistd.h&gt;

int main(void)
{
    setuid(0);
    clearenv();
    system(&#34;export TERM=linux; export PATH=/sbin:/bin:/usr/bin:/usr/local/bin:$PATH; export TERM=linux; /bin/bash&#34;);
}
```

# 编译

&gt; 一定要使用普通用户

```bash
gcc super.c -o super
```

这里可以试一下执行程序，发现依然是当前用户

```bash
[trader@localhost ~]$ ll
total 16
-rwxrwxr-x 1 trader trader 8216 Oct 25 20:36 super
-rw-r--r-- 1 root   trader  170 Oct 25 20:34 super.c
[trader@localhost ~]$ ./super
[trader@localhost trader]$ whoami
trader
```

# 权限

下面，我们来设置这个可执行程序的权限，使得其可以在普通用户的环境中，也是可以使用默认的 `root` 权限运行的。

使用 `root` 权限修改可执行程序：

```bash
sudo chown root super
sudo chmod ug&#43;s super
sudo chmod a&#43;x super
```

如此一来，我们便可以通过执行 `super` 自动获取 `root` 权限了

```bash
[trader@localhost ~]$ ll
total 16
-rwsrwsr-x 1 root trader 8216 Oct 25 20:36 super
-rw-r--r-- 1 root trader  170 Oct 25 20:34 super.c
[trader@localhost ~]$ ./super
[root@localhost trader]# whoami
root
[root@localhost trader]# mkdir -p /usr/test
[root@localhost trader]# rm -rf /usr/test
[root@localhost trader]#
```

# 添加用户到 sudoers

```bash
sudo vim /etc/sudoers

## 多个命令用逗号分割
## NOPASSWD 表示不用输入密码
ops ALL=(ALL) NOPASSWD:/usr/bin/bash
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-linux-%E8%AE%BE%E7%BD%AE%E8%B6%85%E7%BA%A7%E7%94%A8%E6%88%B7%E7%A8%8B%E5%BA%8F/  

