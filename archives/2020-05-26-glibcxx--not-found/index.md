# GLIBCXX: not found


无法找到 GLIBCXX 的解决方法。

```bash
## Ubuntu
cd /usr/lib/x86_64-linux-gnu/
## CentOS
cd /usr/lib64

ll |grep libstd
strings libstdc&#43;&#43;.so.6 | grep GLIBCXX
## 有可能找不到 GLIBCXX_3.2.26

locate libstdc&#43;&#43;.so.6

strings /usr/local/gcc/lib64/libstdc&#43;&#43;.so.6 | grep GLIBCXX
cp /usr/local/gcc/lib64/libstdc&#43;&#43;.so.6 /usr/lib/x86_64-linux-gnu
strings /usr/lib/x86_64-linux-gnu/libstdc&#43;&#43;.so.6 | grep GLIBCXX
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-05-26-glibcxx--not-found/  

