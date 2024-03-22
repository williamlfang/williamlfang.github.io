# vim 打怪之旅


`vim` 素有「编辑器之神」的称呼。对于 「Linux-er」，`vim` 是我们日常写代码的得力助手。

当然，这个「助手」并非那么「听话」，有时还很「高冷」。据说 SO 上面关于 Vim 问答最活跃的一个帖子，是如何退出。

我曾经也是一名小白。从一开始的「恐vim」心态，逐渐变成「爱不释手」，这过程中所经历的曲折不尽其数。为了让自己更加熟悉 Vim，也为了后来者有所参数，我决定以博客的形式，记录自己在使用 Vim 过程中所思所想、所感所悟，希望对自己有所总结，对他人有所启发。

文中主要以使用工具的实践为导向，介绍相关的插件与配置。

&lt;!--more--&gt;

## Ref

之所以先把参考资源相关的连接放在前面，是因为我在修炼 `Vim` 的道路上，得到了这些前辈高手的指点与启发。在这里表示诚挚的感谢！

- [所需即所获：像 IDE 一样使用 vim](https://github.com/yangyangwithgnu/use_vim_as_ide)：这篇博文可以说是我的启蒙之光了，从非常使用的角度指导如何配置 `Vim`，使之成为一个得力的工具。我的大部分配置都参考了这个神作。在此向作者表示敬意！


## 打开大文件

```vimrc
&#34; ref:https://vim.fandom.com/wiki/Faster_loading_of_large_files
&#34; 处理 vim 打开大文件较慢的问题
&#34; file is large from 10mb
let g:LargeFile = 1024 * 1024 * 10 &#34;10MB
augroup LargeFile
  au!
  autocmd BufReadPre * let f=getfsize(expand(&#34;&lt;afile&gt;&#34;)) | if f &gt; g:LargeFile || f == -2 | call LargeFile() | endif
augroup END

function! LargeFile()
     &#34; no syntax highlighting etc
     set eventignore&#43;=FileType
     &#34; save memory when other file is viewed
     setlocal bufhidden=unload
     &#34; is read-only (write with :w new_filename)
     setlocal buftype=nowrite
     &#34; no undo possible
     setlocal undolevels=-1
     &#34; display message
     autocmd VimEnter *  echo &#34;The file is larger than &#34; . (g:LargeFile / 1024 / 1024) . &#34; MB, so some options are changed (see .vimrc for details).&#34;
endfunction
```

## YouCompleteMe(YCM)

对于经常使用 Vim 编辑 C&#43;&#43; 项目，我们需要一款得力的自动补全工具。

### 使用 Plug 安装（大概有不行）

```vimrc
Plug &#39;Valloric/YouCompleteMe&#39;, { &#39;do&#39;: &#39;./install.sh --go-completer --js-completer&#39;, &#39;on&#39;: []  }
```

### 使用 git 安装(可行方案)

```bash

```

### 配置

## NerdTree

## Seiya: 透明化背景

```vimrc
Plug &#39;miyakogi/seiya.vim&#39; &#34;使用命令:SeiyaEnable,SeiyaDisable
let g:seiya_auto_enable=1 &#34;默认启动 seiya
```

## tagbar

## Vim-Tmux 补全

&gt; 插件：[tmux-complete.vim](https://github.com/wellle/tmux-complete.vim)
&gt;
&gt; 功能：允许用户在编辑 vim 文件的时候，自动补全 Tmux 出现的字段

### 安装

```.vimrc
Plug &#39;prabirshrestha/async.vim&#39;
Plug &#39;prabirshrestha/asyncomplete.vim&#39;
Plug &#39;wellle/tmux-complete.vim&#39;

let g:tmuxcomplete#asyncomplete_source_options = {
            \ &#39;name&#39;:      &#39;tmuxcomplete&#39;,
            \ &#39;whitelist&#39;: [&#39;*&#39;],
            \ &#39;config&#39;: {
            \     &#39;splitmode&#39;:      &#39;words&#39;,
            \     &#39;filter_prefix&#39;:   1,
            \     &#39;show_incomplete&#39;: 1,
            \     &#39;sort_candidates&#39;: 0,
            \     &#39;scrollback&#39;:      0,
            \     &#39;truncate&#39;:        0
            \     }
            \ }
&#34;&#34; 设置：解决 enter 不能新起一行的问题
let g:tmuxcomplete#trigger = &#39;omnifunc&#39;
imap &lt;c-space&gt; &lt;Plug&gt;(asyncomplete_force_refresh)
inoremap &lt;expr&gt; &lt;CR&gt; pumvisible() ? asyncomplete#close_popup() . &#34;\&lt;CR&gt;&#34; : &#34;\&lt;CR&gt;&#34;
```

## Devicons

```
## 首先需要安装 nerd-fond
git clone https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
bash ./install.sh

## 需要设置 Terminator 的字体为 FiraCode Nerd Font Mono

## 然后安装插件即可显示
Plug &#39;ryanoasis/vim-devicons&#39;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-03-17-vim-%E6%89%93%E6%80%AA%E4%B9%8B%E6%97%85/  

