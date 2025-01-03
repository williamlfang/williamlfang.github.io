# crti.so 找不到的解决方法


在编译一个代码模块的是否，`gcc` 报错

```bash
/usr/bin/ld: cannot find crt1.o: No such file or directory
```

我们需要让 `gcc` 识别到 `crt` 的路径

```bash
find /usr -name crti*

/usr/lib32/crti.o
/usr/lib/i386-linux-gnu/crti.o
/usr/lib/x86_64-linux-gnu/crti.o
/usr/libx32/crti.o
```

可以看到，在默认的路径找到了 `/usr/lib32/crt1.o`，但是由于这个指向的是 32 位操作系统的动态库（可能是当前系统安装了多个编译环境），导致 `gcc` 编译文件无法使用 64 位的动态库。同时，我们还发现 `/usr/lib/x86_64-linux-gnu/crti.o` 这个版本是 64 位动态库，因此需要让 `gcc` 使用该版本

```bash
sudo apt-get install libc6-dev

export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}
export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:${LIBRARY_PATH}

sudo ln -s /usr/lib/x86_64-linux-gnu /usr/lib64
```


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-03-crti.so-%E6%89%BE%E4%B8%8D%E5%88%B0%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/  

