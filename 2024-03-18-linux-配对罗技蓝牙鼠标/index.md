# Linux 配对罗技蓝牙鼠标


我在多年前购买了一款罗技无线蓝牙鼠标 `Master 3S`，使用感觉是相当得丝滑。不过非常遗憾，我这次过年回家，不小心把鼠标的蓝牙适配器弄丢了，导致最近办公只能使用戴尔赠送的有线鼠标。体验感不是特别好。

今天突发奇想，我原先也有一个旧的罗技蓝牙鼠标（初代Master），何不利用旧的蓝牙适配器来配对这款 `Master 3s` ？

&lt;!--more--&gt;

# 官网软件

首先遇到的问题是：由于罗技出产配对使用的是鼠标的通道，如果需要用其他蓝色接收器重新配对，则要通过罗技提供的软件进行重新配对的操作。遗憾的是（大部分厂商）都只提供 `Window` 和 `Mac` 操作系统下的软件版本，而没有开发 `Linux` 版本。这导致我无法从官网获取软件支持。

![Logi Options&#43;](./logtech.png &#34;罗技官网下载 Logi Options&#43;&#34;)

# Linux 开源软件

## 遇事不决，google 解决

当然，遇事不决，google 解决。我以关键词 **Logi Options&#43; linux** 检索，第一个跳出

{{&lt; link
    href=&#34;https://askubuntu.com/questions/1206369/logitech-options-on-linux&#34;
    content=&#34;StackOverflow:Logitech Options on Linux&#34;
    title=&#34;Logitech Options on Linux&#34;
    card=true
&gt;}}

按照上面的方法，开始安装 `solaar`

```bash
sudo apt install solaar
solaar
```

## solaar

打开 `solaar` 后，我们接下来需要添加新设备。我们需要把鼠标先关闭，然后再重新开启，这样程序才能识别是新接入的设备。

![添加新设, 记得先关闭再重启鼠标](./solaar-1.png &#34;添加新设, 记得先关闭再重启鼠标&#34;)

配对成功后，即可看到无线鼠标的设备信息来。

![成功配对我的 Master 3S](./solaar-2.png &#34;成功配对我的 Master 3S&#34;)


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-18-linux-%E9%85%8D%E5%AF%B9%E7%BD%97%E6%8A%80%E8%93%9D%E7%89%99%E9%BC%A0%E6%A0%87/  

