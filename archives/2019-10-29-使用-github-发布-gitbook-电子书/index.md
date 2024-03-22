# 使用 github 发布 gitbook 电子书


`gitbook` 是一个用于生成现代电子书的工具，进过处理后可以得到`mobi`、`pdf`、静态网页等多种类型的书籍形式。对于生成后得到的静态网页，我们可以将其托管在 `github` 上面，使用 `gh-pages` 发布到网上，从而实现制作文档、发布知识分享。

本篇博客总结了如何配置 `gitbook`、如何制作静态网页、如何使用 `github` 托管等方面的技巧。

&lt;!--  --&gt;
## 安装软件

### 安装 gitbook
需要使用 `npm` 执行命令

```bash
npm install gitbook -g
```

安装完成后，可以使用命令查找具体的可执行文件所在目录

```bash
whereis gitbook
```

查看具体的版本号

```bash
/opt/node-v12.10.0-linux-x64/bin/gitbook -V
```

### 基本命令

- 初始化，会自动生成 README.md 以及 SUMMARY.md
    ```bash
    gitbook init
    ```
- 生成静态网页，会得到 `_book` 的目录
    ```bash
    gitbook build
    ```
- 本地预览
    ```bash
    gitbook serve
    ```

### 安装插件
由于使用的插件需要嵌入到静态网站，通常的做法是直接配置一个 `book.json` 的文件，里面会填入托管网站相关的信息，以及需要使用的配置参数。比如

```json
{
    &#34;author&#34;: &#34;方莲&#34;,
    &#34;description&#34;: &#34;To be betteR.&#34;,
    &#34;title&#34;: &#34;betteR&#34;,
    &#34;variables&#34;: {},
    &#34;extension&#34;: null,
    &#34;generator&#34;: &#34;site&#34;,
    &#34;isbn&#34;: &#34;&#34;,
    &#34;links&#34;: {
        &#34;sharing&#34;: {
            &#34;all&#34;: null,
            &#34;facebook&#34;: null,
            &#34;google&#34;: null,
            &#34;twitter&#34;: null,
            &#34;weibo&#34;: null
        },
        &#34;sidebar&#34;: {
            &#34;William&#39;s Blog&#34;: &#34;https://williamlfang.github.io/&#34;
        }
    },
    &#34;output&#34;: null,
    &#34;pdf&#34;: {
        &#34;fontSize&#34;: 12,
        &#34;footerTemplate&#34;: null,
        &#34;headerTemplate&#34;: null,
        &#34;margin&#34;: {
            &#34;bottom&#34;: 36,
            &#34;left&#34;: 62,
            &#34;right&#34;: 62,
            &#34;top&#34;: 36
        },
        &#34;pageNumbers&#34;: false,
        &#34;paperSize&#34;: &#34;a4&#34;
    },
    &#34;plugins&#34;: [&#34;chapter-fold&#34;,
                &#34;expandable-chapters-small&#34;,
                &#34;expandable-chapters&#34;,
                &#34;advanced-emoji&#34;,
                &#34;github&#34;,
                &#34;splitter&#34;,
                &#34;-sharing&#34;, &#34;sharing-plus&#34;,
                &#34;simple-page-toc&#34;,
                &#34;copy-code-button&#34;,
                &#34;page-toc-button&#34;,
                &#34;klipse&#34;,
                &#34;pageview-count&#34;,
                &#34;popup&#34;,
                &#34;tbfed-pagefooter&#34;,
                &#34;todo&#34;,
                &#34;prism&#34;, &#34;-highlight&#34;
                ],
    &#34;pluginsConfig&#34;: {
        &#34;github&#34;: {&#34;url&#34;: &#34;https://github.com/williamlfang&#34;},
        &#34;sharing&#34;: {
                   &#34;douban&#34;: true,
                   &#34;google&#34;: true,
                   &#34;twitter&#34;: true,
                   &#34;weibo&#34;: true,
                   &#34;all&#34;: [
                       &#34;google&#34;, &#34;twitter&#34;, &#34;weibo&#34;
                   ]
               },
        &#34;simple-page-toc&#34;: {
                &#34;maxDepth&#34;: 3,
                &#34;skipFirstH1&#34;: true
                },
        &#34;page-toc-button&#34;: {
            &#34;maxTocDepth&#34;: 3,
            &#34;minTocSize&#34;: 3
           },
        &#34;tbfed-pagefooter&#34;: {
                    &#34;copyright&#34;:&#34;&#34;,
                    &#34;modify_label&#34;: &#34;该文件最后修改时间：&#34;,
                    &#34;modify_format&#34;: &#34;YYYY-MM-DD HH:mm:ss&#34;
                },
        &#34;prism&#34;: {
          &#34;css&#34;: [
            &#34;prismjs/themes/prism-dracula.css&#34;
          ]
        }
    }
}
```

