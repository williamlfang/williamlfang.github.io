# autossh 实现反向代理自动重连


# 下载

```bash
## https://www.harding.motd.ca/autossh/
wget https://www.harding.motd.ca/autossh/autossh-1.4g.tgz
```
&lt;!--more--&gt;

# 安装

```bash
tar -xvf autossh-1.4g.tgz
cd autossh-1.4g
./configure --prefix=$HOME/opt
make -j &amp;&amp; make install
```

# 使用



## 阿里云

```bash
## 运行外部访问端口 8002 转发到 8001，然后由 8001 转发到托管机器 22 端口
ssh -fNCL *:8002:localhost:8001 localhost
```

## 托管机器

```bash
## 开启 8001，任何访问外网的端口会自动转发到 22，即 ssh 服务
ssh -fNCR 8001:localhost:22 -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -o ExitOnForwardFailure=True -p 22 root@47.98.117.71

autossh -M 60001 \
-fN -o &#34;PubkeyAuthentication=yes&#34; \
-o &#34;StrictHostKeyChecking=false&#34; -o &#34;ServerAliveInterval 60&#34; -o &#34;ServerAliveCountMax 3&#34; \
-R 8001:localhost:22 \
-p 22 root@47.98.117.71
```

命令说明：

- `-M 60001` 选项指定中继服务器上的监视端口，用于交换监视 SSH 会话的测试数据，需要保证该端口在服务器上未被占用，一般而言，``autossh` 还有再占用后面一到两个端口用于监控，所以如果在一个机器上面有多个 `autossh`，建议中间的端口会稍微岔开一些。
- `-o` 用于设置 autossh 参数
- `-f` 指定 autossh 在后台运行，并不会传给 ssh
- `-R` 远程连接，还有一种模式是 `-L` 本地转发
- `-p` 登录的账户与端口信息

举个例子，我们在 `XTP02` 机器上面

```bash
##[autossh]
## ops@R7 可以访问本地
## ssh admin@127.0.0.1 -p 60002
autossh -M 51001 \
    -fN -o &#34;PubkeyAuthentication=yes&#34; \
    -o &#34;StrictHostKeyChecking=false&#34; -o &#34;ServerAliveInterval 60&#34; -o &#34;ServerAliveCountMax 3&#34; \
    -R 0.0.0.0:60002:localhost:22 \
    -p 60001 ops@58.33.72.179


## HF02 可以访问ops@R7, 10.36.121.115 是本地前兆网卡地址
## ssh ops@10.36.121.115 -p60001
autossh -M 51011 \
    -fN -o &#34;PubkeyAuthentication=yes&#34; \
    -o &#34;StrictHostKeyChecking=false&#34; -o &#34;ServerAliveInterval 60&#34; -o &#34;ServerAliveCountMax 3&#34; \
    -L 10.36.121.115:60001:localhost:22 \
    -p 60001 ops@58.33.72.179
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-03-28-autossh-%E5%AE%9E%E7%8E%B0%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E8%87%AA%E5%8A%A8%E9%87%8D%E8%BF%9E/  

