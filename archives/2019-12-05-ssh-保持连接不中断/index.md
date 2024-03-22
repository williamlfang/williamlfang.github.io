# ssh 保持连接不中断


为了在使用 `ssh` 登录服务器保持通信连接的持续，我们可以修改服务器端或者客户端。

# 修改服务器端

如果想要对所有的用户都允许保持连接，可以考虑把服务器端的配置作修改，路径是 `/etc/ssh/sshd_config`

```bash
vim /etc/ssh/sshd_config

## 增加以下设置

## 意思是向客户端每60秒发一次保持连接的信号
ClientAliveInterval  60

## 如果仍要设置断开时间,还有一个参数可以添加
## 意思是如果客户端60次未响应就断开连接,依据你期望的时间来设定
# ClientAliveCountMax  60
```

## 修改客户端

如果在服务器端没有权限，我们也可以只修改本地机器的设置，路径是 `/etc/ssh/ssh_config`

```bash
vim /etc/ssh/ssh_config

## 连续发送信号
ServerAliveInterval  60

## 也可以设置最大保持连接次数
# ServerAliveCountMax  60
```

# 参考链接

1. [Linux系统下的SSH 使用总结](https://www.cnblogs.com/kevingrace/p/6110842.html)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-05-ssh-%E4%BF%9D%E6%8C%81%E8%BF%9E%E6%8E%A5%E4%B8%8D%E4%B8%AD%E6%96%AD/  

