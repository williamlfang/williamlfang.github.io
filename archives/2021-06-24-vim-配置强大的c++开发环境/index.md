# Vim 配置强大的C&#43;&#43;开发环境


# 安装 Vim8

## 使用 Anaconda-python

```bash
## 不需要 lto
export LDFLAGS=&#34;-fno-lto&#34;
## 有可能需要添加环境路径
## 1.
ldconfig -p |grep libSM
ldconfig -p |grep libuuid
## 2.
export PATH=
export LD_LIBRARY_PATH=

./configure --prefix=$HOME/opt \
--enable-python3interp=yes \
--enable-cscope \
--enable-gui=auto \
--enable-gtk2-check \
--enable-gnome-check \
--with-features=huge \
--enable-multibyte \
--enable-largefile \
--disable-netbeans \
--with-compiledby=&#34;xorpd&#34; \
--enable-fail-if-missing \
--with-python3-command=$HOME/anaconda3/bin/python3 \
--with-python3-config-dir=$HOME/anaconda3/lib/python3.7/config-3.7m-x86_64-linux-gnu

make -j &amp;&amp; make install

~/opt/bin/vim --version |grep python
/home/ops/opt/bin/vim: /home/ops/anaconda3/lib/libuuid.so.1: no version information available (required by /lib64/libSM.so.6)
&#43;cmdline_hist      &#43;langmap           -python            &#43;visual
&#43;cmdline_info      &#43;libcall           &#43;python3           &#43;visualextra
Linking: gcc -fno-lto -L/usr/local/lib -Wl,--as-needed -o vim -lSM -lICE -lXt -lX11 -lSM -lICE -lm -ltinfo -lselinux -ldl -L/home/ops/anaconda3/lib/python3.7/config-3.7m-x86_64-linux-gnu -lpython3.7m -lcrypt -lpthread -ldl -lutil -lrt -lm
```

## 使用系统自带 python3

```bash
./configure --prefix=$HOME/opt \
	--with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --enable-python3interp=yes \
    --with-python3-config-dir=$(python3-config --configdir) \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-gui=gtk2 \
    --enable-cscope\
    --enable-largefile \
	--disable-netbeans \
	--with-x \
	--with-compiledby=&#34;xorpd&#34; \
	--enable-fail-if-missing
```



## 使用源代码编译 python

```bash
## 为了避免出现 _ctypes 错误
## 建议安装一下 yum install libffi-devel

## 需要安装动态库
## 在安装 Python 的时候，最好添加命令
## ./configure --enable-optimizations --enable-share

export LDFLAGS=&#34;-rdynamic&#34;
export LDFLAGS=&#34;-fno-lto&#34;

export PATH=
export LD_LIBRARY_PATH=

./configure --prefix=$HOME/opt \
--enable-python3interp=yes \
--enable-cscope \
--enable-gui=auto \
--enable-gtk2-check \
--enable-gnome-check \
--with-features=huge \
--enable-multibyte \
--enable-largefile \
--disable-netbeans \
--with-compiledby=&#34;xorpd&#34; \
--enable-fail-if-missing \
--with-python3-command=$HOME/opt/bin/python3.9 \
--with-python3-config-dir=$HOME/opt/lib/python3.9/config-3.9-x86_64-linux-gnu
```



# 安装插件

随着 `Vim` 生态环境的改善，现在我们有了更多的插件管理器。从早期的 `Vundle` 到新晋网红 `Vim-Plug`，插件的管理功能逐渐得到改善，如支持并行安装、按需加载功能、异步调用等。

当前最为推荐的`Vim`插件，当属 `Vim-Plug`。

## 安装 Vim-Plug

简单粗暴，直接下载到 `~/.vim` 目录下即可

```bash
sh -c &#39;curl -fLo &#34;${XDG_DATA_HOME:-$HOME/.local/share}&#34;/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim&#39;
```

## 如何使用 Vim-Plug 安装插件

跟 `Vundle` 一样的方法，我们可以通过在`~/.vimrc`添加

```bash
&#34; ================================
&#34; 设置安装插件的路径
call plug#begin(&#39;~/.vim/plugged&#39;)

&#34;&#34; 安装指定插件，可以通过 github 找到 repo 的地址
&#34;&#34; 如:https://github.com/airblade/vim-gitgutter
&#34;&#34; 我们就直接使用url，让管理器自动安装
Plug &#39;airblade/vim-gitgutter&#39;

call plug#end()
&#34; ================================
```

