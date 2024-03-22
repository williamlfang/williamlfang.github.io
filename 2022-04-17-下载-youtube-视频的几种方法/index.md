# 下载 YouTube 视频的几种方法


作为 IT 开发人员，我们常常需要了解新的技术，学习新的技能。从个人的经验看，我偏向于通过 Google 和 YouTube 获取新信息，一方面是原生的英文文档更新相对比较及时，另外这些渠道的分享资源相对比较优质。

YouTube 上面有大量的技术分享视频、各种专业的会议视频（如CppCon），在本篇博文，我简单介绍几种获取 YouTube 视频的方法。

&lt;!--more--&gt;

## AddonCrop

Ref:https://addoncrop.com/v2/youtube-downloader/

## Chrome 下载插件

之前有一个非常优秀的 YouTube 视频下载网站，[savefrom](https://us.savefrom.net/)，非常遗憾的被迫关闭了。但是这个网站提供了一种下载 YouTube 视频的思路：可以通过插件的形式，把需要下载的视频作为缓存，进行拼接保存下来。

[下载Youtube视频的几种常用方法和软件](https://www.sunnyfly.com/download-youtube-video.html) 有比较详细的介绍：

1. 首先给你的Chrome安装上[Tampermonkey](https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)
2. 然后在[Greasyfork](https://greasyfork.org/zh-CN/scripts/369400-local-youtube-downloader)安装本地Youtube下载器激活即可。

## yt-dlp 命令行

`youtube-dl` 是一个十分优秀的命令行下载视频的工具，而这款 [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) 则是基于其而增强功能的升级版，使用起来也很简单。

我写了一个简单的 `bash` 脚本，可以循环下载整个视频列表。

```bash
#!/bin/bash
url=&#34;https://www.youtube.com/watch?v=SbQVY-JOrgg&amp;list=PLHTh1InhhwT6VxYHtoWIvOup9gz0p95Qr&amp;index=8&amp;t=26s&#34;
while true
do
    yt-dlp --playlist-start 1  --yes-playlist --write-sub --sub-format &#34;ass/srt/best&#34; --convert-subs &#34;srt&#34; $url

    status=$?
    if [[ $status = 0 ]];
    then
		exit
    fi
done
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-04-17-%E4%B8%8B%E8%BD%BD-youtube-%E8%A7%86%E9%A2%91%E7%9A%84%E5%87%A0%E7%A7%8D%E6%96%B9%E6%B3%95/  

