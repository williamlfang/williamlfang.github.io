# Ubuntu 安装 Deepin wechat


# 安装

可以参考项目地址：[deepin-wine](https://github.com/zq1997/deepin-wine)。

```bash
## 需要添加仓库
wget -O- https://deepin-wine.i-m.dev/setup.sh | sh

## 开始安装应用
## wechat
sudo apt-get install deepin.com.wechat

## wechat-work
sudo apt install deepin.com.weixin.work
```



# 字体安装

由于 `wechat` 使用了 **文泉驿字体**，因此需要再安装相关的字体

```bash
sudo apt-get install ttf-wqy-microhei  #文泉驿-微米黑

sudo apt-get install ttf-wqy-zenhei  #文泉驿-正黑

sudo apt-get install xfonts-wqy #文泉驿-点阵宋体
```



# 输入法

有报告提出由于 `wechat` 和 `sogou` 使用的 `qt` 版本不一致，导致在微信的界面会出现卡死的现象。安装旧版本或者不使用。

# 使用





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-10-24-ubuntu-%E5%AE%89%E8%A3%85-deepin-wechat/  

