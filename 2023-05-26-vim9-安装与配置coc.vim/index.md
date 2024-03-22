# vim9 安装与配置coc.vim


安装 `vim9`，并使用 `coc.vim` 实现代码补全。我把常用的一些插件也放在这里，方便大家参考。

&lt;!--more--&gt;

## 安装注意事项

安装 `vim9` 遇到了一些坑，这里先说一下：

1. 不一定需要最新版本的 `python3`。我原来为了安装最新版本的 `python3.11`，而去升级 `glibc-2.28` 以上版本。但是呢，其实这个系统(`Centos7.6`)内核只支持到 `glibc-2.18`，升级到这个版本以上的话，会导致其他的可执行程序出现问题，比如

    ```bash
    ls: relocation error: /home/ops/vim9/local/lib/libc.so.6: symbol __tunable_get_val, version glibc_private not defined in file ld-linux-x86-64.so.2 with link time reference
    ```

    这是因为系统与 `glibc` 有非常严格的版本关系，在不同的 `glibc` 版本编译出来的可执行，往往内存空间是不一样的。严重的时候，甚至会引起 `segment fault` 的错误。这篇 `Stack OverFlow` 的问答真是解释了这个问题，并且极力不推荐随意升级 `glibc`，尤其是系统层面的环境路径：[safely upgrade glibc on CentOS 7](https://serverfault.com/questions/894625/safely-upgrade-glibc-on-centos-7)

2. 上面说道不需要最新版本的 `python3`，那目前我尝试过可用的版本，可以是 `python3.9.0`

3. 另外，在编译 `python` 的时候，一定要加上命令 `export LDFLAGS=-rdynamic`

4. 同时，我们也不要更新太高版本的 `nodejs`，这个同样要求我们升级 `glibc`，目前可以的版本是 `node-v16.20.0`

## 安装过程

下面开始介绍安装 `vim9` 的完整过程，我默认把 `vim` 安装到 home 下面的 `vim9` 文件夹。使用的时候，通过指定可执行的路径。

```bash
export VIM9_PATH=$HOME/vim9
mkdir -p ${VIM9_PATH}/local/{bin,lib}
mkdir -p $HOME/tmp
```

### 安装 openssl

这个主要是为了给 `python` 使用

```bash
cd $HOME/tmp &amp;&amp; wget --no-check-certificate https://www.openssl.org/source/openssl-3.0.7.tar.gz &amp;&amp; \
    tar -xvf openssl-3.0.7.tar.gz &amp;&amp; \
    cd openssl-3.0.7 &amp;&amp; \
    ./config --prefix=${VIM9_PATH}/local/openssl --openssldir=${VIM9_PATH}/local/openssl no-shared zlib-dynamic &amp;&amp; \
    make -j &amp;&amp; make install \
    rm -rf $HOME/tmp/openssl*
```

### 安装 python3.9

```bash
export PYTHON_VERSION=3.9.0
cd $HOME/tmp &amp;&amp; \
    wget --no-check-certificate https://registry.npmmirror.com/-/binary/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz &amp;&amp; \
    tar -xvf Python-${PYTHON_VERSION}.tar.xz &amp;&amp; \
    cd Python-${PYTHON_VERSION} &amp;&amp; \
    export LDFLAGS=-rdynamic &amp;&amp; \
    CFLAGS=&#34;-I${VIM9_PATH}/local/openssl/include&#34; LDFLAGS=&#34;-L${VIM9_PATH}/local/openssl/lib64&#34; \
    ./configure \
        --enable-shared \
        --enable-optimizations \
        --enable-loadable-sqlite-extensions \
        --prefix=${VIM9_PATH}/local \
        --with-openssl=${VIM9_PATH}/local/openssl &amp;&amp; \
    make -j &amp;&amp; make install
```

### 安装 lua

```bash
cd $HOME/tmp &amp;&amp; wget --no-check-certificate http://www.lua.org/ftp/lua-5.4.4.tar.gz &amp;&amp; \
    tar -xvf lua-5.4.4.tar.gz &amp;&amp; \
    cd lua-5.4.4 &amp;&amp; \
    sed -i &#39;s|^INSTALL_TOP=.*|INSTALL_TOP= ${VIM9_PATH}/local|g&#39; Makefile &amp;&amp; \
    make -j &amp;&amp; make install
```

### 安装 perl

这个我暂时不需要，就没安装了

```bash
wget http://www.cpan.org/src/5.0/perl-5.14.2.tar.gz &amp;&amp; \
tar -xzf perl-5.14.2.tar.gz &amp;&amp; \
cd perl-5.14.2

# -d: default
# -e: escapte question
./Configure –des -Dprefix=/home/william/vim9/local
make
#make test
make install

## 如果 vim 需要 perl 支持
## 则添加这个选项
--enable-perlinterp=$HOME/vim9/local/bin/perl
```

### 安装 vim

```bash
cd /tmp &amp;&amp; \
    git clone https://github.com/vim/vim.git &amp;&amp; \
    cd vim &amp;&amp; \
    git pull origin master &amp;&amp; \
    make clean distclean

export VIM9_PATH=$HOME/vim9
export LD_LIBRARY_PATH=${VIM9_PATH}/local/lib:$LD_LIBRARY_PATH
export PATH=$HOME/vim9/local/bin:${VIM9_PATH}/local/bin:${VIM9_PATH}/local/node-v16.20.0-linux-x64/bin:$PATH

./configure --prefix=$HOME/vim9/local \
    --with-features=huge \
    --enable-multibyte \
    --enable-python3interp=yes \
    --with-python3-command=$HOME/vim9/local/bin/python3 \
    --with-python3-config-dir=$($HOME/vim9/local/bin/python3-config --configdir) \
    --enable-luainterp=yes \
    --with-lua-prefix=$HOME/vim9/local \
    --enable-cscope \
    --enable-largefile \
    --disable-netbeans \
    --with-compiledby=&#34;william&#34; \
    --enable-fail-if-missing

## --enable-perlinterp=/home/ops/vim9/local/bin/perl

make -j &amp;&amp; make install
```

### 安装 nodejs

由于 `coc.vim` 需要 `nodejs` 支持

```bash
cd $HOME/vim9/local

## 直接下载二进制，可以省掉安装步骤（还挺费时间的）
cd /tmp
wget https://nodejs.org/dist/latest-v16.x/node-v16.20.0-linux-x64.tar.gz
tar -xvf node-v16.20.0-linux-x64.tar.gz
cp -r node-v16.20.0-linux-x64 $HOME/vim9/local

export VIM9_PATH=$HOME/vim9
export LD_LIBRARY_PATH=${VIM9_PATH}/local/lib:$LD_LIBRARY_PATH
export PATH=$HOME/vim9/local/bin:${VIM9_PATH}/local/bin:${VIM9_PATH}/local/node-v16.20.0-linux-x64/bin:$PATH

## 安装 yarn
npm install -g yarn

## 如果 coc.vim 是离线安装，则可以执行

## ~/.vim/plugged/coc.nvim/是我的coc.nvim插件的安装目录
cd ~/.vim/plugged/coc.nvim/
yarn install
yarn build
```

## 配置 vim

### alias

```bash
#alias vim=&#39;LD_LIBRARY_PATH=$HOME/vim9/local/lib:$LD_LIBRARY_PATH PATH=$HOME/vim9/local/bin:$HOME/vim9/local/node-v16.20.0-linux-x64/bin:$PATH vim -u $HOME/.vimrc.coc&#39;
#alias vim=&#39;LD_LIBRARY_PATH=$HOME/vim9/local/lib:$LD_LIBRARY_PATH PATH=$HOME/vim9/local/bin:$HOME/vim9/local/node-v16.20.0-linux-x64/bin:$PATH $HOME/vim9/local/bin/vim -u $HOME/vim9/.vimrc&#39;
alias vim=&#39;LD_LIBRARY_PATH=$HOME/vim9/local/lib:$LD_LIBRARY_PATH PATH=$HOME/vim9/local/bin:$HOME/vim9/local/node-v16.20.0-linux-x64/bin:$PATH $HOME/vim9/local/bin/vim -u $HOME/vim9/.vimrc&#39;
```

注意，对于新安装的 `vim`，需要退出当前 `ssh` 连接后，重新登录才可以生效。


### 解决 tmux 配色无效生效的冲突

```bash
## tmux 会引发 vim color scheme 错误
## https://stackoverflow.com/questions/10158508/lose-vim-colorscheme-in-tmux-mode
egrep &#39;.*default-terminal.*xterm-256color.*&#39; ~/.tmux.conf || echo -e &#39;set -g default-terminal \&#34;xterm-256color\&#34;&#39; &gt;&gt; ~/.tmux.conf
```

同时，还是无法显示，这需要使用参数

```bash
tmux -2

## 或者可以写一个 alias
alias tnew=&#39;tmux -2 -u new -s&#39;
```

### 安装 vim.plugin

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### coc.vim

0. `coc.vim` 只是提供一个调用接口，所有的代码补全与检查功能都是由 `lsp` 提供。而为了能够处理 `cpp` 文件，我们一定要确保在 `coc-settings.json` 里面配置的 `clangd` 能够正确运行，否则运行命令 `: CocCommand clangd.install` 会报错：coc client failed to connected

    ```bash
    ## 务必确保 clangd 的服务端是可以正常启动的
    ## 如果有报错，需要找到对应版本的 clangd 二进制
    ## 然后在 `coc-settings.json` 进行设置
    pwd
    /home/william/.config/coc/extensions/coc-clangd-data/install/16.0.2/clangd_16.0.2/bin

    ./clangd

    clangd is a language server that provides IDE-like features to editors.

    It should be used via an editor plugin rather than invoked directly. For more information, see:
    https://clangd.llvm.org/
    https://microsoft.github.io/language-server-protocol/

    clangd accepts flags on the commandline, and in the CLANGD_FLAGS environment variable.

    I[17:56:41.885] clangd version 16.0.2 (https://github.com/llvm/llvm-project 18ddebe1a1a9bde349441631365f0472e9693520)
    I[17:56:41.885] Features: linux&#43;grpc
    I[17:56:41.885] PID: 17226
    I[17:56:41.885] Working directory: /home/william/.config/coc/extensions/coc-clangd-data/install/16.0.2/clangd_16.0.2/bin
    I[17:56:41.885] argv[0]: ./clangd
    I[17:56:41.885] Starting LSP over stdin/stdout
    ```

1. 如果报错没有找到 `clangd` ，则需要我们自己安装。这个命令需要打开一个`test.cpp`文件再执行: CocCommand clangd.install
2. 具体的配置可以通过帮助命令 `:h g:coc_data_home` 来获取，比如在 `.vimrc` 设置

    - 存放 `coc` 配置路径`coc-settings.json`：`let g:coc_config_home=~/.vim`
    - 存放 `coc` 插件路径`coc-clang`等：`let g:coc_data_home=~/.config/coc`

    ```bash
    g:coc_config_home					*g:coc_config_home*

    	Configure the directory which will be used to look for
    	user&#39;s `coc-settings.json`, default:

    	Windows: `~/AppData/Local/nvim`
    	Other: `~/.config/nvim`

    g:coc_data_home						*g:coc_data_home*

    	Configure the directory which will be used to for data
    	files(extensions, MRU and so on), default:

    	Windows: `~/AppData/Local/coc`
    	Other: `~/.config/coc`

    ```
3. 打开命令 `:CocConfig` 进行配置

    ```bash
    {
      // Enable preselect feature on neovim, default: `true`
      &#34;suggest.enablePreselect&#34;: true,
      // Add preview option to `completeopt`, default: `false`
      &#34;suggest.enablePreview&#34;: true,
      // completion automatically select the first completed
      &#34;suggest.noselect&#34;: false,
      // &#34;suggest.triggerAfterInsertEnter&#34;: true
      &#34;diagnostic.checkCurrentLine&#34;: true,
      // min word for trigger preview
      &#34;suggest.minTriggerInputLength&#34;: 1,
      // Target to show hover information, default is floating window when possible.
      &#34;coc.preferences.hoverTarget&#34;: &#34;preview&#34;,
      // Auto close preview window on cursor move.,  default: `true`
      &#34;coc.preferences.previewAutoClose&#34;: true,

      // Coc.Prettier ---------------------------------------------------------------
      &#34;prettier.singleQuote&#34;: true,
      &#34;prettier.trailingComma&#34;: &#34;all&#34;,
      &#34;prettier.bracketSpacing&#34;: false,

      // Coc.Python -----------------------------------------------------------------
      &#34;python.linting.pylintEnabled&#34;: false,
      &#34;python.linting.flake8Enabled&#34;: true,
      &#34;python.linting.enabled&#34;: true,
      &#34;python.pythonPath&#34;: &#34;/home/william/anaconda3/bin/python3&#34;,
      &#34;pyright.inlayHints.variableTypes&#34;: false,
      &#34;clangd.path&#34;: &#34;~/.config/coc/extensions/coc-clangd-data/install/16.0.2/clangd_16.0.2/bin/clangd&#34;
    }
    ```
### zsh-vim-fzf 搜索并打开目标文件

在 `zsh` 使用 `fzf` 搜索目标文件，并调用 `vim` 打开。我设置的快捷键为 `Ctrl-f`

```bash
## vim ~/.zshrc

## fzf : Ctr-f -------------------------------------------------
# .zshrc example
function __fsel_files() {
  setopt localoptions pipefail no_aliases 2&gt; /dev/null
  eval find ./ -type f -print | fzf --reverse -m &#34;$@&#34; | while read item; do
    echo -n &#34;${(q)item} &#34;
  done
  local ret=$?
  echo
  return $ret
}

function fzf-vim {
    selected=$(__fsel_files)
    if [[ -z &#34;$selected&#34; ]]; then
        zle redisplay
        return 0
    fi
    zle push-line # Clear buffer
    BUFFER=&#34;vim $selected&#34;;
    zle accept-line
}
zle -N fzf-vim
bindkey &#34;^f&#34; fzf-vim
```

## .vimrc

```bash
set nocompatible
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
noremap          &lt;F2&gt; :Autoformat&lt;CR&gt;
nnoremap &lt;silent&gt;&lt;F3&gt; :call &lt;SID&gt;ToggleColorColumn()&lt;cr&gt;    &#34; Show Column
nmap             &lt;F4&gt; :ALEDetail&lt;CR&gt;                        &#34; ALE detail info
nmap     &lt;silent&gt;&lt;F5&gt; :NERDTreeToggle&lt;CR&gt;                   &#34; Nerd
nmap     &lt;silent&gt;&lt;F8&gt; :TagbarToggle&lt;CR&gt;                     &#34; Tagbar
nnoremap &lt;silent&gt;&lt;F9&gt; :call asyncrun#quickfix_toggle(5)&lt;cr&gt;&#34; Show build window
&#34; nnoremap &lt;silent&gt;&lt;F10&gt; :AsyncRun -cwd=&lt;root&gt; cd `pwd`/build &amp;&amp; bash ../kickstart.sh &lt;cr&gt;
nnoremap &lt;silent&gt;&lt;F10&gt; :AsyncRun -cwd=&lt;root&gt; cd `pwd`/build &amp;&amp; bash ../kickstart.sh &amp;&amp; make install &lt;cr&gt;
map &lt;F12&gt; :%s/\t/    /g&lt;CR&gt;
&#34; imap tt &lt;Esc&gt;   &#34; ff to exit insert mode
&#34; 定义快捷键的前缀，即&lt;Leader&gt;
let mapleader=&#34;;&#34;
let maplocalleader=&#34;;&#34;
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;

&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;&#34; Plug
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
call plug#begin()

&#34; Code completion -------------------------------------------------------------
Plug &#39;neoclide/coc.nvim&#39;, {&#39;branch&#39;: &#39;release&#39;}

&#34; Color Theme -----------------------------------------------------------------
Plug &#39;sainnhe/everforest&#39;

Plug &#39;frazrepo/vim-rainbow&#39;
Plug &#39;mechatroner/rainbow_csv&#39;
let g:disable_rainbow_hover = 1
let g:rainbow_comment_prefix = &#39;#&#39;

&#34; Status Bar ------------------------------------------------------------------
Plug &#39;vim-airline/vim-airline&#39;
Plug &#39;vim-airline/vim-airline-themes&#39;
&#34;&#34; Adding extras.
&#34;&#34; Uncomment the following line If you have installed the powerline fonts.
&#34;&#34; It is good for airline layer.
let g:airline_powerline_fonts = 1
let g:airline_theme=&#39;everforest&#39;
&#34; AIRLINE SETTINGS
let g:airline#extensions#tabline#show_close_button = 0
&#34;&#34; AIRLINE SETTINGS
let g:airline#extensions#tabline#show_close_button = 0
&#34; let g:airline#extensions#tabline#buffer_nr_show = 1 &#34; 不要显示 index
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap &lt;leader&gt;1 &lt;Plug&gt;AirlineSelectTab1
nmap &lt;leader&gt;2 &lt;Plug&gt;AirlineSelectTab2
nmap &lt;leader&gt;3 &lt;Plug&gt;AirlineSelectTab3
nmap &lt;leader&gt;4 &lt;Plug&gt;AirlineSelectTab4
nmap &lt;leader&gt;5 &lt;Plug&gt;AirlineSelectTab5
nmap &lt;leader&gt;6 &lt;Plug&gt;AirlineSelectTab6
nmap &lt;leader&gt;7 &lt;Plug&gt;AirlineSelectTab7
nmap &lt;leader&gt;8 &lt;Plug&gt;AirlineSelectTab8
nmap &lt;leader&gt;9 &lt;Plug&gt;AirlineSelectTab9
&#34; let g:airline_skip_empty_sections = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#tabline#fnamemod = &#39;:t&#39;
&#34;&#34;let g:airline#extensions#syntastic#enabled = 0
let g:airline_detect_iminsert=1
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#tab_nr_type = 1 &#34; tab number
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#wordcount#enabled = 0
&#34;let g:airline_theme=&#39;base16&#39;
&#34; let g:airline_powerline_fonts = 1
let g:airline#extensions#tagbar#enabled = 1
&#34; END AIRLINE SETTINGS
let g:airline#extensions#tabline#show_tabs = 0

&#34; Nerd Tree--------------------------------------------------------------------
Plug &#39;scrooloose/nerdtree&#39;
Plug &#39;preservim/nerdcommenter&#39;
&#34; nerdtree 从当前文件目录打开
autocmd BufEnter * lcd %:p:h
&#34;如果想打开vim时自动打开NERDTree，可以如下设定
&#34; autocmd vimenter * NERDTree
&#34; 显示行号
let NERDTreeShowLineNumbers=1
let NERDTreeAutoCenter=1
&#34; 是否显示隐藏文件
&#34; 在终端启动vim时，共享NERDTree
let g:nerdtree_tabs_open_on_console_startup=1
&#34; 忽略以下文件的显示
let NERDTreeIgnore=[&#39;\.pyc&#39;,&#39;\~$&#39;,&#39;\.swp&#39;]
&#34; 显示书签列表
let NERDTreeShowBookmarks=1
&#34;NERDTree配置
let NERDChristmasTree=1 &#34;显示增强
let NERDTreeAutoCenter=1 &#34;自动调整焦点
let NERDTreeShowFiles=1 &#34;显示文件
let NERDTreeShowLineNumbers=1 &#34;显示行号
let NERDTreeHightCursorline=1 &#34;高亮当前文件
let NERDTreeShowHidden=1 &#34;显示隐藏文件
let NERDTreeMinimalUI=0 &#34;不显示&#39;Bookmarks&#39; label &#39;Press ? for help&#39;
let NERDTreeWinSize=30 &#34;窗口宽度
&#34; let NERDTreeQuitOnOpen = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
set autochdir
let NERDTreeChDirMode=2

&#34; File Icon -------------------------------------------------------------------
Plug &#39;ryanoasis/vim-devicons&#39;
&#34;Can be enabled or disabled
let g:webdevicons_enable_nerdtree = 1
&#34;whether or not to show the nerdtree brackets around flags
let g:webdevicons_conceal_nerdtree_brackets = 1
&#34;adding to vim-airline&#39;s tabline
let g:webdevicons_enable_airline_tabline = 1
&#34;adding to vim-airline&#39;s statusline
let g:webdevicons_enable_airline_statusline = 1

&#34; pair and indent -------------------------------------------------------------
Plug &#39;jiangmiao/auto-pairs&#39;
Plug &#39;Yggdroot/hiPairs&#39;
&#34;auto pair --------------------------------------------------------------------
&#34;设置要自动配对的符号
let g:AutoPairs={&#39;(&#39;:&#39;)&#39;, &#39;[&#39;:&#39;]&#39;, &#39;{&#39;:&#39;}&#39;,&#34;&#39;&#34;:&#34;&#39;&#34;,&#39;&#34;&#39;:&#39;&#34;&#39;, &#39;`&#39;:&#39;`&#39;}
&#34;let g:AutoPairs = {&#39;(&#39;:&#39;)&#39;, &#39;[&#39;:&#39;]&#39;, &#39;{&#39;:&#39;}&#39;,&#34;&#39;&#34;:&#34;&#39;&#34;,&#39;&#34;&#39;:&#39;&#34;&#39;}
&#34;添加要自动配对的符号 &lt;&gt;
&#34;let g:AutoPairs[&#39;&lt;&#39;]=&#39;&gt;&#39;
&#34;把 BACKSPACE 键映射为删除括号对和引号，默认为 1。
let g:AutoPairsMapBS = 1
&#34;当g:AutoPairsMapCR为 1 时，且文本位于窗口底部时，自动移到窗口中间
let g:AutoPairsCenterLine = 1
&#34; au Filetype markdown let b:AutoPairs={&#39;(&#39;:&#39;)&#39;, &#39;[&#39;:&#39;]&#39;, &#39;{&#39;:&#39;}&#39;,&#39;&#34;&#39;:&#39;&#34;&#39;, &#39;`&#39;:&#39;`&#39;}
let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutBackInsert = &#39;&lt;M-b&gt;&#39;

&#34;white space at end of line
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
autocmd BufWritePre * :%s/\s\&#43;$//e
let g:current_line_whitespace_disabled_soft=1
&#34; if confirm
let g:strip_whitespace_confirm=0
&#34;only modified line
let g:strip_only_modified_lines=1
&#34; white list
&#34; let g:better_whitespace_filetypes_blacklist=[&#39;&lt;filetype1&gt;&#39;, &#39;&lt;filetype2&gt;&#39;, &#39;&lt;etc&gt;&#39;]
nnoremap ]w :NextTrailingWhitespace&lt;CR&gt;
nnoremap [w :PrevTrailingWhitespace&lt;CR&gt;

&#34; pair and indent -------------------------------------------------------------
Plug &#39;nathanaelkane/vim-indent-guides&#39;
&#34; Plug &#39;lukas-reineke/indent-blankline.nvim&#39;

&#34; surround --------------------------------------------------------------------
Plug &#39;tpope/vim-surround&#39;
&#34; git
Plug &#39;tpope/vim-fugitive&#39;
&#34; git blame
nnoremap gb :Git blame&lt;CR&gt;&lt;CR&gt;
&#34; git log
nnoremap gl :Git log %&lt;CR&gt;&lt;CR&gt;

Plug &#39;airblade/vim-gitgutter&#39;
function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf(&#39;&#43;%d ~%d -%d&#39;, a, m, r)
endfunction
set statusline&#43;=%{GitStatus()}
let g:gitgutter_sign_added = &#39;&#43;&#39;
let g:gitgutter_sign_modified = &#39;^&#39;
let g:gitgutter_sign_removed = &#39;-&#39;
let g:gitgutter_sign_modified_removed = &#39;^-&#39;
highlight GitGutterAdd    ctermfg=blue
highlight GitGutterChange ctermfg=green
highlight GitGutterDelete ctermfg=red

Plug &#39;zivyangll/git-blame.vim&#39;
nnoremap &lt;Leader&gt;gg :&lt;C-u&gt;call gitblame#echo()&lt;CR&gt;

&#34; python3 ---------------------------------------------------------------------
Plug &#39;vim-python/python-syntax&#39;
let g:python_highlight_all = 1

&#34; interestingwords ------------------------------------------------------------
Plug &#39;lfv89/vim-interestingwords&#39;

&#34; cpp -------------------------------------------------------------------------
Plug &#39;octol/vim-cpp-enhanced-highlight&#39;, {&#39;for&#39;:&#39;cpp&#39;}
Plug &#39;bfrg/vim-cpp-modern&#39;, {&#39;for&#39;:&#39;cpp&#39;}
Plug &#39;derekwyatt/vim-fswitch&#39;, {&#39;for&#39;:[&#39;cpp&#39;,&#39;hpp&#39;]}
Plug &#39;Konfekt/FastFold&#39;

&#34; highlight Cpp
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
&#34; let g:cpp_experimental_simple_template_highlight = 1
&#34; let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 0

&#34; Disable function highlighting (affects both C and C&#43;&#43; files)
let g:cpp_no_function_highlight = 0
&#34; Enable highlighting of C&#43;&#43;11 attributes
let g:cpp_attributes_highlight = 1
&#34; Highlight struct/class member variables (affects both C and C&#43;&#43; files)
let g:cpp_member_highlight = 1
&#34; Put all standard C and C&#43;&#43; keywords under Vim&#39;s highlight group &#39;Statement&#39;
&#34; (affects both C and C&#43;&#43; files)
let g:cpp_simple_highlight = 1

&#34; LeaderF
Plug &#39;Yggdroot/LeaderF&#39;, { &#39;do&#39;: &#39;:LeaderfInstallCExtension&#39; }
Plug &#39;skywind3000/Leaderf-snippet&#39;
Plug &#39;ludovicchabant/vim-gutentags&#39;

&#34; Track the engine.
Plug &#39;SirVer/ultisnips&#39;
&#34; Snippets are separated from the engine. Add this if you want them:
Plug &#39;honza/vim-snippets&#39;

&#34; cursor
Plug &#39;mg979/vim-visual-multi&#39;, {&#39;branch&#39;: &#39;master&#39;}

&#34; fzf
Plug &#39;junegunn/fzf&#39;, { &#39;dir&#39;: &#39;~/.fzf&#39;, &#39;do&#39;: &#39;./install --all&#39;  }
Plug &#39;junegunn/fzf.vim&#39;
Plug &#39;yuki-yano/fzf-preview.vim&#39;, { &#39;branch&#39;: &#39;release/rpc&#39; }

&#34; misc
Plug &#39;skywind3000/asyncrun.vim&#39;
Plug &#39;skywind3000/vim-quickui&#39;
&#34; Plug &#39;powerline/powerline-fonts&#39;

&#34; REPL
Plug &#39;sillybun/vim-repl&#39;, { &#39;for&#39;: [&#39;python&#39;, &#39;r&#39;], &#39;on&#39;:&#39;REPLToggle&#39; }

call plug#end()
&#34;&#34;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;

&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;&#34; General
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
set encoding=UTF-8
set fileencodings=ucs-bom,utf-8,chinese
set nocompatible              &#34; 去除VI一致性,必须要添加
set autoread
&#34;filetype off                  &#34; 必须要添加
&#34; 让配置变更立即生效
autocmd BufWritePost $MYVIMRC source $MYVIMRC
autocmd! bufwritepost .vimrc source %

&#34; Backups ---------------------------------------------------------------------
set nobackup               &#34; do not keep backups after close
set nowritebackup          &#34; do not keep a backup while working
set noswapfile             &#34; don&#39;t keep swp files either
set backupdir=~/.vim/backup &#34; store backups under ~/.vim/backup
set backupcopy=yes         &#34; keep attributes of original file
set backupskip=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
set directory=~/.vim/swap,~/tmp,. &#34; keep swp files under ~/.vim/swap


&#34; color theme -----------------------------------------------------------------
syntax on
colorscheme everforest
set background=dark     &#34; For dark-mode version.
&#34; set background=light  &#34; For light-mode version.

&#34; basic config
set backspace=indent,eol,start      &#34; better backspace
filetype plugin on                  &#34; load filetype-specific plugin
filetype indent on                  &#34; load filetype-specific indent files
set wildmenu                        &#34; visual autocomplete for command menu
set lazyredraw                      &#34; redraw only when we need to.
set softtabstop=4                   &#34; number of spaces in tab when editing
set shiftwidth=4                    &#34; 4 space
set tabstop=4                       &#34; tab as 4 space
set expandtab                       &#34; tabs are spaces

&#34; indent-guides settings ------------------------------------------------------
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=237
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=237
let g:indent_guides_start_level=1
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_exclude_filetypes = [&#39;markdown&#39;, &#39;html.mustache&#39;, &#39;help&#39;]&#34;


&#34;&#34; Folding-related -----------------------------------------------------------
&#34;hi Folded  term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=DarkGrey
set foldenable              &#34; 开始折叠
set foldmethod=syntax       &#34; 设置语法折叠
set foldcolumn=0            &#34; 设置折叠区域的宽度
&#34;setlocal foldlevel=1        &#34; 设置折叠层数为
&#34;set foldlevelstart=99       &#34; 打开文件是默认不折叠代码

&#34;set foldclose=all          &#34; 设置为自动关闭折叠
&#34; 用空格键来开关折叠
nnoremap &lt;space&gt; @=((foldclosed(line(&#39;.&#39;)) &lt; 0) ? &#39;zc&#39;:&#39;zo&#39;)&lt;CR&gt;

&#34;&#34; for python file
&#34;&#34; textwidth=80表示一行最多80个字符，
&#34;&#34; autoindent表示程序自动缩进，
&#34;&#34; fileformat=unix表示按照unix的文件格式存储。
au BufNewFile,BufRead *.py,
    \ set tabstop=4         |
    \ set softtabstop=4     |
    \ set shiftwidth=4      |
    \ set expandtab         |
    \ set autoindent        |
    \ set fileformat=unix   |
    \ set foldmethod=indent

&#34;&#34; visual-related -------------------------------------------------------
set showmatch                       &#34; highlight matching [{()}]
set incsearch                       &#34; search as characters are entered
set hlsearch                        &#34; highlight matches
set selection=exclusive             &#34; visual delete 不包含下一个字符
nnoremap ,&lt;space&gt; :nohlsearch&lt;CR&gt;   &#34; ,&lt;space&gt; to close search hilight
&#34;Press Space to turn off highlighting and clear any message already displayed.
&#34; nnoremap &lt;silent&gt; &lt;Space&gt; :nohlsearch&lt;Bar&gt;:echo&lt;CR&gt;
let loaded_matchparen=1    &#34; don&#39;t hightlight matching brackets/braces
set laststatus=2           &#34; always show the status line
set incsearch              &#34; highlight search text as entered
set ignorecase             &#34; ignore case when searching
set smartcase              &#34; case sensitive only if capitals in search term
&#34;set colorcolumn=80        &#34; not available until Vim 7.3
set visualbell             &#34; shut the fuck up
set showcmd
set novisualbell
&#34;&#34;高亮搜索
&#34;hi Search cterm=NONE ctermfg=51 ctermbg=24
&#34;hi Visual cterm=bold ctermfg=141 ctermbg=61


&#34;&#34; line-related ---------------------------------------------------------------
set number                          &#34; line number on left
set relativenumber                  &#34; show relative line number
set cursorline                      &#34; highlight current line
&#34; set nowrap                          &#34; 不要折行&#34;
nmap &lt;Leader&gt;v 0                    &#34; nmap LB 0
nmap &lt;Leader&gt;e $                    &#34; nmap LE $

set colorcolumn=80,120,140          &#34; columns:80,100,120
let s:color_column_old = 0
function! s:ToggleColorColumn()
    if s:color_column_old == 0
        let s:color_column_old = &amp;colorcolumn
        &#34;windo let &amp;colorcolumn = 0
        set colorcolumn=0
    else
        &#34;windo let &amp;colorcolumn=s:color_column_old
        let &amp;colorcolumn=s:color_column_old
        let s:color_column_old = 0
    endif
endfunction

&#34; sidescroll: {0: 一次扩展半屏, 1: 续字符扩展(更流畅)}
set sidescroll=1
&#34; 折行时，使 j/k 可以在折行内上下移动(而不是一次跳掉整行)
noremap &lt;slient&gt; &lt;expr&gt; j (v:count == 0 ? &#39;gj&#39; : &#39;j&#39;)
noremap &lt;slient&gt; &lt;expr&gt; k (v:count == 0 ? &#39;gk&#39; : &#39;k&#39;)

&#34; NERDCommenter
&#34; Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = &#39;left&#39;
&#34; Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
&#34; Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
&#34; Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1
nmap &lt;Leader&gt;c &lt;Plug&gt;NERDCommenterToggle&lt;CR&gt;
vmap &lt;Leader&gt;c &lt;Plug&gt;NERDCommenterToggle&lt;CR&gt;

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
&#34; highlight clear CursorLine
&#34; highlight CursorLine   cterm=NONE ctermbg=black ctermfg=none guibg=NONE guifg=NONE
&#34; highlight CursorColumn cterm=NONE ctermbg=black ctermfg=none guibg=NONE guifg=NONE

&#34;highlight LineNr term=bold cterm=bold ctermfg=DarkGrey ctermbg=NONE gui=None guifg=DarkGrey guibg=NONE
&#34;highlight CursorLineNR term=bold ctermfg=DarkGreen ctermbg=black cterm=bold
set linebreak              &#34; wrap long lines between words
&#34;&#34; =========================================================


&#34; buffer-related --------------------------------------------------------------
&#34; nnoremap &lt;leader&gt;bp :bp&lt;CR&gt;
&#34; nnoremap &lt;leader&gt;bn :bn&lt;CR&gt;
&#34; nnoremap &lt;leader&gt;db :bd&lt;CR&gt;
nnoremap bp :bp&lt;CR&gt;
nnoremap bn :bn&lt;CR&gt;
nnoremap bd :bd&lt;CR&gt;

&#34;let g:interestingWordsDefaultMappings = 0
&#34; file-releted operation ------------------------------------------------------
vnoremap &lt;Leader&gt;y &#34;&#43;y              &#34; 设置快捷键将选中文本块复制至系统剪贴板
nmap &lt;Leader&gt;p &#34;&#43;p                  &#34; 设置快捷键将系统剪贴板内容粘贴至 vim
nmap &lt;Leader&gt;q :q&lt;CR&gt;               &#34; 定义快捷键关闭当前分割窗口
nmap &lt;Leader&gt;w :w&lt;CR&gt;               &#34; 定义快捷键保存当前窗口内容 vim:save and quit
nmap &lt;Leader&gt;wq :wa&lt;CR&gt;:q&lt;CR&gt;       &#34; 定义快捷键保存所有窗口内容并退出

&#34;&#34; Window-releted ------------------------------------------------------------
&#34; 依次遍历子窗口
nnoremap nw &lt;C-W&gt;&lt;C-W&gt;
&#34; 跳转至右方的窗口
nnoremap &lt;Leader&gt;l &lt;C-W&gt;l
&#34; 跳转至左方的窗口
nnoremap &lt;Leader&gt;h &lt;C-W&gt;h
&#34; 跳转至上方的子窗口
nnoremap &lt;Leader&gt;k &lt;C-W&gt;k
nmap &lt;Leader&gt;k &lt;C-W&gt;k
&#34; 跳转至下方的子窗口
nnoremap &lt;Leader&gt;j &lt;C-W&gt;j
&#34; 定义快捷键在结对符之间跳转
nmap &lt;Leader&gt;M %

&#34; nnoremap &lt;silent&gt; &lt;Leader&gt;&#43; :exe &#34;vertical resize &#34; . (winwidth(0) * 3/2)&lt;CR&gt;
&#34; nnoremap &lt;silent&gt; &lt;Leader&gt;= :exe &#34;vertical resize &#34; . (winwidth(0) * 3/2)&lt;CR&gt;
&#34; nnoremap &lt;silent&gt; &lt;Leader&gt;- :exe &#34;vertical resize &#34; . (winwidth(0) * 2/3)&lt;CR&gt;
nnoremap &lt;silent&gt; &lt;Leader&gt;= :exe &#34;vertical resize &#43;5&#34;&lt;CR&gt;
nnoremap &lt;silent&gt; &lt;Leader&gt;- :exe &#34;vertical resize -5&#34;&lt;CR&gt;


&#34; Window-releted
&#34;max window
function! Zoom ()
    &#34; check if is the zoomed state (tabnumber &gt; 1 &amp;&amp; window == 1)
    if tabpagenr(&#39;$&#39;) &gt; 1 &amp;&amp; tabpagewinnr(tabpagenr(), &#39;$&#39;) == 1
        let l:cur_winview = winsaveview()
        let l:cur_bufname = bufname(&#39;&#39;)
        tabclose

        &#34; restore the view
        if l:cur_bufname == bufname(&#39;&#39;)
            call winrestview(cur_winview)
        endif
    else
        tab split
    endif
endfunction
nmap &lt;leader&gt;z :call Zoom()&lt;CR&gt;

&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;

&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;&#34; Coc
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;&#34; extensions
let g:coc_global_extensions = [&#39;coc-tsserver&#39;, &#39;coc-json&#39;, &#39;coc-yaml&#39;,
    \ &#39;coc-clangd&#39;, &#39;coc-pyright&#39;, &#39;coc-jedi&#39;,
    \ &#39;coc-html&#39;, &#39;coc-css&#39;, &#39;coc-xml&#39;,
    \ &#39;coc-emmet&#39;, &#39;coc-snippets&#39;,
    \ &#39;coc-markdownlint&#39;, &#39;coc-highlight&#39;]
&#34;&#34; color
&#34;hi CocMenuSel ctermbg=237 guibg=#13354A

&#34; if hidden is not set, TextEdit might fail.
set hidden

&#34; Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

&#34; Better display for messages
&#34; 最下端显示的宽度，默认是 2，为了简洁页面，我设置成 1
set cmdheight=1

&#34; You will have bad experience for diagnostic messages when it&#39;s default 4000.
set updatetime=300

&#34; don&#39;t give |ins-completion-menu| messages.
set shortmess&#43;=c

&#34; always show signcolumns
set signcolumn=yes

function! CheckBackspace() abort
  let col = col(&#39;.&#39;) - 1
  return !col || getline(&#39;.&#39;)[col - 1]  =~# &#39;\s&#39;
endfunction
&#34; Use tab for trigger completion with characters ahead and navigate
&#34; NOTE: There&#39;s always complete item selected by default, you may want to enable
&#34; no select by `&#34;suggest.noselect&#34;: true` in your configuration file
&#34; NOTE: Use command &#39;:verbose imap &lt;tab&gt;&#39; to make sure tab is not mapped by
&#34; other plugin before putting this into your config
inoremap &lt;silent&gt;&lt;expr&gt; &lt;TAB&gt;
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? &#34;\&lt;Tab&gt;&#34; :
      \ coc#refresh()
inoremap &lt;expr&gt;&lt;S-TAB&gt; coc#pum#visible() ? coc#pum#prev(1) : &#34;\&lt;C-h&gt;&#34;

&#34; Make &lt;CR&gt; to accept selected completion item or notify coc.nvim to format
&#34; &lt;C-g&gt;u breaks current undo, please make your own choice
inoremap &lt;silent&gt;&lt;expr&gt; &lt;CR&gt; coc#pum#visible() ? coc#pum#confirm()
                             \: &#34;\&lt;C-g&gt;u\&lt;CR&gt;\&lt;c-r&gt;=coc#on_enter()\&lt;CR&gt;&#34;
&#34; Use &lt;c-space&gt; to trigger completion.
inoremap &lt;silent&gt;&lt;expr&gt; &lt;c-space&gt; coc#refresh()

&#34; Use `[g` and `]g` to navigate diagnostics
nmap &lt;silent&gt; [g &lt;Plug&gt;(coc-diagnostic-prev)
nmap &lt;silent&gt; ]g &lt;Plug&gt;(coc-diagnostic-next)

&#34; Remap keys for gotos
nmap &lt;silent&gt; gd &lt;Plug&gt;(coc-definition)
nmap &lt;silent&gt; gy &lt;Plug&gt;(coc-type-definition)
nmap &lt;silent&gt; gi &lt;Plug&gt;(coc-implementation)
nmap &lt;silent&gt; gr &lt;Plug&gt;(coc-references)

&#34; Use K to show documentation in preview window
nnoremap &lt;silent&gt; K :call &lt;SID&gt;show_documentation()&lt;CR&gt;

function! s:show_documentation()
  if (index([&#39;vim&#39;,&#39;help&#39;], &amp;filetype) &gt;= 0)
    execute &#39;h &#39;.expand(&#39;&lt;cword&gt;&#39;)
  else
    call CocAction(&#39;doHover&#39;)
  endif
endfunction

&#34; Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync(&#39;highlight&#39;)

&#34; Remap for rename current word
nmap &lt;leader&gt;rn &lt;Plug&gt;(coc-rename)

&#34; Remap for format selected region
xmap &lt;leader&gt;fm  &lt;Plug&gt;(coc-format-selected)
nmap &lt;leader&gt;fm  &lt;Plug&gt;(coc-format-selected)

augroup mygroup
  autocmd!
  &#34; Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction(&#39;formatSelected&#39;)
  &#34; Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync(&#39;showSignatureHelp&#39;)
augroup end

&#34; Remap for do codeAction of selected region, ex: `&lt;leader&gt;aap` for current paragraph
xmap &lt;leader&gt;a  &lt;Plug&gt;(coc-codeaction-selected)
nmap &lt;leader&gt;a  &lt;Plug&gt;(coc-codeaction-selected)

&#34; Remap for do codeAction of current line
nmap &lt;leader&gt;ac  &lt;Plug&gt;(coc-codeaction)
&#34; Fix autofix problem of current line
nmap &lt;leader&gt;qf  &lt;Plug&gt;(coc-fix-current)

&#34; Create mappings for function text object, requires document symbols feature of languageserver.
xmap if &lt;Plug&gt;(coc-funcobj-i)
xmap af &lt;Plug&gt;(coc-funcobj-a)
omap if &lt;Plug&gt;(coc-funcobj-i)
omap af &lt;Plug&gt;(coc-funcobj-a)

&#34; Use &lt;C-d&gt; for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap &lt;silent&gt; &lt;C-d&gt; &lt;Plug&gt;(coc-range-select)
xmap &lt;silent&gt; &lt;C-d&gt; &lt;Plug&gt;(coc-range-select)

&#34; Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction(&#39;format&#39;)

&#34; Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction(&#39;fold&#39;, &lt;f-args&gt;)

&#34; use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction(&#39;runCommand&#39;, &#39;editor.action.organizeImport&#39;)

&#34; Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,&#39;coc_current_function&#39;,&#39;&#39;)}

&#34; &#34; Using CocList
&#34; &#34; Show all diagnostics
&#34; nnoremap &lt;silent&gt; &lt;space&gt;a  :&lt;C-u&gt;CocList diagnostics&lt;cr&gt;
&#34; &#34; Manage extensions
&#34; nnoremap &lt;silent&gt; &lt;space&gt;e  :&lt;C-u&gt;CocList extensions&lt;cr&gt;
&#34; &#34; Show commands
&#34; nnoremap &lt;silent&gt; &lt;space&gt;c  :&lt;C-u&gt;CocList commands&lt;cr&gt;
&#34; &#34; Find symbol of current document
&#34; nnoremap &lt;silent&gt; &lt;space&gt;o  :&lt;C-u&gt;CocList outline&lt;cr&gt;
&#34; &#34; Search workspace symbols
&#34; nnoremap &lt;silent&gt; &lt;space&gt;s  :&lt;C-u&gt;CocList -I symbols&lt;cr&gt;
&#34; &#34; Do default action for next item.
&#34; nnoremap &lt;silent&gt; &lt;space&gt;j  :&lt;C-u&gt;CocNext&lt;CR&gt;
&#34; &#34; Do default action for previous item.
&#34; nnoremap &lt;silent&gt; &lt;space&gt;k  :&lt;C-u&gt;CocPrev&lt;CR&gt;
&#34; &#34; Resume latest coc list
&#34; nnoremap &lt;silent&gt; &lt;space&gt;p  :&lt;C-u&gt;CocListResume&lt;CR&gt;

&#34;&#34; Use &lt;Ctrl-p&gt; to format documents with prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile
noremap &lt;C-p&gt; :Prettier&lt;CR&gt;

nmap &lt;silent&gt; &lt;C-LeftMouse&gt; &lt;LeftMouse&gt;&lt;Plug&gt;(coc-definition)
&#34; 查阅光标所在单词的信息并弹窗展示，如类型、关联注释等
nnoremap &lt;Leader&gt;k :call CocActionAsync(&#39;doHover&#39;)&lt;CR&gt;
&#34; 执行代码格式化
nnoremap &lt;Leader&gt;F :call CocActionAsync(&#39;format&#39;)&lt;CR&gt;
&#34; 查询函数静态调用树的入节点、出节点
nnoremap &lt;Leader&gt;i :CocCommand document.showIncomingCalls&lt;CR&gt;
nnoremap &lt;Leader&gt;o :CocCommand document.showOutgoingCalls&lt;CR&gt;
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;

&#34; interestingwords ------------------------------------------------------------
&#34;&#34; highlight keywords
let g:interestingWordsGUIColors = [&#39;#8CCBEA&#39;,&#39;#A4E57E&#39;,&#39;#FFDB72&#39;,&#39;#FF7272&#39;,
        \ &#39;#FFB3FF&#39;,&#39;#9999FF&#39;,&#39;#6F69AC&#39;,&#39;$95DAC1&#39;,&#39;#008700&#39;,&#39;#00af5f&#39;,
        \ &#39;#00d787&#39;,&#39;#0087af&#39;,&#39;#00d7af&#39;,&#39;#0087d7&#39;,&#39;#00d7d7&#39;,&#39;#0087ff&#39;,
        \ &#39;#5f8700&#39;,&#39;#5faf5f&#39;,&#39;#87875f&#39;,&#39;#8787af&#39;,&#39;#af875f&#39;,&#39;#d75f00&#39;,&#39;#d7af5f&#39;]
let g:interestingWordsTermColors = [&#39;154&#39;,&#39;121&#39;,&#39;211&#39;,&#39;137&#39;,&#39;214&#39;,&#39;222&#39;,
        \ &#39;172&#39;,&#39;201&#39;,&#39;28&#39;,&#39;35&#39;,&#39;42&#39;,&#39;31&#39;,&#39;43&#39;,&#39;32&#39;,&#39;44&#39;,&#39;33&#39;,&#39;64&#39;,
        \ &#39;71&#39;,&#39;101&#39;,&#39;103&#39;,&#39;137&#39;,&#39;166&#39;,&#39;179&#39;]
let g:interestingWordsRandomiseColors = 1
let g:interestingWordsDefaultMappings = 0
nnoremap &lt;silent&gt; &lt;leader&gt;x :call InterestingWords(&#39;n&#39;)&lt;cr&gt;
vnoremap &lt;silent&gt; &lt;leader&gt;x :call InterestingWords(&#39;v&#39;)&lt;cr&gt;
nnoremap &lt;silent&gt; &lt;leader&gt;X :call UncolorAllWords()&lt;cr&gt;
nnoremap &lt;silent&gt; n :call WordNavigation(1)&lt;cr&gt;
nnoremap &lt;silent&gt; N :call WordNavigation(0)&lt;cr&gt;

&#34; cpp/hpp file switch ---------------------------------------------------------
&#34; *.cpp 和 *.h 间切换
nmap &lt;silent&gt; &lt;Leader&gt;sw :FSHere&lt;cr&gt;

&#34; hiPairs --------------------------------------------------------------------
let g:matchup_matchparen_offscreen = {&#39;method&#39;: &#39;popup&#39;}
let g:hiPairs_hl_matchPair = { &#39;term&#39;    : &#39;underline,bold&#39;,
            \                  &#39;cterm&#39;   : &#39;bold&#39;,
            \                  &#39;ctermfg&#39; : &#39;0&#39;,
            \                  &#39;ctermbg&#39; : &#39;180&#39;,
            \                  &#39;gui&#39;     : &#39;bold&#39;,
            \                  &#39;guifg&#39;   : &#39;Black&#39;,
            \                  &#39;guibg&#39;   : &#39;#D3B17D&#39; }
let g:hiPairs_hl_unmatchPair = { &#39;term&#39;    : &#39;underline,italic&#39;,
            \                    &#39;cterm&#39;   : &#39;italic&#39;,
            \                    &#39;ctermfg&#39; : &#39;15&#39;,
            \                    &#39;ctermbg&#39; : &#39;12&#39;,
            \                    &#39;gui&#39;     : &#39;italic&#39;,
            \                    &#39;guifg&#39;   : &#39;White&#39;,
            \                    &#39;guibg&#39;   : &#39;Red&#39; }

&#34;Leaderf ----------------------------------------------------------------------
let g:Lf_ShortcutF = &#39;&lt;Leader&gt;&lt;Leader&gt;f&#39;
let g:Lf_WorkingDirectoryMode = &#39;AF&#39;
let g:Lf_RootMarkers = [&#39;.git&#39;, &#39;.svn&#39;, &#39;.hg&#39;, &#39;.project&#39;, &#39;.root&#39;]
let g:Lf_WindowPosition = &#39;popup&#39;
&#34; Default fzf layout
&#34; - down / up / left / right
let g:fzf_layout = { &#39;down&#39;: &#39;~40%&#39; }
&#34; Customize fzf colors to match your color scheme
let g:fzf_colors =
            \ { &#39;fg&#39;:      [&#39;fg&#39;, &#39;Normal&#39;],
            \ &#39;bg&#39;:      [&#39;bg&#39;, &#39;Normal&#39;],
            \ &#39;hl&#39;:      [&#39;fg&#39;, &#39;Comment&#39;],
            \ &#39;fg&#43;&#39;:     [&#39;fg&#39;, &#39;CursorLine&#39;, &#39;CursorColumn&#39;, &#39;Normal&#39;],
            \ &#39;bg&#43;&#39;:     [&#39;bg&#39;, &#39;CursorLine&#39;, &#39;CursorColumn&#39;],
            \ &#39;hl&#43;&#39;:     [&#39;fg&#39;, &#39;Statement&#39;],
            \ &#39;info&#39;:    [&#39;fg&#39;, &#39;PreProc&#39;],
            \ &#39;prompt&#39;:  [&#39;fg&#39;, &#39;Conditional&#39;],
            \ &#39;pointer&#39;: [&#39;fg&#39;, &#39;Exception&#39;],
            \ &#39;marker&#39;:  [&#39;fg&#39;, &#39;Keyword&#39;],
            \ &#39;spinner&#39;: [&#39;fg&#39;, &#39;Label&#39;],
            \ &#39;header&#39;:  [&#39;fg&#39;, &#39;Comment&#39;] }
&#34; don&#39;t show the help in normal mode
let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
&#34; popup mode
let g:Lf_PreviewInPopup = 1
let g:Lf_StlSeparator = { &#39;left&#39;: &#34;\ue0b0&#34;, &#39;right&#39;: &#34;\ue0b2&#34;, &#39;font&#39;: &#34;DejaVu Sans Mono for Powerline&#34; }
let g:Lf_PreviewResult = {&#39;Function&#39;: 1, &#39;BufTag&#39;: 1 }
let g:Lf_CommandMap = {&#39;&lt;C-K&gt;&#39;: [&#39;&lt;Up&gt;&#39;], &#39;&lt;C-j&gt;&#39;: [&#39;&lt;Down&gt;&#39;]}
let g:Lf_WindowHeight = 0.30
let g:Lf_StlColorscheme = &#39;powerline&#39;
let g:Lf_PreviewResult = {
        \ &#39;File&#39;: 0,
        \ &#39;Buffer&#39;: 0,
        \ &#39;Mru&#39;: 0,
        \ &#39;Tag&#39;: 0,
        \ &#39;BufTag&#39;: 1,
        \ &#39;Function&#39;: 1,
        \ &#39;Line&#39;: 1,
        \ &#39;Colorscheme&#39;: 0,
        \ &#39;Rg&#39;: 0,
        \ &#39;Gtags&#39;: 0
        \}

&#34;&lt;C-J&gt;, &lt;C-K&gt; : navigate the result list.
noremap &lt;leader&gt;f :LeaderfSelf&lt;cr&gt;
&#34; all buffers
noremap &lt;leader&gt;fb :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf buffer %s&#34;, &#34;&#34;)&lt;CR&gt;&lt;CR&gt;
&#34; most recently used
noremap &lt;leader&gt;fm :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf mru %s&#34;, &#34;&#34;)&lt;CR&gt;&lt;CR&gt;
noremap &lt;leader&gt;fn :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf function %s&#34;, &#34;&#34;)&lt;CR&gt;&lt;CR&gt;
noremap &lt;leader&gt;ft :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf bufTag %s&#34;, &#34;&#34;)&lt;CR&gt;&lt;CR&gt;
noremap &lt;leader&gt;fl :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf line %s&#34;, &#34;&#34;)&lt;CR&gt;&lt;CR&gt;

&#34;command! -bang -nargs=* Ag
  &#34;\ call fzf#vim#grep(
  &#34;\   &#39;ag --column --numbers --noheading --color --smart-case &#39;.shellescape(&lt;q-args&gt;), 1,
  &#34;\   fzf#vim#with_preview(), &lt;bang&gt;0)
command! -bang -nargs=* Ag
    \ call fzf#vim#ag(&lt;q-args&gt;,
    \                 &lt;bang&gt;0 ? fzf#vim#with_preview(&#39;up:60%&#39;)
    \                         : fzf#vim#with_preview(&#39;right:50%:hidden&#39;, &#39;?&#39;),
    \                 &lt;bang&gt;0)
&#34;ag
map &lt;Leader&gt;ag :Ag
&#34; ag current word
map &lt;Leader&gt;aw :Ag &lt;C-R&gt;&lt;C-W&gt;&lt;CR&gt;

&#34; fzf
noremap &lt;C-B&gt; :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf! rg --current-buffer -e %s &#34;, expand(&#34;&lt;cword&gt;&#34;))&lt;CR&gt;
noremap &lt;C-F&gt; :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf! rg -e %s &#34;, expand(&#34;&lt;cword&gt;&#34;))&lt;CR&gt;
&#34; search visually selected text literally
xnoremap gf :&lt;C-U&gt;&lt;C-R&gt;=printf(&#34;Leaderf! rg -F -e %s &#34;, leaderf#Rg#visual())&lt;CR&gt;
noremap go :&lt;C-U&gt;Leaderf! rg --recall&lt;CR&gt;

&#34; should use `Leaderf gtags --update` first
let g:Lf_GtagsAutoGenerate = 0
let g:Lf_GtagsGutentags = 1
let g:Lf_Gtagslabel = &#39;native-pygments&#39;

&#34; fzf -------------------------------------------------------------------------
&#34; This is the default option:
&#34;   - Preview window on the right with 50% width
&#34;   - CTRL-/ will toggle preview window.
&#34; - Note that this array is passed as arguments to fzf#vim#with_preview function.
&#34; - To learn more about preview window options, see `--preview-window` section of `man fzf`.
let g:fzf_preview_window = [&#39;right:50%&#39;, &#39;ctrl-/&#39;]
&#34; Preview window on the upper side of the window with 40% height,
&#34; hidden by default, ctrl-/ to toggle
let g:fzf_preview_window = [&#39;up:40%:hidden&#39;, &#39;ctrl-/&#39;]
&#34; Empty value to disable preview window altogether
let g:fzf_preview_window = []
&#34; [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
&#34; [[B]Commits] Customize the options used by &#39;git log&#39;:
let g:fzf_commits_log_options = &#39;--graph --color=always --format=&#34;%C(auto)%h%d %s %C(black)%C(bold)%cr&#34;&#39;
&#34; [Tags] Command to generate tags file
let g:fzf_tags_command = &#39;ctags -R&#39;
&#34; [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = &#39;alt-enter,ctrl-x&#39;
&#34; Mapping selecting mappings
nmap &lt;leader&gt;&lt;tab&gt; &lt;plug&gt;(fzf-maps-n)
xmap &lt;leader&gt;&lt;tab&gt; &lt;plug&gt;(fzf-maps-x)
omap &lt;leader&gt;&lt;tab&gt; &lt;plug&gt;(fzf-maps-o)
nmap &lt;C-f&gt; :Files&lt;CR&gt;
nmap &lt;C-b&gt; :Buffers&lt;CR&gt;
nmap &lt;leader&gt;ff :Files&lt;CR&gt;
let g:fzf_action = {&#39;ctrl-e&#39;:&#39;edit&#39;, &#34;ctrl-t&#34;:&#34;tab split&#34;, &#34;ctrl-s&#34;: &#34;split&#34;, &#34;ctrl-v&#34;: &#34;vsplit&#34;}

&#34; Insert mode completion
imap &lt;c-x&gt;&lt;c-k&gt; &lt;plug&gt;(fzf-complete-word)
imap &lt;c-x&gt;&lt;c-f&gt; &lt;plug&gt;(fzf-complete-path)
imap &lt;c-x&gt;&lt;c-l&gt; &lt;plug&gt;(fzf-complete-line)


&#34; quickui ---------------------------------------------------------------------
&#34;==============================================================================
&#34;vim-quickui
&#34; clear all the menus
call quickui#menu#reset()
let g:quickui_color_scheme = &#39;gruvbox&#39;

&#34; install a &#39;File&#39; menu, use [text, command] to represent an item.
call quickui#menu#install(&#39;&amp;File&#39;, [
            \ [ &#34;&amp;New File\tCtrl&#43;n&#34;, &#39;echo 0&#39; ],
            \ [ &#34;&amp;Open File\t(F3)&#34;, &#39;echo 1&#39; ],
            \ [ &#34;&amp;Close&#34;, &#39;echo 2&#39; ],
            \ [ &#34;--&#34;, &#39;&#39; ],
            \ [ &#34;&amp;Save\tCtrl&#43;s&#34;, &#39;echo 3&#39;],
            \ [ &#34;Save &amp;As&#34;, &#39;echo 4&#39; ],
            \ [ &#34;Save All&#34;, &#39;echo 5&#39; ],
            \ [ &#34;--&#34;, &#39;&#39; ],
            \ [ &#34;E&amp;xit\tAlt&#43;x&#34;, &#39;echo 6&#39; ],
            \ ])

&#34; items containing tips, tips will display in the cmdline
call quickui#menu#install(&#39;&amp;Edit&#39;, [
            \ [ &#39;&amp;Copy&#39;, &#39;echo 1&#39;, &#39;help 1&#39; ],
            \ [ &#39;&amp;Paste&#39;, &#39;echo 2&#39;, &#39;help 2&#39; ],
            \ [ &#39;&amp;Find&#39;, &#39;echo 3&#39;, &#39;help 3&#39; ],
            \ ])

&#34; script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install(&#34;&amp;Option&#34;, [
            \ [&#39;Set &amp;Spell %{&amp;spell? &#34;Off&#34;:&#34;On&#34;}&#39;, &#39;set spell!&#39;],
            \ [&#39;Set &amp;Cursor Line %{&amp;cursorline? &#34;Off&#34;:&#34;On&#34;}&#39;, &#39;set cursorline!&#39;],
            \ [&#39;Set &amp;Paste %{&amp;paste? &#34;Off&#34;:&#34;On&#34;}&#39;, &#39;set paste!&#39;],
            \ ])

&#34; register HELP menu with weight 10000
call quickui#menu#install(&#39;H&amp;elp&#39;, [
            \ [&#34;&amp;Cheatsheet&#34;, &#39;help index&#39;, &#39;&#39;],
            \ [&#39;T&amp;ips&#39;, &#39;help tips&#39;, &#39;&#39;],
            \ [&#39;--&#39;,&#39;&#39;],
            \ [&#34;&amp;Tutorial&#34;, &#39;help tutor&#39;, &#39;&#39;],
            \ [&#39;&amp;Quick Reference&#39;, &#39;help quickref&#39;, &#39;&#39;],
            \ [&#39;&amp;Summary&#39;, &#39;help summary&#39;, &#39;&#39;],
            \ ], 10000)

call quickui#menu#install(&#39;&amp;C/C&#43;&#43;&#39;, [
            \ [ &#39;&amp;Compile&#39;, &#39;echo 1&#39; ],
            \ [ &#39;&amp;Run&#39;, &#39;echo 2&#39; ],
            \ ], &#39;&lt;auto&gt;&#39;, &#39;c,cpp&#39;)

&#34; enable to display tips in the cmdline
let g:quickui_show_tip = 1

&#34; hit space twice to open menu
noremap &lt;Leader&gt;&lt;Leader&gt;m :call quickui#menu#open()&lt;cr&gt;

function! TermExit(code)
    echom &#34;terminal exit code: &#34;. a:code
endfunc

let opts = {&#39;w&#39;:120, &#39;h&#39;:20,  &#39;col&#39;:30, &#39;line&#39;:10, &#39;callback&#39;:&#39;TermExit&#39;}
let opts.title = &#39;Terminal Popup&#39;
&#34;打开终端
nnoremap &lt;Leader&gt;&lt;Leader&gt;t :call quickui#terminal#open(&#39;zsh&#39;, opts)&lt;cr&gt;
&#34;切换buffer
&#34;Then hjkl to navigate, enter/space to switch buffer and ESC/CTRL&#43;[ to quit: ]
&#34;If there are many buffers listed, you can use / or ? to search, and n or N to jump to the next / previous match.
&#34;Usage:
&#34;
&#34;- j/k: navigate.
&#34;- ESC/CTRL&#43;[: quit
&#34;- Enter: open with switchbuf rules (override with g:quickui_switch_enter).
&#34;- Space: open with switchbuf rules (override with g:quickui_switch_space).
&#34;- CTRL&#43;e: edit in current window.
&#34;- CTRL&#43;x: open in a new split.
&#34;- CTRL&#43;]: open in a new vertical split.
&#34;- CTRL&#43;t: open in a new tab.
&#34;- CTRL&#43;g: open with :drop command.
&#34;- /: search.
&#34;- ?: search backwards.
nnoremap &lt;Leader&gt;&lt;Leader&gt;b :call quickui#tools#list_buffer(&#39;e&#39;)&lt;cr&gt;
&#34;function list
&#34; nnoremap &lt;space&gt;&lt;space&gt;f :call quickui#tools#list_function()&lt;cr&gt;

&#34; Vim-repl -------------------------------------------------------------------
&#34; let g:repl_program = {
&#34;             \   &#39;python&#39;: &#39;ipython&#39;,
&#34;             \   &#39;default&#39;: &#39;bash&#39;,
&#34;             \   &#39;r&#39;: &#39;R&#39;,
&#34;             \   &#39;lua&#39;: &#39;lua&#39;,
&#34;             \   }
let g:repl_program = {
            \   &#39;python&#39;: &#39;zsh&#39;,
            \   &#39;default&#39;: &#39;zsh&#39;,
            \   &#39;r&#39;: &#39;R&#39;,
            \   &#39;lua&#39;: &#39;lua&#39;,
            \   }
let g:repl_width = 120 &#34;REPL windows width&#34;
let g:repl_predefine_python = {
            \   &#39;numpy&#39;: &#39;import numpy as np&#39;,
            \   &#39;matplotlib&#39;: &#39;from matplotlib import pyplot as plt&#39;
            \   }
let g:repl_python_auto_import = 1
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = &#39;7&#39;
&#34; nnoremap &lt;leader&gt;t :REPLToggle&lt;Cr&gt;
nnoremap &lt;leader&gt;t :REPLToggle&lt;Cr&gt;
&#34; autocmd Filetype python nnoremap &lt;F12&gt; &lt;Esc&gt;:REPLDebugStopAtCurrentLine&lt;Cr&gt;
&#34;autocmd Filetype python nnoremap &lt;F10&gt; &lt;Esc&gt;:REPLPDBN&lt;Cr&gt;
&#34;autocmd Filetype python nnoremap &lt;F11&gt; &lt;Esc&gt;:REPLPDBS&lt;Cr&gt;
&#34;let g:repl_width = None                           &#34;窗口宽度
&#34;let g:repl_height = None                          &#34;窗口高度
&#34; let g:sendtorepl_invoke_key = &#34;&lt;leader&gt;r&#34;          &#34;传送代码快捷键，默认为&lt;leader&gt;w
&#34; ref: http://stackoverflow.com/questions/598113/can-terminals-detect-shift-enter-or-control-enter
let g:sendtorepl_invoke_key = &#34;&lt;CR&gt;&#34;          &#34;传送代码快捷键，默认为&lt;leader&gt;w
let g:repl_position = 3                             &#34;0表示出现在下方，1表示出现在上方，2在左边，3在右边
let g:repl_stayatrepl_when_open = 0         &#34;打开REPL时是回到原文件（1）还是停留在REPL窗口中（0）&#34;
let g:repl_console_name = &#39;Vim-REPL&#39;
tnoremap &lt;C-h&gt; &lt;C-w&gt;&lt;C-h&gt;
tnoremap &lt;C-j&gt; &lt;C-w&gt;&lt;C-j&gt;
tnoremap &lt;C-k&gt; &lt;C-w&gt;&lt;C-k&gt;
tnoremap &lt;C-l&gt; &lt;C-w&gt;&lt;C-l&gt;
&#34; tnoremap &lt;C-n&gt; &lt;C-w&gt;N
tnoremap &lt;ScrollWheelUp&gt; &lt;C-w&gt;Nk
tnoremap &lt;ScrollWheelDown&gt; &lt;C-w&gt;Nj

&#34; Fastfold --------------------------------------------------------------------
nmap zuz &lt;Plug&gt;(FastFoldUpdate)
let g:fastfold_savehook = 1
let g:fastfold_fold_command_suffixes =  [&#39;x&#39;,&#39;X&#39;,&#39;a&#39;,&#39;A&#39;,&#39;o&#39;,&#39;O&#39;,&#39;c&#39;,&#39;C&#39;]
let g:fastfold_fold_movement_commands = [&#39;z&#39;, &#39;[z&#39;, &#39;zj&#39;, &#39;zk&#39;]
let g:fastfold_fold_command_suffixes = [&#39;x&#39;,&#39;X&#39;,&#39;a&#39;,&#39;A&#39;,&#39;o&#39;,&#39;O&#39;,&#39;c&#39;,&#39;C&#39;,&#39;r&#39;,&#39;R&#39;,&#39;m&#39;,&#39;M&#39;,&#39;i&#39;,&#39;n&#39;,&#39;N&#39;]

&#34; Highlight  ------------------------------------------------------------------
&#34; Highlight TODO, FIXME, NOTE, etc.
if has(&#34;autocmd&#34;)
  if v:version &gt; 701
    autocmd Syntax * call matchadd(&#39;Todo&#39;,  &#39;\W\zs\(TODO\|FIXME\|CHANGED\|BUG\|HACK\)&#39;)
    autocmd Syntax * call matchadd(&#39;Debug&#39;, &#39;\W\zs\(NOTE\|Note:\|INFO\|IDEA\)&#39;)
  endif
endif

&#34; abb ------------------------------------------------------------------------
vmap \a :source ~/.vim/abb.vim&lt;CR&gt;
nnoremap \a :source ~/.vim/abb.vim&lt;CR&gt;

&#34;Rainbow ---------------------------------------------------------------------
&#34;&#34;au FileType c,cpp,objc,objcpp call rainbow#load()
let g:rainbow_active = 1
let g:rainbow_load_separately = [
    \ [ &#39;*&#39; , [[&#39;(&#39;, &#39;)&#39;], [&#39;\[&#39;, &#39;\]&#39;], [&#39;{&#39;, &#39;}&#39;]] ],
    \ [ &#39;*.tex&#39; , [[&#39;(&#39;, &#39;)&#39;], [&#39;\[&#39;, &#39;\]&#39;]] ],
    \ [ &#39;*.cpp&#39; , [[&#39;(&#39;, &#39;)&#39;], [&#39;\[&#39;, &#39;\]&#39;], [&#39;{&#39;, &#39;}&#39;]] ],
    \ [ &#39;*.{html,htm}&#39; , [[&#39;(&#39;, &#39;)&#39;], [&#39;\[&#39;, &#39;\]&#39;], [&#39;{&#39;, &#39;}&#39;], [&#39;&lt;\a[^&gt;]*&gt;&#39;, &#39;&lt;/[^&gt;]*&gt;&#39;]] ],
    \ ]

let g:rainbow_guifgs = [&#39;RoyalBlue3&#39;, &#39;DarkOrange3&#39;, &#39;DarkOrchid3&#39;, &#39;FireBrick&#39;]
let g:rainbow_ctermfgs = [&#39;lightblue&#39;, &#39;lightgreen&#39;, &#39;yellow&#39;, &#39;red&#39;, &#39;magenta&#39;]

&#34;UltiSnips -------------------------------------------------------------------
&#34;Put under .vim/UltiSnips
let g:UltiSnipsSnippetDirectories=[&#34;UltiSnips&#34;, &#34;MyUltiSnips&#34;]

&#34; Trigger configuration. You need to change this to something other than &lt;tab&gt; if you use one of the following:
&#34; - https://github.com/Valloric/YouCompleteMe
&#34; - https://github.com/nvim-lua/completion-nvim
&#34; let g:UltiSnipsExpandTrigger=&#34;&lt;leader&gt;&lt;tab&gt;&#34;
&#34; let g:UltiSnipsJumpForwardTrigger=&#34;&lt;leader&gt;&lt;tab&gt;&#34;
&#34; let g:UltiSnipsJumpBackwardTrigger=&#34;&lt;leader&gt;&lt;tab&gt;&#34;
let g:UltiSnipsExpandTrigger=&#34;&lt;leader&gt;u&#34;
let g:UltiSnipsJumpForwardTrigger=&#34;&lt;leader&gt;s&#34;
let g:UltiSnipsJumpBackwardTrigger=&#34;&lt;leader&gt;s&#34;
let g:UltiSnipsListSnippets=&#34;&lt;c-l&gt;&#34;
&#34; If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit=&#34;vertical&#34;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-26-vim9-%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AEcoc.vim/  

