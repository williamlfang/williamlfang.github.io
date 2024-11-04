# Linux 报错：too many open files


查看文件数

```bash
ulimit -a

ulimit -n
```

增加文件数

```bash
vim /etc/security/limits.conf

* soft nofile 40960
* hard nofile 40960
```

注销后重新登录即可生效。

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-11-04-linux-%E6%8A%A5%E9%94%99-too-many-open-files/  

