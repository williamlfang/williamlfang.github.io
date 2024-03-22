# 本地终端运行远程R命令，并输出图像


# 痛点

今天在网上看到一个 `R` 编程语言的扩展包，解决了长期以来困扰我的一个难题：如果在本地终端编辑运行位于远程服务器上的 `R` 命令脚本，并在需要的时候，能够把远程的画图同步输出到本地，使得在本地也可以浏览画图效果。针对这个问题，其实我们可以有以下至少三种解决方案：

1. Install [RStudio Server](https://www.rstudio.com/products/rstudio-server-pro/) on the remote server and use that from a web browser on your local machine. Graphics output is shown in the IDE.
2. Use X11 forwarding (`ssh -X|Y`). Graphics output is sent back to your machine.
3. Use VNC with a linux desktop environment like KDE or GNOME.

当然，第一种使用 `Rstudio` 其实是非常好的方案，运行在网页打开，整个界面其实就是本地化的 `IDE`，这也是我们团队目前使用的方案。但是，对于我这样使用惯了终端命令行的开发人员，更倾向于在 `Sublime` 编辑脚本，然后通过 `SublimeREPL` 把命令发送到远程服务器的解释器进行运行。长期以来，我一直在苦苦寻找这样的方案。

今天隆重介绍这个优秀的扩展包：[`rmote`](https://github.com/cloudyr/rmote)

# 解决

## ssh 登录服务器

`rmote` 默认开启 **4321** 的服务端口，可以通过 `rmote::start_rmote()` 进行设置。这个命令是把远程消息同步映射到本地浏览器端

```bash
ssh -L 4321:localhost:4321 fl@192.168.1.166
```

## 启动 R 服务

通过以上命令我们就登录了远程服务器，接下来是启动 `R` 进程开始运行

```R
R                                                                                                                                                                     [14:44:16]

R version 3.5.1 (2018-07-02) -- &#34;Feather Spray&#34;
Copyright (C) 2018 The R Foundation for Statistical Computing
Platform: x86_64-redhat-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type &#39;license()&#39; or &#39;licence()&#39; for distribution details.

  Natural language support but running in an English locale

R is a collaborative project with many contributors.
Type &#39;contributors()&#39; for more information and
&#39;citation()&#39; on how to cite R or R packages in publications.

Type &#39;demo()&#39; for some demos, &#39;help()&#39; for on-line help, or
&#39;help.start()&#39; for an HTML browser interface to help.
Type &#39;q()&#39; to quit R.


Attaching package: ‘emayili’

The following object is masked from ‘package:base’:

    body

&gt;

## 可以设置不同的端口
rmote::start_rmote()

?start_rmote
start_rmote               package:rmote                R Documentation

Initialize a remote servr

Description:

     Initialize a remote servr

Usage:

     start_rmote(server_dir = file.path(tempdir(), &#34;rmote_server&#34;), port = 4321,
       daemon = TRUE, help = TRUE, graphics = TRUE, basegraphics = TRUE,
       htmlwidgets = TRUE, hostname = TRUE, history = TRUE)

Arguments:

server_dir: directory to launch servr from

    port: port to run servr on

  daemon: logical - should the server be started as a daemon?

    help: (logical) send results of `?` to servr

graphics: (logical) send traditional lattice / ggplot2 plots to servr

basegraphics: (logical) send base graphics to servr

htmlwidgets: (logical) send htmlwidgets to servr

hostname: (logical) try to get hostname and use it in viewer page title

 history: (logical) should history thumbnails be created and shown in
          the viewer?

```

## 运行命令

输入命令运行

```R
?plot

library(ggplot2)
qplot(mpg, wt, data=mtcars, colour=cyl)
```

## 本地浏览器查看

这样，我们可以在浏览器打开 [http://localhost:4321](http://localhost:4321/) 即可查看图片。

# Sublime 集成快捷键

```bash
// 使用 Rmote 功能，实现远程服务器图片在本地浏览
  { &#34;keys&#34;: [&#34;f8&#34;],
    &#34;caption&#34;: &#34;SublimeREPL: Rmote166&#34;,
    &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
    {
        &#34;type&#34;: &#34;subprocess&#34;,
        &#34;external_id&#34;: &#34;r&#34;,
        &#34;additional_scopes&#34;: [&#34;tex.latex.knitr&#34;],
        &#34;encoding&#34;:
        {
            &#34;windows&#34;: &#34;$win_cmd_encoding&#34;,
            &#34;linux&#34;: &#34;utf8&#34;,
            &#34;osx&#34;: &#34;utf8&#34;
        },
        &#34;soft_quit&#34;: &#34;\nquit(save=\&#34;no\&#34;)\n&#34;,
        &#34;cmd&#34;: {&#34;linux&#34;:
                    [
                        &#34;ssh&#34;,
                        &#34;-L&#34;, &#34;4321:localhost:4321&#34;, &#34;fl@192.168.1.166&#34;, &#34;-p22&#34;,
                        &#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;
                    ]
                },
        &#34;cwd&#34;: &#34;$file_path&#34;,
        &#34;extend_env&#34;:
        {
            &#34;osx&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
            &#34;linux&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
            &#34;windows&#34;: {}
        },
        &#34;cmd_postfix&#34;: &#34;\n&#34;,
        &#34;suppress_echo&#34;:
        {
            &#34;osx&#34;: true,
            &#34;linux&#34;: true,
            &#34;windows&#34;: false
        },
        &#34;syntax&#34;: &#34;Packages/R/R Console.tmLanguage&#34;
    }
  },
```

![Rmote&#43;Chrome](/images/rmote.png)

# 问题

## 提示:

```R
- not sending to rmote because another graphics device has been opened...
- sending to the open graphics device instead...
- to send to rmote, close all active graphics devices using graphics.off()
```

说明已经有图片打开，需要关闭后即可

```R
graphics.off()
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-11-29-%E6%9C%AC%E5%9C%B0%E7%BB%88%E7%AB%AF%E8%BF%90%E8%A1%8C%E8%BF%9C%E7%A8%8Br%E5%91%BD%E4%BB%A4%E5%B9%B6%E8%BE%93%E5%87%BA%E5%9B%BE%E5%83%8F/  

