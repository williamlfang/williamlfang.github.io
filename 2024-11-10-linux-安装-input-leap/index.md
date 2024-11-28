# Linux 安装 input leap



## 安装 libc(3.38)

```bash
## 添加源
echo &#34;deb http://th.archive.ubuntu.com/ubuntu jammy main    #添加该行到文件&#34; &gt;&gt; /etc/apt/sources.list

## 升级
sudo apt update
sudo apt install libc6
```

## 安装 libqt6

```bash
sudo add-apt-repository ppa:okirby/qt6-backports
sudo apt update
apt-get update
sudo apt install qt6-base-dev
apt --fix-broken install
```

## 安装 Input-Leap

到 [github 项目主页](https://github.com/input-leap/input-leap) [下载](https://github.com/input-leap/input-leap/releases/download/v3.0.2/InputLeap_3.0.2_ubuntu_22-04_amd64.deb)


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-11-10-linux-%E5%AE%89%E8%A3%85-input-leap/  

