# Github使用SSH免密码登录


在使用 `Github` 进行提交修改时，默认是每次都需要输入账户与密码才能完成提交。这对于需要频繁修改的项目而言，无疑存在极大的重复性操作。因此，我想通过使用 `SSH` 免密码的方式，事先设置好相关的配置，一旦需要有新的 `commit` 就可以跳过账户与密码验证的步骤，进而极大简化工作流程。

&lt;!--more--&gt;

以下是基本的操作流程。

# 配置 `ssh-key`

经常使用 `github`,会发现每次在命令行输入账户和密码是一件多么惹人烦的事情.不过现在有一个更好的方法,是使用 `ssh-key` 来配对进行身份的验证.

具体的带入如下

```bash
cd ~
ssh-keygen -t rsa -C &#34;william.lian.fang@gmail.com&#34;

复制 ./ssh/id_rsa.pub 到 github/account/ssh

# 添加全局设置
git config --global user.email “william.lian.fang@gmail.com”
git config --global user.name “williamlfang”

# 进行一次验证操作
ssh -T git@github.com

记得输入 Yes 进行确认即可.
```

# 解决 `git pull/push` 每次都需要输入密码问题

如果我们git clone的下载代码的时候是连接的https://而不是git@git (ssh)的形式，当我们操作git pull/push到远程的时候，总是提示我们输入账号和密码才能操作成功，频繁的输入账号和密码会很麻烦。

解决办法：

git bash进入你的项目目录，输入：

```bash
git config --global credential.helper store
```

然后你会在你本地生成一个文本，上边记录你的账号和密码。当然这些你可以不用关心。

然后你使用上述的命令配置好之后，再操作一次git pull，然后它会提示你输入账号密码，这一次之后就不需要再次输入密码了。

# 解决提交到GitHub首页不显示的问题

有时候会出现通过 `ssh` 提交了 `commit` 但是无法在首页显示出来，这个原因是因为我在不同的电脑分别复制类两个相同的项目，因此系统无法识别是哪个账户提交的修改。这个需要修改本地的邮箱地址即可。可以[参考链接](https://blog.csdn.net/Cloudox_/article/details/50284193)。具体的解决方法如下：

```bash
//如果想对所有的仓库生效，避免在别的仓库继续出现这个情况，则输入：
$ git config --global user.email &#34;william.lian.fang@gmail.com&#34;

// 同样可以查看确认一下：
$ git config --global user.email
```

修改完成后，再次提交 `commit`，就可以在 `github` 首页看到活动变成绿色了。开心。



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-09-05-github%E4%BD%BF%E7%94%A8ssh%E5%85%8D%E5%AF%86%E7%A0%81%E7%99%BB%E5%BD%95/  

