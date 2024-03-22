# 解决ssh上传公钥到服务器仍需输入密码的问题


为了保证安装，我们通常使用公钥登录的方式，可以避免输入密码。但是如果权限管理不正确，即使上传了本地公钥后，ssh 登录连接仍然提示需要输入密码。

这主要是因为权限设置的问题。参考链接：[SSH 上传公钥到服务器后还需要密码](https://ruby-china.org/topics/14182)。

&gt; 貌似是.ssh目录和authorized的权限不对，ssh -vvT git@serverip时出现了：ignored authorized_keys bad ownership or modes for directory。然后google搜答案.将.ssh的权限改为700,authorized_keys权限改为600即可。

```bash
cd ~/
mkdir .ssh
chmod 700 .ssh

## touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys

## touch .ssh/config
chmod 600 .ssh/config

Host lyb
    HostName 127.0.0.1
    Port 10135
    User admin
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-02-%E8%A7%A3%E5%86%B3ssh%E4%B8%8A%E4%BC%A0%E5%85%AC%E9%92%A5%E5%88%B0%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%BB%8D%E9%9C%80%E8%BE%93%E5%85%A5%E5%AF%86%E7%A0%81%E7%9A%84%E9%97%AE%E9%A2%98/  

