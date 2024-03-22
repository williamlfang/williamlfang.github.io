# terminator themes


配置 `terminator` 主题颜色，以插件的形式提供了灵活的配置方式。[The biggest collection of Terminator themes](https://github.com/EliverLara/terminator-themes)。

&lt;!--more--&gt;

# 获取配置

这个一定要在系统自带的 `terminal` 里安装，否则会无法载入。[Can&#39;t find the plugin in the preferences &amp;gt; Plugins](https://github.com/EliverLara/terminator-themes/issues/14)

&gt; Had the same problem, make sure to close any open instance of terminator b4 trying, solved it for me
&gt;
&gt; 需要关闭所有的 terminator, 然后在系统自带的 terminal 下面安装。

```bash
sudo apt install python-requests
mkdir -p $HOME/.config/terminator/plugins

## For terminator &gt;= 1.9
wget https://git.io/v5Zww -O $HOME&#34;/.config/terminator/plugins/terminator-themes.py&#34;

## For terminator &lt; 1.9
wget https://git.io/v5Zwz -O $HOME&#34;/.config/terminator/plugins/terminator-themes.py&#34;
```

# 安装插件

现在，打开 `terminator`，鼠标右键点击选择 `Preference -&gt; Plugins`，然后选中 `TerminatorThemes` 按钮。

![激活](/images/2019-01-22-terminator-themes/preference.gif)

# 安装主题

内置了非常丰富的主题配色，可以在 `terminator` 操作界面，使用鼠标右键选择 `themes` 来安装和选择喜欢的配色。

![主题](/images/2019-01-22-terminator-themes/themes.gif)

# 设置默认
可以在启动 `terminator` 的时候，启用默认的配色方案。

打开 `~/.config/terminator/config`，把 `[plugins] -&gt; [profiles] -&gt; [[default]]` 的设置替换为默认启动的方案即可。

```bash
## 这个是原来的一个默认配置
[plugins]
[profiles]
  [[default]]
    background_color = &#34;#002b36&#34;
    background_darkness = 0.92
    background_type = transparent
    copy_on_selection = True
    cursor_color = &#34;#aaaaaa&#34;
    foreground_color = &#34;#839496&#34;
    palette = &#34;#073642:#dc322f:#859900:#b58900:#268bd2:#d33682:#2aa198:#eee8d5:#002b36:#cb4b16:#586e75:#657b83:#839496:#6c71c4:#93a1a1:#fdf6e3&#34;
    show_titlebar = False
    use_theme_colors = True
```

比如，我用 `Zenburn` 配置

```bash
[plugins]
[profiles]
  [[default]]
    background_color = &#34;#3f3f3f&#34;
    background_darkness = 0.92
    background_type = transparent
    copy_on_selection = True
    cursor_color = &#34;#dcdcdc&#34;
    foreground_color = &#34;#dcdcdc&#34;
    palette = &#34;#3f3f3f:#cc9393:#7f9f7f:#e3ceab:#dfaf8f:#cc9393:#8cd0d3:#dcdccc:#3f3f3f:#cc9393:#7f9f7f:#e3ceab:#dfaf8f:#cc9393:#8cd0d3:#dcdccc&#34;
    show_titlebar = False
  [[Zenburn]]
    background_color = &#34;#3f3f3f&#34;
    background_type = transparent
    copy_on_selection = True
    cursor_color = &#34;#73635a&#34;
    foreground_color = &#34;#dcdccc&#34;
    palette = &#34;#4d4d4d:#705050:#60b48a:#f0dfaf:#506070:#dc8cc3:#8cd0d3:#dcdccc:#709080:#dca3a3:#c3bf9f:#e0cf9f:#94bff3:#ec93d3:#93e0e3:#ffffff&#34;
    show_titlebar = False
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-01-22-terminator-themes/  

