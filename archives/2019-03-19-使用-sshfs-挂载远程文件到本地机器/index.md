# 使用 sshfs 挂载远程文件到本地机器


我们在与远程服务器进行交互的过程中，常用的是通过终端以 `ssh` 的形式连接到服务器，然后再以命令行（`CLI`）进行操作。但是，如果是想把远程服务器的目录文件直接挂载到本地机器上面，然后像浏览和操作本地文件一样方便，其实也是可行的。这就需要使用到今天介绍的 `sshfs`，一款基于 `ssh` 的远程文件挂载工具。

&lt;!--more--&gt;

# 安装

使用命令行安装即可

```bash
sudo apt install sshfs
sudo apt install fuse
```

# 命令

## 挂载

挂载的一般格式为：

```bash
sudo sshfs {{user id}}@{{server hostname}}:{{desiredremote share}} {{desired local mount point}} -o idmap=user -o allow_other -ouid={{local user id}} -o gid={{local group id}}
```

其中：

-   `-o transform_symlinks` 表示转换绝对链接符号为相对链接符号

-   `-o follow_symlinks` 沿用服务器上的链接符号

-   `-C` 压缩，或者-o compression=yes

-   `-o reconnect` 自动重连：避免掉线

-   `-o cache=yes`
-   `-o allow_other`

一般常用的命令是

```bash
cd
mkdir trader188
sshfs trader@192.168.1.188:/home/trader ~/trader188 -o port=22,compression=yes,reconnect,idmap=user

cd trader188 &amp;&amp; ll
total 972K
drwx------  1 william william 4.0K Mar 10 19:20 ./
drwxr-xr-x 80 william william 4.0K Mar 19 09:26 ../
drwxrwxr-x  1 william william 4.0K Feb 13 16:28 anaconda2/
drwxrwxrwx  1 william william   97 Jan 25 13:54 .anydesk/
drwx------  1 william william    6 Jan 25 13:54 AnyDesk/
-rw-------  1 william william  21K Mar 19 00:44 .bash_history
-rw-r--r--  1 william william   18 Apr 11  2018 .bash_logout
-rw-r--r--  1 william william  193 Apr 11  2018 .bash_profile
-rw-r--r--  1 william william 1.4K Feb 21 15:31 .bashrc
-rw-r--r--  1 william william  231 Jul 17  2018 .bashrc-anaconda2.bak
drwx------  1 william william 4.0K Jan 29 09:13 .cache/
-rwxrwxr-x  1 william william 1.5K Feb 25 17:13 centos_info.sh*
-rw-r--r--  1 william william  84K Feb 25 17:07 centos.txt
drwxrwxr-x  1 william william   70 Jul 18  2018 .codeintel/
drwxrwxr-x  1 william william   18 Jul 17  2018 .conda/
-rw-rw-r--  1 william william  108 Nov 29 17:01 .condarc
drwxr-xr-x  1 william william 4.0K Sep 27 16:59 .config/
drwx------  1 william william   25 Jul 17  2018 .dbus/
drwxr-xr-x  1 william william   24 Oct 20 14:51 Desktop/
drwxr-xr-x  1 william william  217 Sep 27 16:56 Documents/
drwxr-xr-x  1 william william  173 Jan 25 13:47 Downloads/
drwx------  1 william william   28 Mar 10 19:20 .emacs.d/
-rw-------  1 william william   16 Jul 17  2018 .esd_auth
-rwxrwxr-x  1 william william 390K Mar  4 15:47 hicloud.so*
-rw-------  1 william william 5.5K Feb 25 17:26 .ICEauthority
-rw-------  1 william william   35 Mar 10 19:19 .lesshst
drwx------  1 william william   19 Jul 17  2018 .local/
drwxr-xr-x  1 william william   81 Jul 17  2018 .mozilla/
-rw-rw-r--  1 william william 8.7K Mar  6 11:24 .mycli-history
-rw-rw-r--  1 william william  15K Mar  5 20:39 .mycli.log
-rw-rw-r--  1 william william 4.1K Sep 27 15:37 .myclirc
drwxrwxr-x  1 william william 8.0K Mar 19 08:40 myLog/
drwxrwxr-x  1 william william   35 Dec  3 10:55 myShell/
-rw-------  1 william william 5.8K Jan 29 15:58 .mysql_history
-rw-------  1 william william 245K Jul 18  2018 myTask_20171105-20171111-momentum-trading.pdf
drwxrwxr-x  1 william william  166 Mar  5 15:14 myVnpy/
drwxrwxr-x  1 william william  155 Mar 15 19:54 .navicat64/
drwxrw----  1 william william   19 Jul 18  2018 .pki/
drwxrwxr-x  1      27 sudo       6 Feb 28 15:10 public/
drwxrwxr-x  1 william william   45 Jul 18  2018 R/
drwx------  1 william william   17 Jul 17  2018 .redhat/
drwxr-xr-x  1 william william 4.0K Jul 18  2018 .rstudio/
drwx------  1 william william   48 Feb 26 08:57 .ssh/
drwxr-xr-x  1 william william   65 Jul 18  2018 .subversion/
drwxrwxr-x  1 william william   59 Jan 24 21:31 temp/
-rw-rw-r--  1 william william 4.6K Jan 23 20:33 .tmux.conf
-rw-------  1 william william 4.4K Mar  6 11:34 .viminfo
drwxrwxr-x  1 william william  260 Sep 27 08:31 .vnc/
-rw-------  1 william william  198 Sep 27 08:31 .Xauthority

```

## 卸载

使用命令 `fusermount` 来卸载

```bash
fusermount -u ~/trader188

cd ~/trader188 &amp;&amp; ls
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-03-19-%E4%BD%BF%E7%94%A8-sshfs-%E6%8C%82%E8%BD%BD%E8%BF%9C%E7%A8%8B%E6%96%87%E4%BB%B6%E5%88%B0%E6%9C%AC%E5%9C%B0%E6%9C%BA%E5%99%A8/  

