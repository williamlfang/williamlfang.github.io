# xremap 拯救我的小拇指


我常用的编辑器是 `vim`，最近开始入坑 `Emacs`，觉得使用 `M-x` 导致小拇指极其难受。于是在谷歌搜索一番后，发现可以使用 `xremap` 重映射功能键，把 `Ctrl` 和 `Alt` 映射到更加方便的键盘位。

&lt;!--more--&gt;

## 下载 xremap

可以到[网站下载](https://github.com/xremap/xremap/releases)，选择 `x11`。解压后即可看到 `xremap` 可执行文件。

## 配置

可以编辑 `~/.config/xremap.yaml`，具体的键位名称可以参考：[keys](https://github.com/emberian/evdev/blob/1d020f11b283b0648427a2844b6b980f1a268221/src/scancodes.rs#L72)

{{&lt; admonition &gt;}}
For KEY_XXX and KEY_YYY, use these names. You can skip KEY_ and the name is case-insensitive. So KEY_CAPSLOCK, CAPSLOCK, and CapsLock are the same thing
{{&lt; /admonition &gt;}}

### modmap

{{&lt; admonition &gt;}}
modmap is for key-to-key remapping like xmodmap. Note that remapping a key to a modifier key, e.g. CapsLock to Control_L, is supported only in modmap since keymap handles modifier keys differently.
{{&lt; /admonition &gt;}}

- `modmap` 是**一一对应**的关系，不像 `keymap` 可以使用组合方式。比如，我把 `CapsLock` 当成 `Esc` 使用。
- 同时，我们还可以通过定义一个触发规则，把一个键位对应到多个事件，这个是通过定义 `held` 和 `alone` 组合来实现。比如我这里把 `Ctrl_L` 映射为两个行为

    - 如果是单独触发，在时间 `alone_timeout_millis` 内没有触发其他的按键，则对应 `Esc`
    - 如果是组合触发，比如我使用 `Ctrl-k` 来切换 `tmux` window

{{&lt; admonition &gt;}}
If you specify a map containing held and alone, you can use the key for two purposes. The key is considered alone if it&#39;s pressed and released within alone_timeout_millis (default: 1000) before any other key is pressed. Otherwise it&#39;s considered held.
{{&lt; /admonition &gt;}}

### keymap

`keymap` 可以实现组合键。

```bash
## https://github.com/emberian/evdev/blob/1d020f11b283b0648427a2844b6b980f1a268221/src/scancodes.rs#L26-L572
modmap:
  - name: Cap as Esc # Optional
    application: # Optional
      not: Google-chrome
      # or
      # only: [vim, nvim, neovim]
    remap: # Required
      CapsLock:
        # held: CapsLock
        held: Ctrl_L
        alone: Esc
        alone_timeout_millis: 1000
      Ctrl_L:
        held: Ctrl_L
        alone: Esc
        alone_timeout_millis: 1000 ## default:1000
keymap:
  - name: Right Arrow to complete in zsh
    application: # Optional
      not: Google-chrome
      # or
      # only: [vim, nvim, neovim]
    remap:
      # C-i: [Ctrl_L-Right]
      Alt-i: [Ctrl_L-Right]
      Alt-DOT: [Ctrl_L-Right]
      C-DOT: [Right, Right]
      C-COMMA: [Ctrl_L-Right]
      # Ctrl_L-SEMICOLON: [SPACE, Shift-KEY_BACKSLASH]
      # Ctrl_L-APOSTROPHE: [SPACE, Shift-KEY_BACKSLASH]
      C-SEMICOLON: [SPACE, Shift-KEY_BACKSLASH]
      C-APOSTROPHE: [SPACE, Shift-KEY_BACKSLASH]
      C-MINUS: [SPACE, Shift-KEY_MINUS]
  - name: Arrow
    remap:
      Alt-c: [Ctrl_L-c]
      Alt-v: [Shift-Insert]
      Alt-SPACE: Shift-Insert
      Shift-SPACE: Shift-Insert
      # Ctrl_L-SPACE: Shift-Insert
      Alt-h: [Ctrl_L-Left]
      Alt-j: Down
      Alt-k: Up
      Alt-l: [Ctrl_L-Right]
```

这里需要区分 `modmap` 与 `keymap`

- `modmap` is for key-to-key remapping like xmodmap. Note that remapping a key to a modifier key, e.g. `CapsLock`  to `Control_L`, is supported only in `modmap` since `keymap` handles modifier keys differently.
- `keymap` is for remapping a sequence of key combinations to another sequence of key combinations or other actions.

## 运行

使用 `root` 权限运行即可

```bash
## 需要 root 权限执行
sudo /home/william/xremap /home/william/.config/xremap.yaml
```

如果不使用 `root` 执行，则需要设置

```bash
## 需要获取 input 执行权限
sudo gpasswd -a william input
echo &#39;KERNEL==&#34;uinput&#34;, GROUP=&#34;input&#34;, TAG&#43;=&#34;uaccess&#34;&#39; | sudo tee /etc/udev/rules.d/input.rules

## 需要重启生效，下次就可以使用普通用户执行了
reboot
```

## ref

- [example/config.yaml](https://github.com/xremap/xremap/blob/master/example/config.yml)
- [example/emacs.yaml](https://github.com/xremap/xremap/blob/master/example/emacs.yml)
- [分享下我折腾 sway/alacritty/xremap 的经历](https://emacs-china.org/t/sway-alacritty-xremap/24781)
- [一份参考配置](https://github.com/jixiuf/dotfiles/blob/main/linux/etc/xremap.yaml)
- [使用内置 keyboard 修改映射](https://askubuntu.com/questions/485454/how-to-remap-keys-on-a-user-level-both-with-and-without-x)


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-10-20-xremap-%E6%8B%AF%E6%95%91%E6%88%91%E7%9A%84%E5%B0%8F%E6%8B%87%E6%8C%87/  

