# Emacs 入坑


一直在入坑，却从未爬出来。

&lt;!--more--&gt;

# Install

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/gnu/emacs/emacs-29.1.tar.gz
tar -xvf emacs-29.1.tar.gz
cd emacs-29.1

## 准备安装环境
sudo apt build-dep emacs

##
./configure --with-x-toolkit=no  --with-xpm=ifavailable --with-gif=ifavailable  --with-pop
```

# DoomEmacs

```bash
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d

## 添加到环境变量的可执行路径
export PATH=/home/william/.emacs.d/bin:$PATH
```

- 在修改了`~/.doom.d/init.el` 和 `~/.doom.d/packages.el` 后需要执行 `doom sync`
- 如果有问题就运行 `doom doctor`
- 如果需要更新就运行 `doom upgrade`
- 可以在 `Emacs` 内通过 `SPC h d h` 来查看文档

可以通过命令查看启动时间：`M-x emacs-init-time`

# 字体

ref: https://github.com/seagle0128/doom-modeline/issues/310

&gt; @bk138 Currently `nerd-icons` is used in `doom-modeline`, while `all-the-icons` has been dropped. You should install `nerd-fonts` via `M-x nerd-icons-install-fonts`. Please read REAME.

```bash
## 安装 nerd symbol font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/NerdFontsSymbolsOnly.zip
unzip NerdFontsSymbolsOnly.zip
cd NerdFontsSymbolsOnly
cp *ttf ~/.local/share/fonts

## 更新字体缓存
fc-cache -fv
fc-list |grep -i nerd

## 清理原来的 font
cd /home/william/.emacs.d/.local/straight/repos
rm all-the-icons.el
cd /home/william/.emacs.d/.local/straight/build-29.1
rm -rf all-the-icons

## 重新加载
doom sync &amp;&amp; doom build

## 安装必要的字体包
M-x all-the-icons-install-fonts
M-x nerd-icons-install-fonts
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-10-11-emacs-%E5%85%A5%E5%9D%91/  

