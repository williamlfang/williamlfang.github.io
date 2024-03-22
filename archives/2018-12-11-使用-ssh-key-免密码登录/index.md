# 使用 ssh key 免密码登录


# 终结痛苦

通常，我们登录远程服务器使用的是 `ssh` 安全通道，通过终端交互的形式与服务器进行对话。但是，使用该命令要求每次都输入账号和密码。这对于一个理想主义者来说，实在是不能忍受的痛苦，而且还存在密码被暴露的风险。我更希望是，通过一定的配置，远程服务器能够「认识」我，并且十分友好的让我进入操作界面。

这个问题从另一方面来看，实际上是实现了远程登录的「静音模式」，尤其是对于日常运行的脚本，可以实现自动运行，不需要我们每次都有交互输入，比如在本地和远程服务器之间传输数据与文件的命令，`rsync`，就可以做到无人值守了。

# `ssh-key`生成多个公钥、私钥

使用 `ssh-key` 生成密匙，「通知」远程服务器「我们是自己人」。需要注意的是，如果不想要输入密码，旧直接敲击两次回车键即可。

```bash
ssh-keygen -t rsa -C &#34;fl@192.168.1.166&#34; -f ~/.ssh/id_rsa_fl166
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/william/.ssh/id_rsa_fl166.
Your public key has been saved in /home/william/.ssh/id_rsa_fl166.pub.
The key fingerprint is:
SHA256:Dto6JWe5yQbE&#43;GxPG2JFiuKz5fXaNliKhi/iRxTYIwM fl@192.168.1.166
The key&#39;s randomart image is:
&#43;---[RSA 2048]----&#43;
|E o              |
| &#43; &#43;  .          |
|  o&#43;oo           |
|. o.&#43; .          |
|...&#43; ...S        |
| o oO&#43;B&#43;         |
|  Bo&#43;@*=.        |
|.&#43; =.&#43;O&#43;         |
|o.=..&#43;o..        |
&#43;----[SHA256]-----&#43;
```

默认存放在 `~/.ssh/id_rsa_fl166.pub`。这相当于设置了公共访问权限，允许外部访问者可以访问本机。同时，如果把这个权限放在

# 配置`config`文件

`~/.ssh/config`文件相当于一个`钥匙柜子`，里面存放了本地系统运行外部访问的公钥，可以十分方便的用来管理多个账户的公钥。我们可以配置该文件如下：

```bash
subl ~/.ssh/config
## ==========================================
## williamlfang: github 配置
## 这个是在默认的 id_rsa 不用动
Host github
    HostName github.com
    User git
    ## IdentityFile ~/.ssh/id_rsa_github
    IdentityFile ~/.ssh/id_rsa

## ==========================================
## fl@192.168.1.166 配置
Host fl166
    HostName 192.168.1.166
    User fl
    IdentityFile ~/.ssh/id_rsa_fl166
```



# 将公匙拷贝至远程主机

把本地的公钥拷贝到远程服务器。不过，由于我前期已经在服务器有 `~/.ssh/authorized_keys` 的文件夹，这时候直接拷贝会报错：sh: .ssh/authorized_keys: Is a directory。参考了[SO](https://askubuntu.com/questions/844156/sh-ssh-authorized-keys-is-a-directory)上面的回答，发现原来这个是一个文件夹，无法进行直接拷贝。需要先把原来的文件夹删除掉，然后再进行复制。

```bash
## 如果有报错，
## 需要把远程服务器上面的　~/.ssh/authorized_keys 删掉
## rm -rf ~/.ssh/authorized_keys

ssh-copy-id fl@192.168.1.166
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
fl@192.168.1.166&#39;s password:
sh: .ssh/authorized_keys: Is a directory

ssh-copy-id -i ~/.ssh/id_rsa_fl166.pub fl@192.168.1.166
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: &#34;/home/william/.ssh/id_rsa_fl166.pub&#34;
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys

Number of key(s) added: 1

Now try logging into the machine, with:   &#34;ssh &#39;fl@192.168.1.166&#39;&#34;
and check to make sure that only the key(s) you wanted were added.
```

# 免密码登录 ssh

现在，远程服务器已经有本地的公钥，也就是可以「认识」本地机器，这意味着可以直接进行 `ssh` 免密码登录服务器。

```bash
ssh fl@192.168.1.166
Last login: Thu Jan 10 14:38:55 2019 from 192.168.1.115
[fl@localhost-166 ~]$

## 没有输入密码即可登录
```

# 使用 `rsync` 传输文件

现在，我们便可以使用 `rsync` 在不需要输入密码的情况下，进行本地机器与远程服务器之间同步文件了。

```bash
rsync --progress -avz -e ssh /home/william/Documents/QUANTAXIS/myTask/data/daily/* fl@192.168.1.166:/home/fl/myData/data/ChinaStocks/Bar/FromTDX
sending incremental file list
sh600138.csv
        298,115 100%    5.06MB/s    0:00:00 (xfr#1, to-chk=2843/2844)
sh600139.csv
        266,422 100%    2.57MB/s    0:00:00 (xfr#2, to-chk=2842/2844)
sh600141.csv
        271,233 100%    1.70MB/s    0:00:00 (xfr#3, to-chk=2841/2844)
sh600143.csv
        199,249 100%    1.12MB/s    0:00:00 (xfr#4, to-chk=2840/2844)

```

这里，`rsync`主要参数有：

- `--progress` 显示进度条
- `-a` 以文件形式传送
- `-v` 显示结果
- `-z` 压缩数据
- `-e` 执行命令，也就是后面的 `ssh`

# 自动配置脚本

编写一个简单的部署脚本:

```sh
#!/usr/bin/bash

## -----------------
HOST=192.168.1.135
USER=trader
## -----------------

## -----------------------------------------------------------------------------
ssh-keygen -t rsa -N &#39;&#39; -C &#34;${USER}@${HOST}&#34; -f ~/.ssh/id_rsa_${USER}${HOST}

echo &#34;\n## ==========================================&#34;  &gt;&gt; ~/.ssh/config
echo &#34;## ${USER}${HOST}&#34;                                &gt;&gt; ~/.ssh/config
echo &#34;Host ${USER}${HOST}&#34;                              &gt;&gt; ~/.ssh/config
echo &#34;    HostName ${HOST}&#34;                             &gt;&gt; ~/.ssh/config
echo &#34;    User ${USER}&#34;                                 &gt;&gt; ~/.ssh/config
echo &#34;    IdentityFile ~/.ssh/id_rsa_${USER}${HOST}&#34;    &gt;&gt; ~/.ssh/config

ssh-copy-id ${USER}@${HOST}
## -----------------------------------------------------------------------------
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-12-11-%E4%BD%BF%E7%94%A8-ssh-key-%E5%85%8D%E5%AF%86%E7%A0%81%E7%99%BB%E5%BD%95/  