在这个配置文件，我使用了一些外部插件。对于这些插件，我们可以在项目的`根目录`下执行命令进行安装

```bash
gitbook install ./
```

## 搭建 github 网页

`github` 提供 `gh-pages` 功能，可以生成静态网站托管。

- 在`github`创建新仓库，默认为 `master` 主干枝
- 在本地拷贝远程仓库
    ```bash
    git clone git@github.com:williamlfang/ProjectName.git
    ```
- 在本地仓库搭建 `gitbook`
    ```bash
    cd ProjectName
    ## 开始搭建静态网页
    gitbook build
    ```
- 建立分支 `gh-pages` 用于显示静态网页
    ```bash
    git checkout -b gh-pages
    ```
- 同步拷贝 `master` 目录得到的 `_book` 到 `gh-pages`
    ```bash
    git checkout master -- _book
    cp -r _book/* ./
    ```
- 提交更新
    ```bash
    git add ./*
    git commit -m &#39;update gh-pages&#39;
    git push origin gh-pages
    ```
- 这样，我们便在 `gh-pages` 存放了生成的静态网页，通过浏览器访问可查看具体的[项目网页](https://williamlfang.github.io/betteR/)


## 一键脚本
我写了一个简单的脚本 `deploy.sh`，实现一键执行相关的操作

```bash
#!/usr/bin/env bash

# Set the English locale for the `date` command.
export LC_TIME=en_US.UTF-8

# GitHub username.
USERNAME=williamlfang
# Name of the branch containing the Hugo source files.
SOURCE=betteR
# The commit message.
MESSAGE=&#34;Gitbook rebuild $(date)&#34;

## -------------------------------------------
msg() {
    printf &#34;\033[1;32m :: %s\n\033[0m&#34; &#34;$1&#34;
}
## -------------------------------------------


## -------------------------------------------
## 切换到 master
git checkout master
msg &#34;Pulling down from ${SOURCE}&lt;master&gt;&#34;
#从github更新原文件并生成静态页面
# git pull

## 使用 R 制作 md
Rscript -e &#39;blogdown::build_dir(dir = &#34;.&#34;, force = FALSE, ignore = &#34;[.]Rproj$&#34;)&#39;  2&gt;&amp;1 &gt;/dev/null

msg &#34;Rebuild gitbook&#34;
## 安装插件
# /opt/node-v12.10.0-linux-x64/bin/gitbook install ./
## 建立静态网页
/opt/node-v12.10.0-linux-x64/bin/gitbook build

git add -A
git commit -m &#34;update master&#34;
git push origin master
## -------------------------------------------


## -------------------------------------------
msg &#34;Pushing new info to gh-pages&#34;
## 创建分支
# git checkout -b gh-pages
git checkout gh-pages
## 同步 master 的 _book 到 gh-pages
git checkout master -- _book

cp -r _book/* .
echo &#34;node_modules
_book&#34;&gt;.gitignore

git add -A
git commit -m &#34;update gh-pages&#34;
git push origin gh-pages

git checkout master
msg &#34;We&#39;ve happily done.&#34;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-10-29-%E4%BD%BF%E7%94%A8-github-%E5%8F%91%E5%B8%83-gitbook-%E7%94%B5%E5%AD%90%E4%B9%A6/  

