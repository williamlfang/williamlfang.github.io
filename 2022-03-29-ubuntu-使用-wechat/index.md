# ubuntu 使用 wechat


通过在 Ubuntu 系统安装 `Deepin`，可以实现使用微信、企业微信、QQ 等多款社交工具。

&lt;!--more--&gt;

##  安装 Deepin 套件

访问官网[deepin-wine](https://deepin-wine.i-m.dev/)，可以发现很多的宝藏工具。

首次使用需要先添加仓库

```bash
wget -O- https://deepin-wine.i-m.dev/setup.sh | sh
```

后面就可以直接安装需要的软件了，具体的名称可以从列表获取得到。比如，我们需要安装微信

```bash
apt install com.qq.weixin.deepin
```

## 微信字体为方框（显示不正常）

### 终极方法
发现之前的方法都是不对的，需要这样处理。主要是参考了这篇博客：[关于Ubuntu 20.04 安装Deepin Wine Wechat后输入框中文方框](http://www.4k8k.xyz/article/qq_31051683/117899323)。

```bash
## 1. 先查看使用的字体
vim ~/.deepinwine/Deepin-WeChat/system.reg

## 查找使用的字体，发现需要使用 SimSun
&#34;MS Shell Dlg&#34;=&#34;SimSun&#34;
&#34;MS Shell Dlg 2&#34;=&#34;Tahoma&#34;

## 2. 那就下载一份相关的字体
## SimSun: https://github.com/micmro/Stylify-Me/blob/main/.fonts/SimSun.ttf
wget https://github.com/micmro/Stylify-Me/blob/main/.fonts/SimSun.ttf
cp SimSun.ttf ~/.deepinwine/Deepin-WeChat/drive_c/windows/Fonts/

## 3. 执行注册表
WINEPREFIX=~/.deepinwine/Deepin-WeChat/ deepin-wine regedit ~/.deepinwine/Deepin-WeChat/system.reg

## 4. 重启wechat即可解决
```

综合上述，写了一个简单的脚本

```bash
## =============================================================
## 杀掉某个指定的进程
## killx program_name
killx () {
    list=$(ps aux | grep -i $1| grep -v color | awk &#39;{print $2}&#39;)

    if [ -n &#34;$list&#34; ]; then
        echo &#34;Killing... $1&#34;
        echo $list | xargs kill -9
    else
        echo &#34;Not running $1&#34;
    fi
}
## =============================================================

## =============================================================
wechat() {
    killx wechat
    killx wine
    cp ~/SimSun.ttf ~/.deepinwine/Deepin-WeChat/drive_c/windows/Fonts/
	## wine 的可执行图标位于
    ## /opt/apps/com.qq.weixin.deepin/entries/applications
    WINEPREFIX=~/.deepinwine/Deepin-WeChat/ deepin-wine regedit ~/.deepinwine/Deepin-WeChat/system.reg
    /opt/apps/com.qq.weixin.deepin/files/run.sh &amp;
}
## =============================================================
```

### 无效方法

需要我们修改默认的系统字体

```bash
cd /opt/deepinwine/tools/
ll

total 2.1M
drwxr-xr-x 2 root root 4.0K Mar 29 00:18 .
drwxr-xr-x 4 root root 4.0K Oct 24  2020 ..
-rwxr-xr-x 1 root root 2.1K Dec  9 19:25 add_hotkeys
-rwxr-xr-x 1 root root 112K Feb 23  2016 app-uninstaller.exe
-rwxr-xr-x 1 root root  15K Dec 20 14:44 fontconfig
-rwxr-xr-x 1 root root  714 Dec  9 19:25 get_tray_window
-rwxr-xr-x 1 root root 6.3K Dec  9 19:25 kill.sh
-rwxr-xr-x 1 root root 1.1K Dec  9 19:25 log.sh
-rwxr-xr-x 1 root root  898 Dec  9 19:25 map_device.sh
-rwxr-xr-x 1 root root  19K Dec 20 14:44 QQGameRunner
-rwxr-xr-x 1 root root  808 Dec  9 19:25 register_font.sh
-rwxr-xr-x 1 root root  22K Mar 29 00:13 run.sh
-rwxr-xr-x 1 root root  12K Mar 29 00:13 run_v2.sh
-rwxr-xr-x 1 root root  13K Mar 29 00:13 run_v3.sh
-rwxr-xr-x 1 root root  14K Mar 29 00:18 run_v4.sh
-rwxr-xr-x 1 root root  13K Dec  9 19:25 sendkeys.exe
-rwxr-xr-x 1 root root 2.4K Dec  9 19:25 sendkeys.sh
-rwxr-xr-x 1 root root 1.5K Dec  9 19:25 SetDpi.sh
-rwxr-xr-x 1 root root 3.1K Feb 22  2016 uninstall.sh
-rwxr-xr-x 1 root root 1.9M Dec 20 14:44 updater
```

这里，我们需要修改

```bash
#安装需要的字体
sudo apt-get install -y ttf-wqy-microhei
sudo apt-get install -y ttf-wqy-zenhei
sudo apt-get install -y xfonts-wqy
#解决微信无法查看发送图片问题
sudo apt install libjpeg68:i386

#参考：https://github.com/wszqkzqk/deepin-wine-ubuntu/issues/136
#终极解决方案
#上述方式略微有一些缺陷，修复如下：
#在run.sh/v2/v3/v4的开头，添加如下：

export LC_ALL=zh_CN.UTF-8
```

如果以上步骤还是不行，则可以尝试下面的方法：

```bash
## 到 https://github.com/qiuhuachuan/fonts/blob/main/MSYH.TTC 下载字体
wget https://github.com/qiuhuachuan/fonts/blob/main/MSYH.TTC

## 拷贝到指定位置
cp MSYH.TTC ~/.deepinwine/Deepin-WeChat/drive_c/windows/Fonts/msyh.ttc

## 将字体注册到 Wine
vim ~/.deepinwine/Deepin-WeChat/font.reg

## 复制一下内容
REGEDIT4
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes]
&#34;MS Shell Dlg&#34;=&#34;msyh&#34;
&#34;MS Shell Dlg 2&#34;=&#34;msyh&#34;

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink]
&#34;Lucida Sans Unicode&#34;=&#34;msyh.ttc&#34;
&#34;Microsoft Sans Serif&#34;=&#34;msyh.ttc&#34;
&#34;MS Sans Serif&#34;=&#34;msyh.ttc&#34;
&#34;Tahoma&#34;=&#34;msyh.ttc&#34;
&#34;Tahoma Bold&#34;=&#34;msyhbd.ttc&#34;
&#34;msyh&#34;=&#34;msyh.ttc&#34;
&#34;Arial&#34;=&#34;msyh.ttc&#34;
&#34;Arial Black&#34;=&#34;msyh.ttc&#34;

## 在命令行执行以下操作
## 如果提示有 wine 程序在执行，需要全部kill掉
WINEPREFIX=~/.deepinwine/Deepin-WeChat/ deepin-wine regedit ~/.deepinwine/Deepin-WeChat/font.reg

## 现在重新运行微信就可以显示中文字体了
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-03-29-ubuntu-%E4%BD%BF%E7%94%A8-wechat/  

