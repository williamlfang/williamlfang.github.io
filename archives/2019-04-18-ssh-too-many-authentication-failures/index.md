# SSH Too Many Authentication Failures


今天在使用 `ssh` 连接服务器的时候出现一个错误，这里记录一下解决方法：

```bash
ssh-copy-id ${USER}@${HOST}
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 6 key(s) remain to be installed -- if you are prompted now it is to install the new keys
Received disconnect from 192.168.1.199 port 22:2: Too many authentication failures
Disconnected from 192.168.1.199 port 22
```



&lt;!--more--&gt;

# 修改 `/etc/ssh/sshd_config`

```bash
Last login: Thu Apr 18 15:26:32 2019 from 192.168.1.199
[root@localhost ~]# cd /etc/ssh/
[root@localhost ssh]# vim sshd_config
```

把允许试错的限制修改一下

```bash
# MaxAuthTries 6
MaxAuthTries 10
```

然后重启 `ssh`

```bash
systemctl restart sshd.service
```

# 重新连接

```bash
ssh-copy-id ${USER}@${HOST}
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 6 key(s) remain to be installed -- if you are prompted now it is to install the new keys
trader@192.168.1.199&#39;s password:

Number of key(s) added: 6

Now try logging into the machine, with:   &#34;ssh &#39;trader@192.168.1.199&#39;&#34;
and check to make sure that only the key(s) you wanted were added.
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-04-18-ssh-too-many-authentication-failures/  

