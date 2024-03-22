# tmux 导致 vim color scheme 无法显示的问题



遇到一个奇怪的现象，对于 `vim 9` 的配色方案 `color-scheme`，我在普通的终端是可以显示主题配置。但是一旦通过 `tmux` 启动，则会失效。查找原因，发现是 `tmux` 没有使用配置方案，导致这个问题出现。

&lt;!--more--&gt;

修改 `~/.tmux.conf`

```bash
set -g default-terminal &#34;xterm-256color&#34;
```

同时，还是无法显示，这需要使用参数

```bash
tmux -2

## 或者可以写一个 alias
alias tnew=&#39;tmux -2 -u new -s&#39;
```

这个命令的作用在于

```bash
-2    Force tmux to assume the terminal supports 256 colours.  This is equivalent to -T 256.
```



我写了一个小脚本 `rsyncx.to.colo.sh`

```bash
#!/bin/bash

if [ $# != 1 ]
then
    echo &#34;usage: rsyncx.to.colo.sh &lt;cololid&gt;&#34;
    exit 1
fi

## -----------------------
colo=$1
echo &#34;sending to $colo&#34;
## -----------------------

rsync -Parzvl  ./.vim  $colo:~/
rsync -Parzvl  ./vim9  $colo:~/

## tmux 会引发 vim color scheme 错误
## https://stackoverflow.com/questions/10158508/lose-vim-colorscheme-in-tmux-mode
ssh $colo &#34;egrep &#39;.*default-terminal.*xterm-256color.*&#39; ~/.tmux.conf || echo -e &#39;set -g default-terminal \&#34;xterm-256color\&#34;&#39; &gt;&gt; ~/.tmux.conf&#34;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-27-tmux-%E5%AF%BC%E8%87%B4-vim-color-scheme-%E6%97%A0%E6%B3%95%E6%98%BE%E7%A4%BA%E7%9A%84%E9%97%AE%E9%A2%98/  

