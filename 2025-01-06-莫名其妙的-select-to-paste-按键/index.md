# 莫名其妙的 Select to paste 按键


这两天在使用 `hhkb` 键盘，并通过配置 `xremap` 进行键位映射，以更加舒服的姿势写代码。由于在 `hhkb` 键盘中，`Ctrl` 和 `Shift` 都处于左手小拇指的位置，这导致我在输入 `shift&#43;;` 的时候，有可能此时的小拇指还停留在 `Ctrl` 键，进而触发来 `Ctrl&#43;;`。然后诡异的是，这时候会跳出一个列表，显示 `Select to paste`，上面保留了系统粘贴板的信息。其实，这个是为了快速的输入最近的粘贴缓存，但是在这个情况下，我误触发键盘，极容易导致不停的跳出列表，非常影响效率。

![fcitx menu](./fcitx-menu.png &#34;fcitx-menu show Select to paste&#34;)

&lt;!--more--&gt;

# 找到快捷键

一开始，我没有想到这个是由于 `fcitx` 引起的，而是猜测可能是 `terminal` 或者 `tmux` 等程序的配置。但是触发这个行为，是都任何一个软件上对会出现，比如 `chrome`、 `sublime`，所以可以肯定是在系统层面。

我试图找到触发这个行为的快捷键，先是在系统层面的 `system settings` 看看是不是有设置；然而并没有找到相关的快捷键。这就有点难办了，因为这个是全局范围的行为，（一开始认为）应该跟某个特定软件无关。

# 遇到相同问题

然后在网上搜索关键字 `select to paste`，跳出第一个博客

{{&lt; link &#34;https://cprimozic.net/notes/posts/changing-linux-select-to-paste-menu-fcitx-keyboard-shortcut/&#34; &#34;Changing Linux Select to Paste Menu fcitx Keyboard Shortcut&#34; &#34;select to paste&#34; true true &gt;}}

仔细阅读文章，发现描述的就是我当前遇到的问题：莫名其妙的弹出 「select to paste」 的列表。于是在继续搜索发现 [problem with unwanted Klipper (or other) keyboard shortcut](https://askubuntu.com/questions/1104703/problem-with-unwanted-klipper-or-other-keyboard-shortcut)。所以可能肯定就是 「fcitx」 引起的问题。

这个也解释了为什么在系统层面没有设置快捷键，但是还是有触发全局行为。原来是因为输入法作为后台应用程序，其实一直处于启动的状态，所以会影响所有的软件。

# 修改快捷键

定位到问题所在，剩下的就是修改配置了。需要打开 `fcitx`，然后在 `Addon` 找到 **第一个** `Clipboard`，打开之后就会出现 `Trigger Key for Clipboard History List`，看到上面的 `Ctrl&#43;;`，恍然大悟：就是这个引起的问题呀。

不过目前看，其实这个设置还是很有用处的，可以帮助我们快速从最近的粘贴搬拷贝文本，而不用通过鼠标的粘贴，减少了手指离开键盘的操作。于是，我将其设置为 `Altr&#43;;`。

![clipboard history](./clipboard.png &#34;mapping altr&#43;; to Copy from Clipboard&#34;)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-06-%E8%8E%AB%E5%90%8D%E5%85%B6%E5%A6%99%E7%9A%84-select-to-paste-%E6%8C%89%E9%94%AE/  

