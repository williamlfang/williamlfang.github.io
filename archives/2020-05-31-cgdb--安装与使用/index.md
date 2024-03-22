# cgdb: 安装与使用


# 安装

## 安装 cgdb

```bash
git clone git@github.com:cgdb/cgdb.git
cd cgdb

./autogen.sh

## 安装依赖包
## CentOS
yum install ncurses-devel
yum install texinfo
## 如果是 CentOS8
yum config-manager --set-enabled PowerTools
yum install help2man
yum install readline-devel
yum install flex

## Ubuntu
sudo apt-get install texinfo
sudo apt-get install flex

./configure --prefix=/usr/local
make -j
sudo make install
```
&lt;!--more--&gt;

## 配置

参考官方说明：[CGDB 中文手册](https://www.bookstack.cn/read/cgdb-manual-in-chinese/4.0.md)。

```bash
vim ~/.cgdb/cgdbrc

## 忽略大小写
set ignorecase
## 高亮调试对应的代码行
set arrowstyle=highlight
## tab = 4
set tabstop==4
## 显示发送的命令
set showtgdbcommands
## 重新加载
set autosourcereload
set wso=vertical
#set eld=shortarrow
set autosourcereload
## 加了一个 F9 的快捷键，用于跳出循环
map &lt;F9&gt; :until&lt;cr&gt;
```

## 中文显示
打印变量时可能出现中文字符乱码，可以根据以下步骤解决这个问题。

```bash
cd /lib/x86_64-linux-gnu
ls -al libncurse*
sudo rm -rf libncurses.so.5
sudo ln -s libncursesw.so.5.9 libncurses.so.5
```

试着打印中文字符变量，这时候就能正确显示了。



# 使用
安装好了以后，输入“cgdb 要调试的程序名”即可以进行调试。

![](/images/2020-05-31-cgdb--安装与使用/Selection_122.png)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-05-31-cgdb--%E5%AE%89%E8%A3%85%E4%B8%8E%E4%BD%BF%E7%94%A8/  

