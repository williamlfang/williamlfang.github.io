# gcc 找不到 libgomp.spec: No such file or directory


[error: can&#39;t find libgomp.spec](http://forum.openmp.org/forum/viewtopic.php?f=3&amp;t=183)

在网上找了好久的解决方法，其实是因为最近安装了新版本的 `gcc`，无法与旧版本的动态库链接。这里需要拷贝一份到 `LD_LIBRARY_PATH` 所在的路径

```bash
sudo cp /home/william/Documents/Linux-Tools/gcc/gcc9/gcc-9.2.0/x86_64-pc-linux-gnu/libgomp/libgomp.spec /usr/lib
sudo cp /home/william/Documents/Linux-Tools/gcc/gcc9/gcc-9.2.0/x86_64-pc-linux-gnu/libgomp/libgomp.spec /usr/local/lib
```

顺便说一下另外一个问题:[解决类似 /usr/lib64/libstdc&#43;&#43;.so.6: version `GLIBCXX_3.4.21&#39; not found 的问题`](https://itbilu.com/linux/management/NymXRUieg.html)

```bash
cd /usr/lib/x86_64-linux-gnu/
ll |grep libstd
strings libstdc&#43;&#43;.so.6 | grep GLIBCXX

## 有可能找不到 GLIBCXX_3.2.26

locate libstdc&#43;&#43;.so.6
strings /usr/local/gcc/lib64/libstdc&#43;&#43;.so.6 | grep GLIBCXX

cp /usr/local/gcc/lib64/libstdc&#43;&#43;.so.6 /usr/lib/x86_64-linux-gnu
strings /usr/lib/x86_64-linux-gnu/libstdc&#43;&#43;.so.6 | grep GLIBCXX
```



---

> 作者:   
> URL: https://williamlfang.github.io/archives/spec--no-such-file-or-directory/  

