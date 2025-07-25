# Linux 安装 syncthing


使用 `syncthing` 同步不同机器之间的文件，所有数据均保留在本地机器。

&lt;!--more--&gt;

# 安装

```bash
## 安装发布密钥
sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
## 添加apt：稳定发布渠道
echo &#34;deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable&#34; | sudo tee /etc/apt/sources.list.d/syncthing.list
## [可选]添加apt：优先发布渠道
echo &#34;deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing candidate&#34; | sudo tee /etc/apt/sources.list.d/syncthing.list
## 安装
sudo apt-get update -y
sudo apt-get install syncthing -y
```

# 配置

我使用 `systemd` 维护自启动服务，可以到[官网](https://docs.syncthing.net/users/autostart.html#linux)下载 [systemd文件](https://raw.githubusercontent.com/syncthing/syncthing/refs/heads/main/etc/linux-systemd/system/syncthing%40.service)

```bash
cd /etc/systemd/system/
sudo systemctl enable  syncthing@william --now
sudo systemctl restart syncthing@william --now
sudo systemctl status  syncthing@william --now
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-06-08-linux-%E5%AE%89%E8%A3%85-syncthing/  

