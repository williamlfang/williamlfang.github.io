# 搭建阿里云Git服务器


![Git:版本控制系统](/images/git.jpeg)

# 搭建 Git 服务器

第一步，安装git：

```bash
$ sudo apt-get install git
```

第二步，创建一个git用户，用来运行git服务：

```bash
$ sudo adduser git
```

第三步，创建证书登录：

收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。

```bash
cat ~/.ssh/id_rsa.pub

## 复制公钥到 /home/git/.ssh/authorized_keys
```

第四步，初始化Git仓库：

先选定一个目录作为Git仓库，假定是/srv/test.git，在/srv目录下输入命令：

```bash
sudo git init --bare test.git
```

Git就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的Git仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的Git仓库通常都以.git结尾。然后，把owner改为git：

```
sudo chown -R git:git test.git
```

第五步，禁用shell登录：

出于安全考虑，第二步创建的git用户不允许登录shell，这可以通过编辑/etc/passwd文件完成。找到类似下面的一行：

```bash
git:x:1001:1001:,,,:/home/git:/bin/bash
```

改为：
```bash
git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell
```

这样，git用户可以正常通过ssh使用git，但无法登录shell，因为我们为git用户指定的git-shell每次一登录就自动退出。

第六步，克隆远程仓库：

现在，可以通过git clone命令克隆远程仓库了，在各自的电脑上运行：

```bash
$ git clone git@server:/srv/sample.git
Cloning into &#39;sample&#39;...
warning: You appear to have cloned an empty repository.
```

剩下的推送就简单了。


# 版本控制

```bash
## 如果没有使用 gitosis
## git clone git@47.98.117.71:/home/git/codebase/test.git

## 如果使用 gitosis, 默认存放在 /home/git/repositories
git clone git@47.98.117.71:test.git

git checkout master
git pull

git branch dev
git checkout dev
git add ./*
git commit -m &#34;modify dev&#34;
git push origin dev

git checkout master
git merge dev
git add ./*
git commit -m &#34;modify master&#34;
git push origin master

## 本地获取其他分支
## 将远程git仓库里的指定分支拉取到本地（本地不存在的分支）
git checkout -b 本地分支名 origin/远程分支名

## 如果出现提示：
## fatal: Cannot update paths and switch to branch &#39;dev2&#39; at the same time.
## Did you intend to checkout &#39;origin/dev2&#39; which can not be resolved as commit?
## 表示拉取不成功。需要先执行
git fetch
## 然后再执行
git checkout -b 本地分支名 origin/远程分支名
```

# 团队管理

## ~~使用 gitosis 管理权限~~

&gt; gitosis 现已经被改写升级成 gitolite, 更好得支持在 branch 级别的权限控制

把团队成员的公钥保存到 `/home/git/.ssh/authorized_keys` 文件的做法，对于小规模的队伍是可行的。但是，这样的弊端也是十分明显：

1. 随着团队规模的扩大、成员的离开，需要重复的增加/删除成员的公钥，这样比较繁琐，而且存在安全隐患
2. `git`默认的权限是对于所有成员开放的，即所有成员都拥有对项目的读写权限，如果是非管理员用户，不小心在分支修改了代码，但是提交到了`master`上面，有可能导致整个项目崩盘
3. 此外，我们还希望给部分成员拥有管理权限，部分成员拥有可读可写权限，而剩下的[实习]成员则只有可读权限，这个需要通过项目的权限管理机制实现。

### 安装 gitosis

`gitosis` 是 `python` 项目，需要安装 `python-setuptools` 模块

```bash
apt-get install python-setuptools
```

然后安装 `gitosis`
```bash
cd ~
git clone https://github.com/tv42/gitosis.git
cd gitosis
sudo python setup.py install
```

默认情况下，`gitosis` 会把项目放在 `/home/git/repositories`

```bash
total 16
drwxr-x--- 8 git git 4096 Nov 30 13:22 gitosis-admin.git
drwxr-x--- 7 git git 4096 Nov 30 13:05 solarflare.git
drwxr-x--- 7 git git 4096 Nov 30 13:22 test2.git
drwxr-x--- 7 git git 4096 Nov 30 13:06 test.git
```

如果原来代码已经放在别的文件夹，可以使用 `ln`

```bash
ln -s /opt/git /home/git/repositories
```

Gitosis 将会帮我们管理用户公钥，所以先把当前控制文件改名备份，以便稍后重新添加，准备好让 Gitosis 自动管理 `authorized_keys` 文件：

