# Ubuntu 源代码安装 wireshark



`wireshark` 与 `tcpdump` 是网络抓包的两大神器。其中，前者提供了更加便捷的界面操作，后者则比较适合在命令行进行操作。
&lt;!--more--&gt;

# 安装

`Ubuntu` 可以直接从默认仓库安装，但是提供的是稳(too)定(old)的版本。为了使用新功能，我决定从源代码安装 `wireshark`。

## 下载代码

我们可以直接从官网下载[最新版本的源代码](https://www.wireshark.org/#download)，或者找到[历史版本](https://www.wireshark.org/download/src/)。最好开启 Chrome 的翻墙功能，下载速度会快一些。

```bash
wget https://1.as.dl.wireshark.org/src/wireshark-3.0.7.tar.xz
```

## 安装依赖

有可能提示找不到 `libgcrypt`

```bash
apt install qttools5-dev qttools5-dev-tools libqt5svg5-dev qtmultimedia5-dev build-essential automake autoconf libgtk2.0-dev libglib2.0-dev flex bison libpcap-dev libgcrypt20-dev cmake -y
sudo apt-get install libgcrypt20-dev
sudo apt-get install keepassx
sudo apt-get install build-essential libgl1-mesa-dev
```



## 安装 wireshark

```bash
tar -xf wireshark-3.0.7.tar.xz
cd wireshark-3.0.7
mkdir build
cd build

cmake ..
make  -j
make install
```

然后查看版本信息

```bash
wireshark -v

Wireshark 3.0.7 (Git commit 9435717b91f5)

Copyright 1998-2019 Gerald Combs &lt;gerald@wireshark.org&gt; and contributors.
License GPLv2&#43;: GNU GPL version 2 or later &lt;http://www.gnu.org/licenses/old-licenses/gpl-2.0.html&gt;
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Compiled (64-bit) with Qt 5.9.7, with libpcap, without POSIX capabilities,
without libnl, with GLib 2.56.4, with zlib 1.2.11, without SMI, without c-ares,
without Lua, without GnuTLS, with Gcrypt 1.8.1, without Kerberos, without
MaxMind DB resolver, without nghttp2, without LZ4, without Snappy, with libxml2
2.9.4, with QtMultimedia, without SBC, without SpanDSP, without bcg729.

Running on Linux 4.15.0-20-generic, with Intel(R) Core(TM) i5-6500 CPU @ 3.20GHz
(with SSE4.2), with 40091 MB of physical memory, with locale en_US.UTF-8, with
libpcap version 1.8.1, with Gcrypt 1.8.1, with zlib 1.2.11, binary plugins
supported (0 loaded).

Built using gcc 7.4.0.
```

![成功启动](./wireshark.png &#34;成功启动&#34;)

## 问题解决

1. 出现错误：file not recognized: File truncated

    ```bash
    ui/qt/CMakeFiles/qtui.dir/widgets/clickable_label.cpp.o: file not recognized: File truncated
    collect2: error: ld returned 1 exit status
    CMakeFiles/wireshark.dir/build.make:557: recipe for target &#39;run/wireshark&#39; failed
    make[2]: *** [run/wireshark] Error 1
    CMakeFiles/Makefile2:661: recipe for target &#39;CMakeFiles/wireshark.dir/all&#39; failed
    make[1]: *** [CMakeFiles/wireshark.dir/all] Error 2
    Makefile:140: recipe for target &#39;all&#39; failed
    make: *** [all] Error 2
    ```

    没有明白具体的错误原因，不过在 SO上面找到了这个提示：[File not recognized: File truncated GCC error](https://stackoverflow.com/questions/5713894/file-not-recognized-file-truncated-gcc-error)。提供的思路是原来编译的目标文件有问题，直接删掉就好了

    &gt; Just remove the object file.
    &gt;
    &gt; This error most likely appeared after the previous build was interrupted and object file was not generated completely.



    ```bash
    rm ui/qt/CMakeFiles/qtui.dir/widgets/clickable_label.cpp.o
    ```

# 抓包

![抓包现场发来图片](./capture.png &#34;抓包现场发来图片&#34;)


# 参考链接
1. [Install Latest Wireshark on Ubuntu 18.04](https://kifarunix.com/install-latest-wireshark-on-ubuntu-18-04/)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-10-ubuntu-%E6%BA%90%E4%BB%A3%E7%A0%81%E5%AE%89%E8%A3%85-wireshark/  

