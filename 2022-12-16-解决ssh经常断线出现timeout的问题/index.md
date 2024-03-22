# 解决ssh经常断线，出现timeout的问题


在登录 `ssh` 的时候，经常会遇到 timed out waiting for input: auto-logout，甚至都没有这个提醒，就直接断线的情况。我们需要修改默认超时参数。

&lt;!--more--&gt;

## server端

```bash
# 设置服务器向 SSH 客户端连接会话发送频率和时间.
vi /etc/ssh/sshd_config，添加如下两行
# 启用客户端活动检查，每 60 秒检查一次，3 次不活动断开连接
ClientAliveInterval 60
ClientAliveCountMax 3
# ClientAliveInterval 指定了服务器端向客户端请求消息的时间间隔, 默认是 0, 不发送。设置 60 表示每分钟发送一次, 然后客户端响应, 这样就保持长连接了。
# ClientAliveCountMax 表示服务器发出请求后客户端没有响应的次数达到一定值, 就自动断开。正常情况下, 客户端不会不响应，使用默认值 3 即可。
#重新启动 SSH 服务
service sshd reload
```

## client 端

```bash
# 1、$TMOUT 系统环境变量
# 用以下命令判断是否是否设置了该参数

echo $TMOUT
# 如果输出空或 0 表示不超时，大于 0 的数字 n 表示 n 秒没有收入则超时。此时则是 100 秒。

# 修改方法
# 系统层面：/etc/profile
# 用户层面：~/.bashr
vi /etc/profile
（当然也可以在其它配置文件配置，涉及到环境变量配置文件读取优先级的问题）
# ----------------------------
export TMOUT=600
# ----------------------------
# 将以上 600 修改为 0 就是设置不超时
source /etc/profile
# 让配置立即生效

# 同时可以修改 ~/.ssh/config
Host *
    TCPKeepAlive yes
    ServerAliveInterval 60
    ServerAliveCountMax 30

```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-12-16-%E8%A7%A3%E5%86%B3ssh%E7%BB%8F%E5%B8%B8%E6%96%AD%E7%BA%BF%E5%87%BA%E7%8E%B0timeout%E7%9A%84%E9%97%AE%E9%A2%98/  

