# xremap 拯救我的小拇指


我常用的编辑器是 `vim`，最近开始入坑 `Emacs`，觉得使用 `M-x` 导致小拇指极其难受。于是在谷歌搜索一番后，发现可以使用 `xremap` 重映射功能键，把 `Ctrl` 和 `Alt` 映射到更加方便的键盘位。

&lt;!--more--&gt;

## 下载 xremap

可以到[网站下载](https://github.com/xremap/xremap/releases)，选择 `x11`。解压后即可看到 `xremap` 可执行文件。

## 配置

可以编辑 `~/.config/xremap.yaml`

```bash
modmap:
  - name: Cap as Esc # Optional
    application: # Optional
      not: Google-chrome
      # or
      # only: [vim, nvim, neovim]
      # only: [Alacritty.Alacritty]
    remap: # Required
      CapsLock: Esc
keymap:
  - name: Ctrl-i as Esc (HHKB)
    application: # Optional
      not: Google-chrome
    remap:
      C-i: Esc
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

