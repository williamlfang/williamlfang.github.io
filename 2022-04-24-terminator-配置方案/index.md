# Terminator 配置方案


`Terminator` 是一款优秀的 Linux 终端模拟器。

&lt;!--more--&gt;

## 配置 OneDark 方案

```bash
vim ~/.config/terminator


[global_config]
  focus = system
  window_state = maximise
  title_hide_sizetext = True
  title_transmit_bg_color = &#34;#d30102&#34;
  enabled_plugins = TerminatorThemes, TerminalShot, LaunchpadCodeURLHandler
  suppress_multiple_term_dialog = True
  title_use_system_font = False
  title_font = FiraCode Nerd Font 8
[keybindings]
  copy = &lt;Primary&gt;c
  paste = &lt;Alt&gt;v
[profiles]
  [[default]]
    background_image = None
    background_color = &#34;#282c34&#34;
    background_type = transparent
    background_darkness = 0.85
    cursor_color = &#34;#bbbbbb&#34;
    foreground_color = &#34;#abb2bf&#34;
    scrollbar_position = hidden
    palette = &#34;#000000:#eb6e67:#95ee8f:#f8c456:#6eaafb:#d886f3:#6cdcf7:#b2b2b2:#50536b:#eb6e67:#95ee8f:#f8c456:#6eaafb:#d886f3:#6cdcf7:#dfdfdf&#34;
    use_system_font = False
    font = FiraCode Nerd Font Mono 12
    icon_bell = False
    show_titlebar = False
    copy_on_selection = True
  [[One dark]]
    background_image = None
    background_color = &#34;#282c34&#34;
    background_type = transparent
    background_darkness = 0.85
    cursor_color = &#34;#bbbbbb&#34;
    foreground_color = &#34;#abb2bf&#34;
    scrollbar_position = hidden
    palette = &#34;#000000:#eb6e67:#95ee8f:#f8c456:#6eaafb:#d886f3:#6cdcf7:#b2b2b2:#50536b:#eb6e67:#95ee8f:#f8c456:#6eaafb:#d886f3:#6cdcf7:#dfdfdf&#34;
    use_system_font = False
    font = FiraCode Nerd Font Mono 12
    icon_bell = False
    show_titlebar = False
    copy_on_selection = True
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      profile = One dark
      type = Terminal
    [[[window0]]]
      parent = &#34;&#34;
      type = Window
[plugins]
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-04-24-terminator-%E9%85%8D%E7%BD%AE%E6%96%B9%E6%A1%88/  

