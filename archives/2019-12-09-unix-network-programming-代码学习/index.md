# Unix Network Programming 代码学习


![网络编程的圣经](/images/2019-12-09-Unix-Network-Programming-代码学习/unp-book1.jpg)

# Chap.0 安装源代码

## 安装步骤

```
## git clone git@github.com:williamlfang/unix-network-programming-v3.git
cd unix-network-programming-v3-master
./configure

cd lib         # build the basic library that all programs need
make           # use &#34;gmake&#34; everywhere on BSD/OS systems

cd ../libfree  # continue building the basic library
make
```
&lt;!--more--&gt;

## 测试

```bash
## 编译
cd intro
make

## 启动服务器
sudo ./daytimetcpsrv

## 运行客户端
./daytimetcpcli
Mon Dec  9 11:45:25 2019
```

# Chap.1 Intro


# 参考链接

1. [A Simple Introduction To Computer Networking](https://betterexplained.com/articles/a-simple-introduction-to-computer-networking/)
2. [理解 TCP/IP 网络栈](https://cizixs.com/2017/07/27/understand-tcp-ip-network-stack/)
3. [Linux socket 编程](https://www.ibm.com/developerworks/cn/education/linux/l-sock/l-sock.html)
4. [Welcome to The TCP/IP Guide!](https://www.tcpipguide.com/)
5. [Computer Science 60: lab assignments -  network programming](https://www.cs.dartmouth.edu/~campbell/cs60/assignments.html)：使用 wireshark 进行网络编程与抓包分析。
6. [计算机网络协议学习总结](https://qhh.me/2019/05/01/计算机网络协议学习总结/)
7. [计算机网络：实现一个可靠的运输协议](https://sine-x.com/kurose-ross-a-reliable-transport-protocol/)
8. [理解 Linux 网络栈（1）：Linux 网络协议栈简单总结](https://www.cnblogs.com/sammyliu/p/5225623.html)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-09-unix-network-programming-%E4%BB%A3%E7%A0%81%E5%AD%A6%E4%B9%A0/  

