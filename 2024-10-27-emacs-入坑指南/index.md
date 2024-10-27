# Emacs 入坑指南


`DoomEmacs` 通过使用 `evil` 模式，很好地结合了 `Emacs` 与 `Vim`，非常适合入坑。

&lt;!--more--&gt;

## 安装

### 安装 Emacs

```bash
sudo add-apt-repository ppa:ubuntuhandbook1/emacs
sudo apt install emacs emacs-common

emacs --version
```

### 安装 DoomEmacs

```bash
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

## 如果有修改，需要执行 sync
doom sync
```

## 配置

需要在环境变量中指定 `DOOMDIR`

```bash
export DOOMDIR=~/.doom.d
cp  templates/config.example.el  ~/.doom.d/config.el
```

### ~/.doom.d/config.el

```lisp
;; ----------------------------------------------------------------------------
;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run &#39;doom
;; sync&#39; after modifying this file!
;; ----------------------------------------------------------------------------

;; theme: ---------------------------------------------------------------------
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme&#39; or manually load a theme with the
;; `load-theme&#39; function. This is the default:
(setq doom-theme &#39;doom-tokyo-night)

;; Leader: --------------------------------------------------------------------
;; DoomEmacs default leader is `&lt;Space&gt;`, here I change it to `;`
;; since it is much more easy
(setq doom-leader-key &#34;;&#34;
      doom-leader-alt-key &#34;;&#34;)
```

## 使用


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-10-27-emacs-%E5%85%A5%E5%9D%91%E6%8C%87%E5%8D%97/  

