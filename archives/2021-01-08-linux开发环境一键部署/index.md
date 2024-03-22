# Linux开发环境一键部署


# 套件

## zsh

```bash
## 可以到主页看一下最新的版本号
## https://www.zsh.org/
wget https://sunsite.icm.edu.pl/pub/unix/shells/zsh/zsh-5.8.tar.xz

tar -xvf zsh-5.8.tar.xz
cd zsh-5.8
./configure --prefix=/home/lfang/opt
make -j &amp;&amp; make install

## 安装 oh-my-zsh
## sh -c &#34;$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)&#34;
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
bash install.sh

## 如果报错，则把 install.sh 里面的 https 换成 git，这是因为 curl 可能不是最新版的
# Cloning Oh My Zsh...
# Cloning into &#39;/home/lfang/.oh-my-zsh&#39;...
# fatal: unable to find remote helper for &#39;https&#39;
# Error: git clone of oh-my-zsh repo failed

## 安装 antigen
mkdir -p ~/.zsh
curl -L git.io/antigen &gt; ~/.zsh/antigen.zsh

echo &#34;
## 需要找到相应的路径
fpath=(/home/lfang/opt/share/zsh/5.8/functions $fpath)
export FPATH=&#34;/home/lfang/opt/share/zsh/5.8/functions:$FPATH&#34;

source ~/.zsh/antigen.zsh

# Bundles from the default repo (robbyrussell&#39;s oh-my-zsh).
antigen bundles &lt;&lt;EOBUNDLES
command-not-found
colored-man-pages
magic-enter
heroku
pip
lein
extract
tmux
ssh-agent
zsh-users/zsh-completions
zsh-users/zsh-autosuggestions
hlissner/zsh-autopair
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search # load after zsh-syntax-highlighting
HeroCC/LS_COLORS
rupa/z
djui/alias-tips # Alias reminder when launching a command that is aliased
EOBUNDLES

# Tell Antigen that you&#39;re done.
antigen apply
&#34; &gt;&gt; ~/.zshrc

source ~/.zshrc
```

## autojump

```bash

```





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-01-08-linux%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2/  

