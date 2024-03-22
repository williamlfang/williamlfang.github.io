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

## Ref

- [一个配置的说明](https://sunnnychan.github.io/cheatsheet/linux/config/alacritty.yml.html)
- [alacritty.yml](https://fuchsia.googlesource.com/third_party/github.com/alacritty/alacritty/&#43;/refs/tags/v0.10.0-rc2/alacritty.yml)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-11-03-alacritty/  

