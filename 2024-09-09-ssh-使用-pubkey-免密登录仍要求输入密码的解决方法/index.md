# ssh 使用 pubkey 免密登录仍要求输入密码的解决方法



使用 `sshd` 的免密登录，仍然要求用户输入密码，查看日志发现

```bash
journalctl --unit=sshd

Sep 09 21:39:35 nfqinxiansystem-1 sshd[32051]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=localhost  user=ops
Sep 09 21:39:38 nfqinxiansystem-1 sshd[32051]: Failed password for ops from 127.0.0.1 port 37386 ssh2
Sep 09 21:39:42 nfqinxiansystem-1 sshd[32051]: Accepted password for ops from 127.0.0.1 port 37386 ssh2
Sep 09 21:46:31 nfqinxiansystem-1 sshd[1328]: Connection closed by 127.0.0.1 port 37392 [preauth]
Sep 09 21:47:25 nfqinxiansystem-1 sshd[2084]: Authentication refused: bad ownership or modes for file /home/ops/.ssh/authorized_keys
Sep 09 21:47:26 nfqinxiansystem-1 sshd[2084]: Connection closed by 127.0.0.1 port 37394 [preauth]
Sep 09 21:47:40 nfqinxiansystem-1 sshd[2213]: Authentication refused: bad ownership or modes for file /home/ops/.ssh/authorized_keys
Sep 09 21:47:53 nfqinxiansystem-1 sshd[2213]: Connection closed by 192.168.1.99 port 58096 [preauth]
Sep 09 21:47:54 nfqinxiansystem-1 sshd[2408]: Accepted publickey for ops from 192.168.1.99 port 58098 ssh2: RSA SHA256:z7QGrcrMvuKMqjbq/qKQk6PGcb5PLEiOp81W6kq3Mpc
Sep 09 21:49:42 nfqinxiansystem-1 sshd[1580]: Received signal 15; terminating.
Sep 09 21:49:42 nfqinxiansystem-1 systemd[1]: Stopping OpenSSH server daemon...
Sep 09 21:49:42 nfqinxiansystem-1 systemd[1]: Stopped OpenSSH server daemon.
Sep 09 21:49:42 nfqinxiansystem-1 systemd[1]: Starting OpenSSH server daemon...
Sep 09 21:49:42 nfqinxiansystem-1 sshd[2986]: Server listening on 0.0.0.0 port 22.
Sep 09 21:49:42 nfqinxiansystem-1 sshd[2986]: Server listening on :: port 22.
Sep 09 21:49:42 nfqinxiansystem-1 systemd[1]: Started OpenSSH server daemon.
Sep 09 21:49:48 nfqinxiansystem-1 sshd[2791]: Connection closed by 127.0.0.1 port 37396 [preauth]
Sep 09 21:49:50 nfqinxiansystem-1 sshd[3015]: Connection closed by 127.0.0.1 port 37398 [preauth]
Sep 09 21:51:02 nfqinxiansystem-1 sshd[3269]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=localhost  user=ops
```

&lt;!--more--&gt;

需要做以下几件事：

- 开启 `sshd` 允许密钥登录模式

    ```bash
    vim /etc/ssh/sshd_config

    #PubkeyAuthentication yes
    PubkeyAuthentication yes
    ```

- 修改 `~/.ssh` 文件权限

    ```bash
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/config
    ```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-09-09-ssh-%E4%BD%BF%E7%94%A8-pubkey-%E5%85%8D%E5%AF%86%E7%99%BB%E5%BD%95%E4%BB%8D%E8%A6%81%E6%B1%82%E8%BE%93%E5%85%A5%E5%AF%86%E7%A0%81%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/  

