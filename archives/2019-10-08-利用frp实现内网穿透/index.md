# 利用frp实现内网穿透


无论是在`服务器端`还是在`客户机端`，均需要安装 `frp`、并启动相关的服务。其中：

- `frps.init` 是服务器配置文件
- `frpc.init` 是客户端配置文件

&lt;!--more--&gt;

# 服务器配置

- 下载 `frp`

    ```bash
    cd ~
    wget https://github.com/fatedier/frp/releases/download/v0.21.0/frp_0.21.0_linux_amd64.tar.gz
    ```

- 解压

    ```bash
    tar -xzvf frp_0.21.0_linux_amd64.tar.gz
    cd frp_0.21.0_linux_amd64/
    ```

- 配置服务器，使用 `7000` 作为监听端口

    ```bash
    vim frps.ini

    [common]
    #bind_addr = 127.0.0.1
    bind_port = 7000
    token = *********
    ```

- 增加允许访问的端口。这个是需要通过 `7000` 的端口转发去访问的客户机端口，可以配置多个。比如我们在客户机的 `frpc.init` 增加了3个可以访问的端口，那么我们就需要告诉服务器，需要开放 `6011`、`6035`、`6066` 这3个端口的远程访问权限：

    ```bash
    [common]
    server_addr = 114.67.109.5
    server_port = 7000
    token = *********

    [sshlocal]
    type = tcp
    local_ip = 127.0.0.1
    local_port = 22
    remote_port = 6011

    [ssh135]
    type = tcp
    local_ip = 192.168.1.135
    local_port = 22
    remote_port = 6035

    [ssh166]
    type = tcp
    local_ip = 192.168.1.166
    local_port = 22
    remote_port = 6066
    ```

    开放端口使用命令 `FirewallD`：

    ```bash
    ## 增加远程访问 端口
    # 1.FirewallD防火墙开放8787端口
    firewall-cmd --zone=public --add-port=6011/tcp --permanent
    firewall-cmd --zone=public --add-port=6035/tcp --permanent
    firewall-cmd --zone=public --add-port=6066/tcp --permanent
    firewall-cmd --zone=public --add-port=6088/tcp --permanent
    firewall-cmd --zone=public --add-port=6099/tcp --permanent

    firewall-cmd --zone=public --add-port=7066/tcp --permanent
    firewall-cmd --zone=public --add-port=7099/tcp --permanent

    # 2.重启防火墙
    systemctl restart firewalld.service


    ## CentOS6 使用以下命令
    ## 开放 8899 端口
    /sbin/iptables -I INPUT -p tcp --dport 8899 -j ACCEPT
    ## 然后保存
    /etc/rc.d/init.d/iptables save
    ## 查看打开的端口
    /etc/init.d/iptables status
    ```

- 开启后台服务，通过 `nohup` 实现不间断的运行服务，记得在服务器是启动 `frps` 服务：

    ```bash
    nohup ./frps -c frps.ini &amp;
    ```

# 客户端配置

- 下载、解压“：

    ```bash
    cd ~
    wget https://github.com/fatedier/frp/releases/download/v0.21.0/frp_0.21.0_linux_amd64.tar.gz

    tar -xzvf frp_0.21.0_linux_amd64.tar.gz
    cd frp_0.21.0_linux_amd64/
    ```

- 配置客户机，客户端的配置文件在 `frpc.init`：

    ```bash
    [common]
    server_addr = xxx.xxx.xxx.xxx  	## 这里是填写服务器的固定 IP
    server_port = 7000				## 这里需要跟服务器端监听的端口一致，默认 7000

    [sshlocal]
    type = tcp
    local_ip = 127.0.0.1			## 本机
    local_port = 22
    remote_port = 6011

    [ssh135]
    type = tcp
    local_ip = 192.168.1.135		## 配置的本地内网服务器
    local_port = 22
    remote_port = 6035

    [ssh166]
    type = tcp
    local_ip = 192.168.1.166
    local_port = 22
    remote_port = 6066

    [ssh188]
    type = tcp
    local_ip = 192.168.1.188
    local_port = 22
    remote_port = 6088

    [ssh199]
    type = tcp
    local_ip = 192.168.1.199
    local_port = 22
    remote_port = 6099

    [ssh166_rstudio]				## 配置的本地内网服务器, Rstudio
    type = tcp
    local_ip = 192.168.1.166
    local_port = 8787
    remote_port = 7066

    [ssh199_rstudio]
    type = tcp
    local_ip = 192.168.1.199
    local_port = 8787
    remote_port = 7099
    ```

