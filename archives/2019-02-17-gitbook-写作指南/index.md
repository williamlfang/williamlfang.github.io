# gitbook 写作指南


介绍如何使用 `gitbook` 编写技术手册，并配置 `github` 实现对内容的版本控制。

&lt;!--more--&gt;

`gitbook` 是在线文本的展示与管理网站，提供了独立主页、项目结构、文本形式等规范化的项目格式，从而使得我们只需要专注于内容的生产，无需处理格式化的问题，从而实现了快速发布文档。

![gitbook website](/images/2019-02-17-gitbook-写作指南/gitbook_website.png)

# 安装 `gitbook`

```bash
## 如果提示没有 npm，则需要安装 node
## -------------------------------
## Ubuntu 使用 apt 安装
sudo apt install npm
## Mac 使用 brew 安装 node
## 会附带 npm 工具
sudo brew install node
## -------------------------------

## 使用 root 权限
sudo npm install gitbook -g
sudo npm install gitbook-cli -g
```

# GitBook 搭建主页

## 注册账户

首先，我们需要通过 [`gitbook` 官网](https://legacy.gitbook.com/)注册一个账户，用于管理文档。

![gitbook 注册](/images/2019-02-17-gitbook-写作指南/gitbook_register.png)

## 登录账户

注册完成后，便可以登录账户了。

![gitbook 登录](/images/2019-02-17-gitbook-写作指南/gitbook_login.png)

## 建立项目



# 管理内容

## 关联`github`仓库

## 同步更新



# 写作指引

## 初始化书籍

```bash
## 初始化，根据 SUMMARY.md 生成对应的目录
gitbook init
```

得到
```bash
info: create math/readme.md
info: create stat/prob.md
info: create stat/eda.md
info: create programming/linux/cli.md
info: create programming/linux/ubuntu.md
info: create programming/linux/centos.md
info: create programming/c/why-c.md
info: create programming/c/pointer.md
info: create programming/c&#43;&#43;/why-c&#43;&#43;.md
info: create programming/c&#43;&#43;/class.md
info: create programming/python/why-python.md
info: create programming/python/numpy.md
info: create programming/python/pandas.md
info: create programming/r/why-r.md
info: create programming/r/data.table.md
info: create SUMMARY.md
info: initialization is finished
```

可以看到，`gitbook` 自动根据 `SUMMARY.md` 的大纲，为我们生成了目录

```bash
tree
.
├── math
│   └── readme.md
├── programming
│   ├── c
│   │   ├── pointer.md
│   │   └── why-c.md
│   ├── c&#43;&#43;
│   │   ├── class.md
│   │   └── why-c&#43;&#43;.md
│   ├── linux
│   │   ├── centos.md
│   │   ├── cli.md
│   │   └── ubuntu.md
│   ├── python
│   │   ├── numpy.md
│   │   ├── pandas.md
│   │   └── why-python.md
│   └── r
│       ├── data.table.md
│       └── why-r.md
├── README.md
├── stat
│   ├── eda.md
│   └── prob.md
└── SUMMARY.md

8 directories, 17 files
```

## 配置`book.json`

`gitbook` 在编译书籍的时候会读取书籍源码顶层目录 `repo/` 中的 `book.json`，支持如下配置：

由于我们在 `book.json` 使用了插件，因此需要让 `gitbook` 安装：

```bash
gitbook install .

info: installing 16 plugins using npm@3.9.2
info:
```



## 本地预览

当我们编辑完成相关的文档后，可以在本地先対书籍进行预览
```bash
gitbook serve .
Live reload server started on port: 35729
Press CTRL&#43;C to quit ...

info: 7 plugins are installed
info: loading plugin &#34;livereload&#34;... OK
info: loading plugin &#34;highlight&#34;... OK
info: loading plugin &#34;search&#34;... OK
info: loading plugin &#34;lunr&#34;... OK
info: loading plugin &#34;sharing&#34;... OK
info: loading plugin &#34;fontsettings&#34;... OK
info: loading plugin &#34;theme-default&#34;... OK
info: found 16 pages
info: found 0 asset files
info: &gt;&gt; generation finished with success in 2.2s !

Starting server ...
Serving book on http://localhost:4000
```

在浏览器打开 `http://localhost:4000` 就能看到书籍完成后的模样了．

![gitbook 本地预览](/images/2019-02-17-gitbook-写作指南/gitbook-local.png)

如果有提示报错，则需要把已经占用的端口线程杀掉，再重新开始预览

```bash
... Uhoh. Got error listen EADDRINUSE :::35729 ...
Error: listen EADDRINUSE :::35729
    at Object._errnoException (util.js:1022:11)
    at _exceptionWithHostPort (util.js:1044:20)
    at Server.setupListenHandle [as _listen2] (net.js:1367:14)
    at listenInCluster (net.js:1408:12)
    at Server.listen (net.js:1492:7)
    at Server.listen (/home/william/.gitbook/versions/3.2.3/node_modules/tiny-lr/lib/server.js:164:15)
    at Promise.apply (/home/william/.gitbook/versions/3.2.3/node_modules/q/q.js:1165:26)
    at Promise.promise.promiseDispatch (/home/william/.gitbook/versions/3.2.3/node_modules/q/q.js:788:41)
    at /home/william/.gitbook/versions/3.2.3/node_modules/q/q.js:1391:14
    at runSingle (/home/william/.gitbook/versions/3.2.3/node_modules/q/q.js:137:13)

You already have a server listening on 35729
You should stop it and try again.

```

使用命令

```bash
fuser -k 35729/tcp

35729/tcp:           18217
```



## 发布
由于我们使用了 `gitbook` 与 `github` 同步关联功能，因此，只需要把改动后的文档同步到 `github` 项目，就可以自动完成対 `gitbook` 的改动，从而实现书籍自动发布的目的。

```bash
## 重新编译，准备发布
gitbook build
```

![gitbook 远程发布](/images/2019-02-17-gitbook-写作指南/gitbook-server.png)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-02-17-gitbook-%E5%86%99%E4%BD%9C%E6%8C%87%E5%8D%97/  

