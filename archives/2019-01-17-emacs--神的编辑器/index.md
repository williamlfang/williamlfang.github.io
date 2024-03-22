# Emacs: 神的编辑器


`Emacs` 速来有「神的编辑器」之美誉，同另一款「编辑器之神」`Vi/Vim`，都是程序员编辑源文件、编写文档的重要法宝。用一种在江湖上流传许久的说法，`Emacs`其实不是**编辑器**，而是披着编辑器外衣的**操作系统**，具有高强度的可拓展性，堪比一款操作系统般强大。

&lt;!--more--&gt;

# 安装

## Linux

### Ubuntu

#### 源码编译安装(最新版)

系统更新资源：
```bash
sudo apt-get update &amp;&amp; apt-get upgrade
```

安装源码编译需要的包：

```bash
sudo apt-get install build-essential libncurses-dev
```

可以到 [EMACS官方下载页面](https://www.gnu.org/software/emacs/download.html) 或 直接使用下面的链接:

```bash
$ cd /tmp
$ wget http://mirrors.ustc.edu.cn/gnu/emacs/emacs-26.1.tar.xz

## 解压 xz 文件包
$ tar -xJvf emacs-26.1.tar.xz
$ cd emacs-26.1
```

可以通过 `configure` 进行配置安装：

- `纯命令行`：仅用于控制台环境，如果需要GUI界面还要安装其它开发包, `--without-x`，以及 `--with-gnutls=no`
- `交互界面`：默认是会配置所有的交互界面，但需要额外安装相关的软件包。

  ```bash
  ## 默认安装 GUI
  $ ./configure
  ```

对于在本地操作，一般我选择配置 `GUI`。如果有报错需要安装包，可以使用 `apt search xxx` 来搜索名称，然后安装好就可以了。我安装了几个常用的包：

```bash
$ sudo apt-get install gnutls-dev libxpm-dev libgif-dev libtiff-dev
```

如果继续报错
```bash
... ...
checking for libXaw... configure: error: No X toolkit could be found.
... ...
```
则需要通过安装 `gtk` 来实现带界面运行

```bash
apt search gtk | grep libgtk

libgtk2.0-dev    - development files for the GTK&#43; library
```

安装这个 `gtk` 包
```bash
$ sudo apt-get install libgtk2.0-dev
```

剩下的就是编译安装了

```bash
$ sudo make &amp;&amp; make install
```

查看版本号

```bash
$ emacs --version
GNU Emacs 26.1
Copyright (C) 2018 Free Software Foundation, Inc.
GNU Emacs comes with ABSOLUTELY NO WARRANTY.
You may redistribute copies of GNU Emacs
under the terms of the GNU General Public License.
For more information about these matters, see the file named COPYING.
```

当然，也可以在终端启动无界面的操作：

```bash
$ emacs -nw
```

![emacs -nw](/images/2019-01-17-Emacs--神的编辑器/nw.png &#34;emacs -nw&#34;)

#### 一键安装(稳定版)

这种方式比较适合安装在 `ppa` 里面的稳定版本，通常是较当前版本号降低一个系列：
```bash
$ sudo apt install emacs
```

![emacs 启动初始界面](/images/2019-01-17-Emacs--神的编辑器/emacs.png &#34;emacs 启动初始界面&#34;)

# 配置

## 配置文件

从本质上说，`Emacs` 其实只是一款 `Lisp` 的编译引擎，可以用来执行任何符合语法的 `Lisp` 脚本。由此推导出来，我们可以通过编写自定义的**配置文件**来设置 `Emacs` 启动后执行的程序命令。通过查看 `GNU Emacs` 的官方说明，在 `Init File` 这部分内容里，我们知道，`Emacs` 会自动去搜索以下路径的配置文件

- `～/.emacs`：这种方式是把所有的配置信息都写在一个文件里，设置相对简单，**但不利于进行模块化管理，一旦设置文件增多，会导致混乱**，一般不推荐这种配置方式。

- `~/.emacs.el`

- `~/.emacs.d/init.el`：这种方式更加现代，可以把所有的配置文件都统一放在一个文件夹下面，因此更有力于管理插件与配置。`Emacs` 在启动后会先读入 `init.el` 文件设置，虽然只是一个单文件，但是可以利用 `feature` 机制，把具体的模块分类写在这里面。

  ```bash
  .
  ├── elpa
  ├── init.el
  ├── lisp
  └── themes

  3 directories,  files
  ```

  - 在配置文件 `init.el` 中，通过 `add-to-list` 将相关的配置文件路径添加到初始化读取路径中。
    - 如果是在 `~/.eamcs.d` 目录下面，可以使用 `(add-to-list &#39;load-path &#34;~/.emacs.d/plugins&#34;)`
    - 如果还有一层子目录，需要指定 `(add-to-list &#39;load-path (expand-file-name &#34;子目录/子目录&#34; &#34;~/.emacs.d&#34;))`。其实，上一条也可以写成 `(add-to-list &#39;load-path (expand-file-name &#34;~/.emacs.d&#34;))`，相当于 `子目录` 写成**空目录**。
  - 一般来说，将配置文件名与其提供的 `feature` 函数命名相同。

  比如，我的配置文件 `init.el`:

  ```lisp
  ;; This is the main Emacs initialization file – .emacs.

  (add-to-list &#39;load-path (expand-file-name &#34;lisp&#34; &#34;~/.emacs.d&#34;))
  (require &#39;feature_1)
  (require &#39;feature_2)
  (require &#39;feature_3)
  ```

  然后在 `&#34;lisp&#34;` 目录下面放入 `feature_1`、`feature_2`、`feature_3`。

  比如：`feature_1` 这个配置文件，它提供`feature_1`特性，即是 `～/.emacs.d/init.el` 中使用 `require` 命令要求的 `feature_1` 特性，那么要在`feature_1.el` 中加入 `provide`，则 `feature_1.el` 内容如下：

  ```lisp
  ;; This is my Emacs customization file feature_1.el providing feature_1
  (provide ‘feature_1)  ;; 为 init.el 提供 require &#39;feature_1
  ;; customization code …
  ```

## 中文输入问题
参考:
- [Ubuntu18.04中解决emacs无法输入中文的问题](https://www.jianshu.com/p/852f679d0e76?utm_campaign=maleskine&amp;utm_content=note&amp;utm_medium=seo_notes&amp;utm_source=recommendation)
- [Ubuntu Emacs下无法使用fcitx输入中文的简单workaround](https://zhuanlan.zhihu.com/p/31642707)



## 插件

### ESS



### IPython

## 主题设置

### `color-theme`

可以下载一个主题集成包，`color-theme`，里面自带了多款颜色主题。

```bash
cd ~/Downloads

## 下载 color-theme
wget http://download.savannah.gnu.org/releases/color-theme/color-theme-6.6.0.tar.gz

tar xfv color-theme-6.6.0.tar.gz
cd color-theme-6.6.0

## 复制到 ~/.emacs.d/plugins 目录
cp -r themes color-theme.el ~/.emacs.d/plugins
```

打开Emacs后可以 `M&#43;X color-theme-select` 选择你喜欢的主题，使用回车键 `Enter` 来预览效果，然后将相应的名称写入 `～/.emacs.d/init.el` 中。

```lisp
;; 需要指定加载的路径
(add-to-list &#39;load-path &#34;~/.emacs.d/plugins&#34;)
(require &#39;color-theme)
(color-theme-initialize)
;; 这个是你选择的主题，后面的 subtle-hacker 就是它的名字，注意使用 小写 。
(color-theme-subtle-hacker)
```

![color-theme](/images/2019-01-17-Emacs--神的编辑器/color-theme-subtle-hacker.png &#34;color-theme&#34;)

### `one-dark-theme`

当然，我比较喜欢 `Atom-One-Dark-Theme`。这个比较适合在黑色背景下进行写代码。

已经有牛人把这个颜色主题改成了 Emacs 下的配置方案，比如 [Introducing Atom One Dark Theme for Emacs](https://github.com/jonathanchu/atom-one-dark-theme)。

先把这个配置下载到本地目录 `~/.emacs.d/themes`

```bash
cd ~/.emacs.d/themes
git clone https://github.com/jonathanchu/atom-one-dark-theme.git
```

然后在配置文件 `~/emacs.d/init.el` 增加

```:new_zealand:
;; -----------------------------------------------------------------------------------
(add-to-list &#39;custom-theme-load-path &#34;~/.emacs.d/themes/atom-one-dark-theme&#34;)
(load-theme &#39;atom-one-dark t)
;; -----------------------------------------------------------------------------------
```

重启 `Emacs` 即可看到效果了。

![one-dark-theme](/images/2019-01-17-Emacs--神的编辑器/one-dark-theme.png &#34;one-dark-theme&#34;)

### `zenburn`

`zenburn` 原来是 `Vim` 下面的一款**低对比度**颜色配置方案，后来又移植到 `Emacs`，[The Zenburn colour theme ported to Emacs](https://github.com/bbatsov/zenburn-emacs)。同样，我们也可以十分方便的安装：

```:new_zealand:
cd ~/.emacs.d/themes
git clone git@github.com:bbatsov/zenburn-emacs.git
```

然后在配置文件 `~/emacs.d/init.el` 增加

```:zambia:
(add-to-list &#39;custom-theme-load-path &#34;~/.emacs.d/themes/zenburn-emacs&#34;)
(load-theme &#39;zenburn t)
```

![zenburn](/images/2019-01-17-Emacs--神的编辑器/zenburn.png &#34;zenburn&#34;)


## 快捷设置

## 模式设置

# Lisp介绍

# 使用体会与个人总结



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-01-17-emacs--%E7%A5%9E%E7%9A%84%E7%BC%96%E8%BE%91%E5%99%A8/  

