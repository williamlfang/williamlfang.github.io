# CentOS7 命令行设置分辨率


`CentOS` 可以通过命令行来设置（修改）屏幕分辨率大小。使用的命令是

&gt; xrandr

&lt;!--more--&gt;

```bash
[trader@localhost ~]$ xrandr --help
usage: xrandr [options]
  where options are:
  --display &lt;display&gt; or -d &lt;display&gt;
  --help
  -o &lt;normal,inverted,left,right,0,1,2,3&gt;
            or --orientation &lt;normal,inverted,left,right,0,1,2,3&gt;
  -q        or --query
  -s &lt;size&gt;/&lt;width&gt;x&lt;height&gt; or --size &lt;size&gt;/&lt;width&gt;x&lt;height&gt;
  -r &lt;rate&gt; or --rate &lt;rate&gt; or --refresh &lt;rate&gt;
  -v        or --version
  -x        (reflect in x)
  -y        (reflect in y)
  --screen &lt;screen&gt;
  --verbose
  --current
  --dryrun
  --nograb
  --prop or --properties
  --fb &lt;width&gt;x&lt;height&gt;
  --fbmm &lt;width&gt;x&lt;height&gt;
  --dpi &lt;dpi&gt;/&lt;output&gt;
  --output &lt;output&gt;
      --auto
      --mode &lt;mode&gt;
      --preferred
      --pos &lt;x&gt;x&lt;y&gt;
      --rate &lt;rate&gt; or --refresh &lt;rate&gt;
      --reflect normal,x,y,xy
      --rotate normal,inverted,left,right
      --left-of &lt;output&gt;
      --right-of &lt;output&gt;
      --above &lt;output&gt;
      --below &lt;output&gt;
      --same-as &lt;output&gt;
      --set &lt;property&gt; &lt;value&gt;
      --scale &lt;x&gt;x&lt;y&gt;
      --scale-from &lt;w&gt;x&lt;h&gt;
      --transform &lt;a&gt;,&lt;b&gt;,&lt;c&gt;,&lt;d&gt;,&lt;e&gt;,&lt;f&gt;,&lt;g&gt;,&lt;h&gt;,&lt;i&gt;
      --off
      --crtc &lt;crtc&gt;
      --panning &lt;w&gt;x&lt;h&gt;[&#43;&lt;x&gt;&#43;&lt;y&gt;[/&lt;track:w&gt;x&lt;h&gt;&#43;&lt;x&gt;&#43;&lt;y&gt;[/&lt;border:l&gt;/&lt;t&gt;/&lt;r&gt;/&lt;b&gt;]]]
      --gamma &lt;r&gt;:&lt;g&gt;:&lt;b&gt;
      --brightness &lt;value&gt;
      --primary
  --noprimary
  --newmode &lt;name&gt; &lt;clock MHz&gt;
            &lt;hdisp&gt; &lt;hsync-start&gt; &lt;hsync-end&gt; &lt;htotal&gt;
            &lt;vdisp&gt; &lt;vsync-start&gt; &lt;vsync-end&gt; &lt;vtotal&gt;
            [flags...]
            Valid flags: &#43;HSync -HSync &#43;VSync -VSync
                         &#43;CSync -CSync CSync Interlace DoubleScan
  --rmmode &lt;name&gt;
  --addmode &lt;output&gt; &lt;name&gt;
  --delmode &lt;output&gt; &lt;name&gt;
  --listproviders
  --setprovideroutputsource &lt;prov-xid&gt; &lt;source-xid&gt;
  --setprovideroffloadsink &lt;prov-xid&gt; &lt;sink-xid&gt;
  --listmonitors
  --listactivemonitors
  --setmonitor &lt;name&gt; {auto|&lt;w&gt;/&lt;mmw&gt;x&lt;h&gt;/&lt;mmh&gt;&#43;&lt;x&gt;&#43;&lt;y&gt;} {none|&lt;output&gt;,&lt;output&gt;,...}
  --delmonitor &lt;name&gt;
```

## 显示当前桌面的分辨率

直接使用命令 `xrandr` 来查看当前的分辨率大小：

```bash
VGA-1 connected primary 1920x1080&#43;0&#43;0 (normal left inverted right x axis y axis) 476mm x 267mm
   1600x900      60.00
   1280x1024     75.02    60.02
   1152x864      75.00
   1024x768      75.03    60.00
   800x600       75.00    60.32
   640x480       75.00    59.94
   1920x1080_60.00  59.96*
```

其中标记 `*` 的就是当前的参数设置。我们可以看到当前系统可以支持多个显示设置。

## 选择某个设置

使用选项 `-s` 来指定某个设置

```bash
xrandr -s 0 // 1600x900
```

## 直接设置分辨率

也可以在命令行直接指定设置：

```bash
xrandr -s 1920x1080_60.00
```

## `errors. BadName`

```bash
Xrandr errors. BadName (named color or font does not exist)
```bash

出现这个问题，一般是由于之前已经有一个显示的配置了，导致重命名。

&gt; I had a similar problem, I believe it was because I had already created that setting before (then rebooted). If I skip that stage and go straight to:

可以参考 [SO: Xrandr errors. BadName (named color or font does not exist) [closed]
](https://stackoverflow.com/questions/851704/xrandr-errors-badname-named-color-or-font-does-not-exist)

## 集成脚本`display.sh`

```bash
## 首次需要建立一个 --newmode
## 以后就不需要了，可以注释掉
## ------------------------
xrandr --newmode &#34;1920x1080_20.00&#34;  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync &#43;vsync

xrandr --addmode VGA-1 &#34;1920x1080_20.00&#34;

xrandr -s 1920x1080
```

## 开机自动调整分辨率

把以上的 `display.sh` 添加到 `~/.bashrc` 配置文件(run configure)。这样，每次开机后，会优先读取 `.bashrc` 文件，然后启动 `display.sh`。

```bash
echo &#34;bash ~/Desktop/display.sh&#34; &gt;&gt; ~/.bashrc
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-12-11-centos7-%E5%91%BD%E4%BB%A4%E8%A1%8C%E8%AE%BE%E7%BD%AE%E5%88%86%E8%BE%A8%E7%8E%87/  