- 客户机开启后台服务命令，配置文件是 `frpc.init`

    ```bash
    nohup ./frpc -c frpc.ini &amp;
    ```

  提示连接成功：

    ```bash
    2019/10/08 20:11:19 [I] [proxy_manager.go:300] proxy removed: []
    2019/10/08 20:11:19 [I] [proxy_manager.go:310] proxy added: [ssh199 ssh166_rstudio ssh199_rstudio sshlocal ssh135 ssh166 ssh188]
    2019/10/08 20:11:19 [I] [proxy_manager.go:333] visitor removed: []
    2019/10/08 20:11:19 [I] [proxy_manager.go:342] visitor added: []
    2019/10/08 20:11:19 [I] [control.go:246] [60429e396343771b] login to server success, get run id [60429e396343771b], server udp port [0]
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [ssh135] start proxy success
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [ssh166] start proxy success
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [ssh188] start proxy success
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [ssh199] start proxy success
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [ssh166_rstudio] start proxy success
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [ssh199_rstudio] start proxy success
    2019/10/08 20:11:19 [I] [control.go:169] [60429e396343771b] [sshlocal] start proxy success
    ```

  并且我们可以在服务器端看到端口已经开启转发功能：

    ```bash
    [root@JD ~]# netstat -ntlp
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      24860/mysqld
    tcp        0      0 127.0.0.1:1234          0.0.0.0:*               LISTEN      2817/ifrit-agent
    tcp        0      0 0.0.0.0:8787            0.0.0.0:*               LISTEN      25292/rserver
    tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      11953/sshd
    tcp6       0      0 :::6088                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::6066                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::6099                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::6035                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::22                   :::*                    LISTEN      11953/sshd
    tcp6       0      0 :::7000                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::7066                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::6011                 :::*                    LISTEN      22623/./frps
    tcp6       0      0 :::7099                 :::*                    LISTEN      22623/./frps
    ```



# 使用 `ssh` 连接

```bash
ssh -p 6066 fl@xxx.xxx.xxx.xxx
&#39;&#39;$&#39;\n&#39;&#39;            &#39;   boost_1_70_0.tar.bz2   Documents              log      Pictures          Templates   Videos
 anaconda2              clion-2019.2           Downloads              Music    Public            test.pdf
 anaconda3              CLionProjects          Dropbox                myData   R                 test.Rmd
 antigen.zsh            data                   libraries              mydeck  &#39;R 入门教程.pdf&#39;   texmf
 bin                    Desktop               &#39;Linux 入门教程.html&#39;   myLog    tarball           tmp
 Boost                  disk                  &#39;Linux 入门教程.pdf&#39;    opt      temp              tmp_disk

RSA key fingerprint is ×××××××××××××××××××××××××××××××××××××××××
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added &#39;[XXX.XXX.XXX.XXX]:6066&#39; (RSA) to the list of known hosts.
Last login: Tue Oct  8 20:03:19 2019 from 192.168.1.111
```

# 总结

其实网上有很多类似的教程，但是如果一味的照搬他们的方法，其实是不能实现连接的。这里面的小技巧是要记得使用 `firewall` 开放端口的远程访问权限，才能进行转发。


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-10-08-%E5%88%A9%E7%94%A8frp%E5%AE%9E%E7%8E%B0%E5%86%85%E7%BD%91%E7%A9%BF%E9%80%8F/  