```bash
mv /home/git/.ssh/authorized_keys /home/git/.ssh/authorized_keys_bk
```

接下来，修改 `git` 通过 `shell` 登录
```bash
vim /etc/passwd

## 修改成如下
git:x:1000:1000::/home/git:/bin/sh
```

### 增加管理员
`gitosis` 默认会搭建一个 `gitosis-admin.git` 的仓库用来管理所有的用户权限。因此，我们需要增加一个**代码管理员**来管理这个`repo`，即只有这个用户才有权限修改项目的权限归属。
比如，我(`william`)的本地机器作为 `gitosis-admin.git` 的所有者，需要把本地的 `id_rsa.pub` 加入到 `gitosis-admin.git`，然后开始初始化仓库

```bash
scp ~/.ssh/id_rsa.pub root@47.98.117.71:/tmp

sudo -H -u git gitosis-init &lt; /tmp/id_rsa.pub
```
这样，我(`william`)的本地机器变成了 `gitosis-admin.git` 的所有者，管理所有仓库的权限。

接下来，需要手工对该仓库中的 post-update 脚本加上可执行权限：

```bash
sudo chmod 755 /home/git/gitosis-admin.git/hooks/post-update
```

试着登录服务器的`git`

```bash
ssh git@47.98.117.71

PTY allocation request failed on channel 0
ERROR:gitosis.serve.main:Need SSH_ORIGINAL_COMMAND in environment.
Connection to 47.98.117.71 closed.
```

说明 Gitosis 认出了该用户的身份，但由于没有运行任何 Git 命令，所以它切断了连接。那么，现在运行一个实际的 Git 命令 — 克隆 Gitosis 的控制仓库
```bash
cd ~/Documents
git clone git@47.98.117.71:gitosis-admin.git
cd gitosis-admin

gitosis.conf  keydir

On branch master
Your branch is up to date with &#39;origin/master&#39;.

nothing to commit, working tree clean

total 20K
drwxrwxr-x  4 william william 4.0K Nov 30 13:22 ./
drwxr-xr-x 50 william william 4.0K Nov 30 12:57 ../
drwxrwxr-x  8 william william 4.0K Nov 30 15:29 .git/
-rw-rw-r--  1 william william  399 Nov 30 13:22 gitosis.conf
drwxrwxr-x  2 william william 4.0K Nov 30 13:10 keydir/
```
其中
1. `gitosis.conf`是配置文件
2. `keydir`存放公钥`.pub`

```bash
cat gitosis.conf

[gitosis]

[group gitosis-admin]
members = william.lian.fang@gmail.com
writable = gitosis-admin

[group hicloud-hft]
members = william.lian.fang@gmail.com
writable = solarflare

[group hicloud-hft]
members = william.lian.fang@gmail.com fl166
writable = test

[group hicloud-test]
members = william.lian.fang@gmail.com
writable = test2

[group hicloud-test-readonly]
members = fl166
readonly = test2
```

```bash
cd keydir
ll

total 16K
drwxrwxr-x 2 william william 4.0K Nov 30 13:10  ./
drwxrwxr-x 4 william william 4.0K Nov 30 13:22  ../
-rw-rw-r-- 1 william william 1.2K Nov 30 13:10  fl166.pub
-rw-rw-r-- 1 william william  409 Nov 30 12:42 &#39;william.lian.fang@gmail.com.pub&#39;
```

看到上面的文件，如 `fl166.pub`，存放的便是公钥，这个文件名需要对应以上的 `members` 才能够被识别。

我们可以看出

1. 对于 `test.git`, `william.lian.fang@gmail.com`和`fl166` 拥有 `writable` 的可读可写权限。
2. 而对于 `test2.git`, `william.lian.fang@gmail.com` 拥有 `writable` 的可读可写权限, 而 `fl166` 只有读的权限，即不可参与项目代码修改，如果推送修改会报错
    ```bash
    ERROR:gitosis.serve.main:Repository write access denied
    fatal: Could not read from remote repository.

    Please make sure you have the correct access rights
    and the repository exists.
    ```

## 使用 gitolite 管理权限

### 安装 gitolite

由于 `gitolite` 使用 `Perl` 编写，因此我们需要先安装

```bash
sudo yum install perl
```

同样，我们需要修改

```bash
vim /etc/passwd

## 修改成如下
git:x :1000:1000::/home/git:/bin/sh
```

然后切换到用户 `git` 安装