这样，就把需要安装的插件地址配置好了，接下来需要 `Vim` 进行插件的安装

```bash
## 打开 Vim

## 然后进入命令模式
## 运行: PlugInstall 就会自动安装相关的插件了


```

## 特色功能

### for:针对某个语言加载

### on:按照需要加载

### 几个常用命令



# 配置 .vimrc

## 主题配色

### onedark.vim

&gt; 不要使用管理器来安装，这样安装后无法修改配色方案，需要手动安装。

到 [onedark.vim](https://github.com/joshdick/onedark.vim) 下载相应的配色方案

- `~/.vim/colors/onedark.vim`
- `~/.vim/autoload/onedark.vim`

接下来我们需要修改 `~/.vim/colors/onedark.vim`

```vim
&#34;&#34; =============================================================================
call s:h(&#34;Pmenu&#34;, { &#34;bg&#34;: s:menu_grey }) &#34; Popup menu: normal item.
call s:h(&#34;PmenuSel&#34;, { &#34;fg&#34;: s:dark_yellow, &#34;bg&#34;: s:special_grey }) &#34; Popup menu: selected item.
call s:h(&#34;PmenuSbar&#34;, { &#34;bg&#34;: s:special_grey }) &#34; Popup menu: scrollbar.
call s:h(&#34;PmenuThumb&#34;, { &#34;bg&#34;: s:white }) &#34; Popup menu: Thumb of the scrollbar.
&#34;&#34; =============================================================================
```

因为 `onedark.vim` 会覆盖其他的配色方案，如果我们需要单独进行配置，一定要写在这后面。比如，对行号的高亮

```bash
&#34;&#34; =========================================================
&#34;&#34; 所有的设置需要在 coloscheme 前面
&#34;&#34; =========================================================
&#34;&#34; https://github.com/joshdick/onedark.vim
let g:onedark_terminal_italics=1
let g:airline_theme=&#39;onedark&#39;
&#34;&#34;hi LineNr ctermfg=240

&#34;&#34; =========================================================
&#34;&#34; 所有设置都会被覆盖
&#34;let g:onedark_termcolors=256
colorscheme onedark
&#34;colorscheme space-vim-dark
&#34;hi Normal     ctermbg=NONE guibg=NONE
&#34;hi LineNr     ctermbg=NONE guibg=NONE
&#34;hi SignColumn ctermbg=NONE guibg=NONE

&#34; 高亮当前行 ================================================
&#34;高亮当前行和行号
&#34; -highlght 主要是用来配色的，包括语法高亮等个性化的配置。可以通过:h highlight，查看详细信息
&#34; -CursorLine 和 CursorColumn 分别表示当前所在的行列
&#34; -cterm 表示为原生vim设置样式，设置为NONE表示可以自定义设置。
&#34; -ctermbg 设置终端vim的背景色
&#34; -ctermfg 设置终端vim的前景色
&#34; -guibg 和 guifg 分别是设置gvim的背景色和前景色，本人平时都是使用终端打开vim，所以只是设置终端下的样式
&#34; 设置高亮行和列
&#34;set cursorcolumn
set cursorline
&#34;设置高亮效果
&#34; Removes the underline causes by enabling cursorline:
highlight clear CursorLine
&#34;highlight CursorLine   cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
&#34;highlight CursorColumn cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
highlight CursorLine   cterm=NONE ctermbg=black ctermfg=none guibg=NONE guifg=NONE
highlight CursorColumn cterm=NONE ctermbg=black ctermfg=none guibg=NONE guifg=NONE

highlight LineNr term=bold cterm=bold ctermfg=DarkGrey ctermbg=NONE gui=None guifg=DarkGrey guibg=NONE
highlight CursorLineNR term=bold ctermfg=DarkGreen ctermbg=black cterm=bold
&#34;highlight CursorLineNR term=bold ctermfg=DarkGreen ctermbg=DarkGrey cterm=bold
set linebreak              &#34; wrap long lines between words
&#34;&#34; =========================================================
```



## 常用工具

## 快捷键

## 设置技巧





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-06-24-vim-%E9%85%8D%E7%BD%AE%E5%BC%BA%E5%A4%A7%E7%9A%84c&#43;&#43;%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83/  

