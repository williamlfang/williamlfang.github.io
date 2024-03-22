# Gitlab 安装全过程


记录在公司内部安装 Gitlab 全过程。
&lt;!--more--&gt;

# 安装 Gitlab

```bash
## 安装必需的依赖项
sudo yum install curl policycoreutils-python openssh-server

## 将 SSH 服务设置成开机自启动
systemctl enable sshd
## 启动 SSH 服务
systemctl start sshd

## 邮件通知
sudo yum install postfix
sudo systemctl start postfix
sudo systemctl enable postfix

## 安装 Gitlab
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce

Thank you for installing GitLab!
...
Complete!

## 调整防火墙
## 要访问GitLab界面，您需要打开端口80和443
sudo systemctl restart firewalld.service
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

## 配置 Gitlab
## 默认是 8080 端口，如果 8080 已被占用，需更改为其它端口，并在防火墙开放对应端口
vim  /etc/gitlab/gitlab.rb

## 修改配置文件中的 external_url &#39;http://192.168.1.135:58080&#39;
## 改完之后执行重置
sudo gitlab-ctl reconfigure
## 重启
sudo gitlab-ctl restart
## 测试
curl 192.168.1.135:58080/gitlab

## 看到以下内容说明安装正确了
&lt;html&gt;&lt;body&gt;You are being &lt;a href=&#34;http://192.168.1.135:58080/users/sign_in&#34;&gt;redirected&lt;/a&gt;.&lt;/body&gt;&lt;/html&gt;%
```

# 管理用户

```bash
## 获取/修改超级管理员root的密码
## 切换目录
cd /opt/gitlab/bin

sudo gitlab-rails console production

## 进入 gitlab 终端操作
## 在irb(main):001:0&gt; 后面运行
## 查看当前用户
User.all
=&gt; #&lt;ActiveRecord::Relation [#&lt;User id:4 @pc&gt;, #&lt;User id:1 @root&gt;, #&lt;User id:2 @fl&gt;, #&lt;User id:3 @lhg&gt;]&gt;
##　切换用户，使用　id:n 来指定
u=User.where(id:1).first
## 输入密码，第一次只有 root, 后面可以通过　Gitlab 网页进行添加
u.password=&#39;******&#39;
u.password_confirmation=&#39;******&#39;
## 保存，注意后面一定要添加符号　&#34;!&#34;
u.save!
```



# 端口转发

在 `frps.ini`

```bash
[common]
bind_port = 7000
vhost_http_port = 58080
```

在 `frpc.ini`

```bash
[common]
server_addr = *.*.*.*
server_port = 7000

[ssh135_gitlab]
type = http
local_ip = 192.168.1.135
local_port = 58080
custom_domains = *.*.*.*  ## 可以通过域名解析到自己的网址，现在先使用 server_addr
```

这样，可以通过打开网页：&lt;http://*.*.*.*:58080/&gt; 访问我们的 `Gitlab` 了。

# 域名解析

可以在 `godday` 上面使用 `gitlab.wi********fang.com` 进行解析 http://*.*.*.*:58080/。则每次只需要访问 `&lt;http://gitlab.wi********fang.com:58080/&gt;`

# 远程访问

## 使用 http

```bash
git clone http://gitlab.wi********fang.com:58080/fl/myctp.git
```

不过这样需要输入密码，可以参考:

修改 `.git/config`

```bash
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote &#34;origin&#34;]
	url = http://你的用户:你的密码@gitlab.wi********fang.com:58080/fl/myctp.git
	fetch = &#43;refs/heads/*:refs/remotes/origin/*
[branch &#34;master&#34;]
	remote = origin
	merge = refs/heads/master
```



&gt; 问题: gitlab使用http方式提交代码不输入密码 ?
&gt;
&gt; 背景: 假如你创建项目地址为 http://git.ops.test.com.cn/root/puppet.git 。
&gt;
&gt; 解决: 如果你已经执行过 `git clone http://git.ops.test.com.cn/root/puppet.git` ,则可以进入puppet目录，修改 `.git/config中url = http://账号:密码@git.ops.test.com.cn/root/puppet.git` ,再提交就发现不要输入密码了；或者直接在克隆仓库的时候直接 `git clone http://账号:密码@git.ops.test.com.cn/root/puppet.git` ，这样下次提交时也不需要输入密码。

## 使用 ssh

上面虽然可以使用 `gitlab`，但是无法直接在**外网**使用项目地址进行clone。比如

```bash
git clone git@192.168.1.135:fl/myctp.git
Cloning into &#39;myctp&#39;...
ssh: connect to host 192.168.1.135 port 22: No route to host
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

这是因为 `192.168.1.135` 是内网，无法被外网解析。这时，我们需要使用 `ssh` 的方式进行操作。

比如，我们已经把 `192.168.1.135` 的 **22** 端口通过 tcp 的方式，映射给了 `*.*.*.*` 的端口号 `6135`， 则可以使用

```bash
git clone ssh://git@*.*.*.*:6135/fl/myctp.git
Cloning into &#39;myctp&#39;...
remote: Counting objects: 3, done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (3/3), done.
```

# 参考链接

1.[如何在CentOS 7上安装和配置GitLab](&lt;https://www.myfreax.com/how-to-install-and-configure-gitlab-on-centos-7/&gt;)

2.[GitLab 部署及管理员账号初始化](&lt;https://blog.csdn.net/hnmpf/article/details/80518460&gt;)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-09-05-gitlab-%E5%AE%89%E8%A3%85%E5%85%A8%E8%BF%87%E7%A8%8B/  

