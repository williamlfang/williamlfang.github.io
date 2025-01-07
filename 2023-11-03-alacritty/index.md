# alacritty


`alacritty` 比 `terminator` 更加强大。


&lt;!--more--&gt;


```bash
apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
apt-get update --fix-missing
sudo apt install git curl cargo
cd /tmp
git clone https://github.com/alacritty/alacritty.git
cd alacritty/
curl --proto &#39;=https&#39; --tlsv1.2 -sSf https://sh.rustup.rs | sh
source &#34;$HOME/.cargo/env&#34;
rustup override set stable
sudo apt install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
cargo build --release
cargo build --release
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
```

## 处理 tmux 问题

```bash
## https://github.com/alacritty/alacritty/issues/2487
export TERM=xterm-256color

## 或者尝试使用以下配置
export TERM=xterm
tmux kill-server
```

## 处理 nvim 颜色显示问题

```bash
## https://github.com/alacritty/alacritty/issues/3354
set-option -ga terminal-overrides &#34;,alacritty:Tc&#34;
set -g default-terminal &#34;alacritty&#34;
```

## color issues

```bash
## tmux.conf
## alacrrity: https://github.com/alacritty/alacritty/issues/3354
set-option -ga terminal-overrides &#34;,alacritty:Tc&#34;
set -g default-terminal &#34;alacritty&#34;
## https://www.reddit.com/r/tmux/comments/onom6t/nvim_colors_change_if_on_tmux_on_alacritty/
set -g default-terminal &#39;xterm-256color&#39;
set -as terminal-overrides &#39;,xterm*:Tc:sitm=\E[3m&#39;

## .zshrc
## alacritty
export TERM=xterm-256color

## .bashrc

## colo
## .zshrc
export TERM=xterm-256color
## .bashrc
export TERM=xterm-256color
```

## 从 yaml 转换到 toml

```bash
alacritty migrate -c xxx.yaml

## 或者批量转换
find . -type f -name &#39;*.yaml&#39; | xargs -I {} alacritty migrate -c {}
```

## 我的配置

