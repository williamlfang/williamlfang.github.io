# youtube dl 神器介绍


# 安装

```bash
## CentOS
sudo yum install epel-release
sudo rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm

sudo yum -y install ffmpeg ffmpeg-devel

## ubuntu
sudo apt install ffmpeg

## 安装 youtube-dl
sudo apt install python3-pip
pip3 install youtube-dl   #安装
pip3 install --upgrade youtube-dl  #升级

## 或者使用 apt 安装
sudo apt-get install youtube-dl
```
&lt;!--more--&gt;

# 使用

- 设置代理
- 设置下载功能

```bash
alias youdl=&#39;youtube-dl --yes-playlist  --playlist-start 1 --proxy &#34;socks5://127.0.0.1:1086&#34; --write-sub --sub-format &#34;ass/srt/best&#34; --convert-subs &#34;srt&#34;&#39;

youdl https://www.youtube.com/watch?v=xVT1y0xWgww
```

## 效果

```bash
youdl https://www.youtube.com/watch?v=xVT1y0xWgww

[youtube] xVT1y0xWgww: Downloading webpage
[info] Writing video subtitles to: CppCon 2017 - Nir Friedman “What C&#43;&#43; developers should know about globals (and the linker)”-xVT1y0xWgww.en.vtt
WARNING: Requested formats are incompatible for merge and will be merged into mkv.
[download] Destination: CppCon 2017 - Nir Friedman “What C&#43;&#43; developers should know about globals (and the linker)”-xVT1y0xWgww.f248.webm
[download]  17.4% of 221.79MiB at 914.28KiB/s ETA 03:25
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-03-12-youtube-dl-%E7%A5%9E%E5%99%A8%E4%BB%8B%E7%BB%8D/  