```bash
su git
cd /home/git
git clone git://github.com/sitaramc/gitolite

## 安装到 /home/git/bin 目录下
mkdir -p /home/git/bin
./gitolite/install -to /home/git/bin/
```

### 添加管理员

可以有两种方式添加管理员

1. 服务器作为管理员
2. 第三方用户作为管理员

我更倾向第二种方法，因为这样可以避免频繁的登录服务器操作。

```bash
## !!! 在本地机器操作
scp ~/.ssh/id_rsa.pub root@47.98.117.71:/home/git/.ssh/william.pub
```

Gitolite 将会帮我们管理用户公钥，所以先把当前控制文件改名备份，以便稍后重新添加，准备好让 Gitosis 自动管理 `authorized_keys` 文件：

```bash
cd ~/
chmod 700 -R .ssh
chmod 600 authorized_keys
mv /home/git/.ssh/authorized_keys /home/git/.ssh/authorized_keys_bk
```


然后在服务器终端操作

```bash
/home/git/bin/gitolite setup -pk /home/git/.ssh/william.pub

Initialized empty Git repository in /home/git/repositories/gitolite-admin.git/
Initialized empty Git repository in /home/git/repositories/testing.git/
```

出现以上消息说明操作成功，我们可以看到在 `/home/git/repositories` 初始化了两个repo

```bash
ll
total 8
drwx------ 8 git git 4096 Dec  1 15:15 gitolite-admin.git
drwx------ 7 git git 4096 Dec  1 15:15 testing.git
```

如此一来，我们便可以在 `william` 的这台电脑上设置用户权限了。

### 设置用户权限

我们在本地机器（`william`）终端操作

```bash
## 本地机器 william

cd ~/Documents
git clone git@47.98.117.71:gitolite-admin.git

cd gitolite-admin
ll
total 20K
drwxrwxr-x  5 william william 4.0K Dec  1 14:24 ./
drwxr-xr-x 52 william william 4.0K Dec  1 14:34 ../
drwxrwxr-x  2 william william 4.0K Dec  1 15:07 conf/
drwxrwxr-x  8 william william 4.0K Dec  1 15:43 .git/
drwxrwxr-x  2 william william 4.0K Dec  1 15:15 keydir/
```

其中：

1. `keydir` 用来存放用户的 `id_rsa.pub` 公钥，文件名字对应用户名称，如 `fl166.pub` 则对应 `fl166` 这个用户，需要在 `gitolite.conf` 配置文件使用到。

    ```bash
    cd keydir
    ll
    total 16K
    drwxrwxr-x 2 william william 4.0K Dec  1 15:15 ./
    drwxrwxr-x 5 william william 4.0K Dec  1 14:24 ../
    -rw-rw-r-- 1 william william  409 Dec  1 14:28 fl166.pub
    -rw-rw-r-- 1 william william  409 Dec  1 14:24 git_admin_william.pub
    ```

2. `conf` 是配置文件，修改用户所属项目的读写权限

    ```bash
    cd conf
    ll

    total 12K
    drwxrwxr-x 2 william william 4.0K Dec  1 15:07 ./
    drwxrwxr-x 5 william william 4.0K Dec  1 14:24 ../
    -rw-rw-r-- 1 william william  210 Dec  1 15:15 gitolite.conf

    cat gitolite.conf

    repo gitolite-admin
    	RW&#43;     =       git_admin_william

    repo testing
    	RW&#43;		=		@all

    repo test1
    	RW&#43;		=		@all

    repo test2
    	RW&#43; 	     =	    git_admin_william
    	R   master   = 	    fl166
    	RW&#43; from166  =      fl166
    ```

   这里，以 `test2` 为例，说明各个用户的权限

   - `git_admin_william` 拥有顶级的可读（`R`）、可写（`W`）、以及强制更新（`&#43;`）权限
   - `fl166` 只拥有对 `master` 分支的读取权限，没有其他（写）权限
   - `fl166` 还拥有对的分支 `from166` 的可读（`R`）、可写（`W`）、以及强制更新（`&#43;`）权限

## 开发项目结构

# 参考链接

1. [gitosis 安装使用及错误整理](https://blog.csdn.net/Suo_ivy/article/details/79941323)：步骤讲解比较详细
3. [git 团队协作](https://www.liaoxuefeng.com/wiki/896043488029600/900375748016320)：快速入门必备


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-11-29-%E6%90%AD%E5%BB%BA%E9%98%BF%E9%87%8C%E4%BA%91git%E6%9C%8D%E5%8A%A1%E5%99%A8/  