```toml
## -----------------------------------------------------------------------------color
import = [ &#34;~/.config/alacritty/git/alacritty-theme/themes/tokyo-night-storm.toml&#34; ]

## https://github.com/enkia/tokyo-night-vscode-theme/blob/master/themes/tokyo-night-storm-color-theme.json
#[colors.primary]
#background = &#34;0x24283b&#34;
##foreground = &#34;0xa9b1d6&#34;
#foreground = &#34;#7982a9&#34;

live_config_reload = true

[[colors.indexed_colors]]
color = &#34;#FAB387&#34;
index = 16

[[colors.indexed_colors]]
color = &#34;#F5E0DC&#34;
index = 17

[colors.cursor]
## 注释掉表示颜色反转
#cursor = &#34;#F5E0DC&#34;
#text = &#34;#1E1E2E&#34;
[colors.primary]
#background = &#34;#1E1E2E&#34;
#foreground = &#34;#CDD6F4&#34;
bright_foreground = &#34;#CDD6F4&#34;
dim_foreground = &#34;#CDD6F4&#34;
## tokyonight
#background= &#39;#24283b&#39;
#foreground= &#39;#a9b1d6&#39;

[colors.normal]
green = &#34;0x449dab&#34;

[colors.dim]
black = &#34;#45475A&#34;
blue = &#34;#89B4FA&#34;
cyan = &#34;#94E2D5&#34;
green = &#34;#A6E3A1&#34;
magenta = &#34;#F5C2E7&#34;
red = &#34;#F38BA8&#34;
white = &#34;#BAC2DE&#34;
yellow = &#34;#F9E2AF&#34;

[colors.hints.end]
background = &#34;#A6ADC8&#34;
foreground = &#34;#1E1E2E&#34;

[colors.hints.start]
background = &#34;#F9E2AF&#34;
foreground = &#34;#1E1E2E&#34;

[colors.search.focused_match]
background = &#34;#A6E3A1&#34;
foreground = &#34;#1E1E2E&#34;

[colors.search.matches]
background = &#34;#A6ADC8&#34;
foreground = &#34;#1E1E2E&#34;

[colors.selection]
background = &#34;#F5E0DC&#34;
text = &#34;#1E1E2E&#34;

[colors.vi_mode_cursor]
cursor = &#34;#B4BEFE&#34;
text = &#34;#1E1E2E&#34;

## ----------------------------------------------------------------------------env
[env]
TERM=&#39;xterm-256color&#39;
# TERM=&#39;Alacritty&#39;

## -----------------------------------------------------------------------------window
[window]
opacity = 0.90
padding.x = 12 ## width
padding.y =  0 ## height
decorations = &#34;Transparent&#34;
# decorations = &#34;None&#34; ## Full, Transparent, Buttonless, None
decorations_theme_variant = &#34;Dark&#34; #&#34;Light&#34;, &#34;Dark&#34;
startup_mode = &#39;Maximized&#39;

[scrolling]
# 回滚缓冲区中的最大行数,指定“0”将禁用滚动。
history = 1000
# 滚动行数
multiplier = 4

## -----------------------------------------------------------------------------font
[font]
size = 12.6
[font.normal]
#family = &#34;FiraCode Nerd Font&#34;
# family = &#34;SauceCodePro Nerd Font&#34;
family = &#34;JetBrainsMono Nerd Font&#34;
style = &#34;Regular&#34;
[font.italic]
# family = &#34;SauceCodePro Nerd Font&#34;
family = &#34;JetBrainsMono Nerd Font&#34;
style = &#34;Italic&#34;
[font.bold]
# family = &#34;SauceCodePro Nerd Font&#34;
family = &#34;JetBrainsMono Nerd Font&#34;
style = &#34;Bold&#34;

[[keyboard.bindings]]
action = &#34;SpawnNewInstance&#34;
key = &#34;Return&#34;
mods = &#34;Control|Shift&#34;

## https://alacritty.org/config-alacritty.html
## 可以通过设置 &#34;None&#34; 屏蔽掉某个快捷键
[[keyboard.bindings]]
# action = &#34;DecreaseFontSize&#34;
action = &#34;None&#34;
key = &#34;Minus&#34;
mods = &#34;Control&#34;
[[keyboard.bindings]]
# action = &#34;IncreaseFontSize&#34;
action = &#34;None&#34;
key = &#34;Equals&#34;
mods = &#34;Control&#34;

## ----------------------------------------------------------------------------shell
[shell]
program = &#34;/usr/bin/zsh&#34;

## ----------------------------------------------------------------------------selection: copy and paste
[selection]
# This string contains all characters that are used as separators for &#34;semantic words&#34; in Alacritty.
semantic_escape_chars=&#34;,│`|:\&#34;&#39; ()[]{}&lt;&gt;\t&#34;
# When set to `true`, selected text will be copied to the primary clipboard.
save_to_clipboard=true

## https://github.com/alacritty/alacritty/issues/6592
[[mouse.bindings]]
action = &#34;PasteSelection&#34;
mouse = &#34;Middle&#34;
[[mouse.bindings]]
action = &#34;PasteSelection&#34;
mouse = &#34;Right&#34;
[[keyboard.bindings]]
key = &#34;V&#34;
mods = &#34;ALT&#34;
action = &#34;Paste&#34;
# [keyboard]
# bindings = [
#   { key = &#34;C&#34;, mods = &#34;Control|Shift&#34;, mode = &#34;Vi|Search&#34;, action = &#34;ClearSelection&#34; },
#   { key = &#34;Insert&#34;, mods = &#34;Shift&#34;, action = &#34;Paste&#34; }
# ]
```

## Ref

- [一个配置的说明](https://sunnnychan.github.io/cheatsheet/linux/config/alacritty.yml.html)
- [alacritty.yml](https://fuchsia.googlesource.com/third_party/github.com/alacritty/alacritty/&#43;/refs/tags/v0.10.0-rc2/alacritty.yml)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-11-03-alacritty/  

