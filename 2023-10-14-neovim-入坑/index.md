# neovim 入坑


尝试使用 `neovim`，可以重复利用 `lua` 这个编程语言。

&lt;!--more--&gt;

## 安装

```bash
## 下载二进制
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -xvf nvim-linux64.tar.gz

## 添加到系统路径
sudo cp -r nvim-linux64 /usr/local/
sudo ln -sfn /usr/local/nvim-linux64/bin/nvim  /usr/bin/nvim

## 查看版本
$ nvim --version
NVIM v0.9.4
Build type: Release
LuaJIT 2.1.1692716794

   system vimrc file: &#34;$VIM/sysinit.vim&#34;
  fall-back for $VIM: &#34;/__w/neovim/neovim/build/nvim.AppDir/usr/share/nvim&#34;

Run :checkhealth for more info

## 打开 nvim，执行 :checkhealth
Configuration
- WARNING Missing user config file: /home/william/.config/nvim/init.vim
  - ADVICE:
    - :help nvim-from-vim

Runtime
- OK $VIMRUNTIME: /usr/local/nvim-linux64/share/nvim/runtime

Performance
- OK Build type: Release

Remote Plugins
- OK Up to date

terminal
- key_backspace (kbs) terminfo entry: key_backspace=
- key_dc (kdch1) terminfo entry: key_dc=
- $TERM_PROGRAM=&#34;tmux&#34;
```

## 配置

nvim 默认会读取初始化文件
1. init.lua
2. init.vim

```bash
## nvim 的配置文件在
mkdir -p ~/.config/nvim
cd ~/.config/nvim
```

### 配置选项

主要用到的就是 `vim.g`、`vim.opt`、`vim.cmd` 等

| In `Vim`          | In `Nvim`                 | Note                             |
| ----------------- | ------------------------- | -------------------------------- |
| `let g:foo = bar` | `vim.g.foo = bar`         |                                  |
| `set foo = bar`   | `vim.opt.foo = bar`       | `set foo` = `vim.opt.foo = true` |
| `some_vimscript`  | `vim.cmd(some_vimscript)` |                                  |


### 插件管理

#### lazy.nvim

ref: [lazy-nvim插件管理器基础入门](https://www.cnblogs.com/w4ngzhen/p/17493128.html)

```bash
## 添加 init.lua
vim ~/.config/nvim/init.lua

-- bootstrap lazy.nvim
-- ./lua/lazynvim-init.lua
require(&#34;lazynvim-init&#34;)

## 设置 lazynvim
vim ~/.config/nvim/lua/lazynvim-init.lua

-- 1. 准备lazy.nvim模块（存在性检测）
-- stdpath(&#34;data&#34;)
-- macOS/Linux: ~/.local/share/nvim
-- Windows: ~/AppData/Local/nvim-data
local lazypath = vim.fn.stdpath(&#34;data&#34;) .. &#34;/lazy/lazy.nvim&#34;
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		&#34;git&#34;,
		&#34;clone&#34;,
		&#34;--filter=blob:none&#34;,
		&#34;https://github.com/folke/lazy.nvim.git&#34;,
		&#34;--branch=stable&#34;, -- latest stable release
		lazypath,
	})
end
--
-- 2. 将 lazypath 设置为运行时路径
-- rtp（runtime path）
-- nvim进行路径搜索的时候，除已有的路径，还会从prepend的路径中查找
-- 否则，下面 require(&#34;lazy&#34;) 是找不到的
vim.opt.rtp:prepend(lazypath)

-- 3. 加载lazy.nvim模块
-- require(&#34;lazy&#34;).setup({})
-- 在 ~/.config/nvim/lua/plugins 安装插件
require(&#34;lazy&#34;).setup(&#34;plugins&#34;)

## 打开 nvim 验证 lazynvim
:Lazy

## 安装 plugin
mkdir -p ~/.config/nvim/lua/plugins
vim ~/.config/nvim/lua/plugins/plugin-lualine.lua

return {
    {
        &#39;nvim-lualine/lualine.nvim&#39;,
        config = function()
            require(&#39;lualine&#39;).setup()
        end
    }
}
```

#### vim-plug

```bash
## 使用 vim-plug: https://github.com/junegunn/vim-plug
## 存放在 ~/.config/nvim，避免与 vim 冲突
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

## 需要安装 pynvim
## python3 -m pip install --user --upgrade pynvim
## 安装相关的插件，位置在：~/.config/nvim/plugged
vim ~/.config/nvim/init.vim

&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;如果vim插件管理器没有安装则自动安装
if empty(glob(&#39;~/.config/nvim/autoload/plug.vim&#39;))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

&#34;&#34; 设置vim可以保存文件修改历史
silent !mkdir -p ~/.config/nvim/tmp/backup
silent !mkdir -p ~/.config/nvim/tmp/undo
&#34;&#34;silent !mkdir -p ~/.config/nvim/tmp/sessions
set backupdir=~/.config/nvim/tmp/backup,.
set directory=~/.config/nvim/tmp/backup,.
if has(&#39;persistent_undo&#39;)
    set undofile
    set undodir=~/.config/nvim/tmp/undo,.
endif

call plug#begin(&#39;~/.config/nvim/plugged&#39;)
Plug &#39;sainnhe/everforest&#39;
call plug#end()
```

### 快捷键

### 主题配色

### 以 vimrc 作为基本
~~当然，我们也可以直接使用 `.vimrc` 作为配置~~

```bash
# CONFIG_PATH=$HOME/.config
# ln -s ~/.vim   $CONFIG_PATH/nvim
# ln -s ~/.vimrc $CONFIG_PATH/nvim/init.vim
```

### lsp

```bash
## nvim &#39;iostream&#39; file not found
sudo apt install libstdc&#43;&#43;-12-dev
```

### python

```bash
/home/lfang/.config/nvim/lazy/mason/packages/python-lsp-server/venv/pyvenv.cfg

home = /home/lfang/anaconda3/bin
## true
include-system-site-packages = true
version = 3.9.12
```

## Ref:

- [X] [关于 bufferline.lua 的合理配置](https://github.com/nullptr-yxw/nvim-config/blob/main/lua/plugins/buffer-line.lua)
- [X] 比较规范的一个配置项目：[nvim](https://github.com/Zwlin98/nvim/tree/main)
- [X] [功能强大](https://dev.to/voyeg3r/my-lazy-neovim-config-3h6o)
- [X] [.config](https://github.com/chrisgrieser/.config/tree/main/nvim/lua/plugins)
- [X] [Neovim小结](https://www.xwxwgo.com/post/2022/02/10/neovim%E5%B0%8F%E7%BB%93/)
- [X] [nvim配置文件 (Ubuntu 18.04 测试成功)](https://gitee.com/muaimingjun/nvim/blob/master/init.vim)
- [ ] [从零开始配置 Neovim(Nvim)](https://martinlwx.github.io/zh-cn/config-neovim-from-scratch/)
- [X] [使用 init.vim](https://github.com/szoradigeza/nvim-config/blob/master/init.vim)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-10-14-neovim-%E5%85%A5%E5%9D%91/  

