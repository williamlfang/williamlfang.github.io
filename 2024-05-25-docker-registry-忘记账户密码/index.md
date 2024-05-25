# docker registry 忘记账户密码


如果忘记 `docker-registry` 账户密码，可以通过复原加密密码查看。

&lt;!--more--&gt;

打开 `~/.docker/config.json`

```json
{
    &#34;auths&#34;: {
        &#34;192.168.1.162:5000&#34;: {
            &#34;auth&#34;: &#34;********************&#34;
        }
    }
}
```

以上密码是在添加 `docker-registry` 时使用 `htpasswd` 加密的

```bash
sudo yum install -y httpd-tools
mkdir /etc/docker/auth
htpasswd -Bbn tradeops passwd &gt; /etc/docker/auth/htpasswd
```

我们可以反向解密

```bash
echo ********** | base64 -d
```

得到

```bash
tradeops:*********
```

然后再登录即可

```bash
docker login -u tradeops 192.168.1.162:5000

Password:
WARNING! Your password will be stored unencrypted in /home/william/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-25-docker-registry-%E5%BF%98%E8%AE%B0%E8%B4%A6%E6%88%B7%E5%AF%86%E7%A0%81/  

