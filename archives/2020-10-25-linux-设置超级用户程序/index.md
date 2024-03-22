# Linux 设置超级用户程序


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
        system(&#34;export PATH=/sbin:/bin:/usr/bin:/usr/local/bin:$PATH; /bin/bash&#34;);
}
```
&lt;!--more--&gt;

# 编译

&gt;  一定要使用普通用户

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

# 参考链接

- [Calling a script from a setuid root C program - script does not run as root](https://stackoverflow.com/questions/556194/calling-a-script-from-a-setuid-root-c-program-script-does-not-run-as-root)
- [Can I make a script always execute as root?](https://superuser.com/questions/440363/can-i-make-a-script-always-execute-as-root)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-10-25-linux-%E8%AE%BE%E7%BD%AE%E8%B6%85%E7%BA%A7%E7%94%A8%E6%88%B7%E7%A8%8B%E5%BA%8F/  

