# R: package 开发指南


# hicloudR

R package for hicloud
&lt;!--more--&gt;

## 开发指南

假设这个包的名称叫 `hicloudR`

### 目录结构

- 需要建立一个 `R` 目录
- 添加 `DESCRIPTION` 用来说明开发包
- 添加 `NAMESPACE` 提供函数

```bash
## 建立一个 R 目录
mkdir R

## 建立一个描述文档
touch DESCRIPTION

## 提供函数
touch NAMESPACE
```

在 `DESCRIPTION` 添加

```
Package: hicloudR
Version: 0.1
```

在 ``NAMESPACE` 添加

```
## 暴露所有函数
exportPattern(&#34;^[[:alpha:]]&#43;&#34;)
```

## 使用 Rcpp

- 在 `DESCRIPTION` 添加

    `````
    Package: hicloudR
    Version: 0.1
    LinkingTo: Rcpp
    Imports: Rcpp
    `````

- 在 `NAMESPACE` 添加

    ```
    exportPattern(&#34;^[[:alpha:]]&#43;&#34;)
    useDynLib(hicloudR)
    importFrom(Rcpp, sourceCpp)
    ```

- 把 `myRcpp.cpp` 放在 `src` 目录下面

- 然后在这个包目录 （与 `R`、`src` 并行的）运行

    ``` bash
    tree -L 2

    .
    ├── data
    ├── DESCRIPTION
    ├── man
    ├── NAMESPACE
    ├── R
    │   ├── about.R
    │   └── RcppExports.R
    ├── README.md
    ├── src
    │   ├── myRcpp.cpp
    │   └── RcppExports.cpp
    └── tests

    Rscript -e &#34;Rcpp::compileAttributes()&#34;
    ```

  这样会生成两个文件

    - `R/RcppExports.R`
    - `src/RcppExports.cpp`




### 打包

打开终端执行

```bash
## 需要跳转到上面一层
cd ..
R CMD build hicloudR

* checking for file ‘hicloudR/DESCRIPTION’ ... OK
* preparing ‘hicloudR’:
* checking DESCRIPTION meta-information ... OK
* checking for LF line-endings in source and make files and shell scripts
* checking for empty or unneeded directories
* building ‘hicloudR_0.1.tar.gz’
```

### 安装

```bash
R CMD INSTALL hicloudR_0.1.tar.gz

* installing to library ‘/home/william/R/x86_64-pc-linux-gnu-library/3.6’
* installing *source* package ‘hicloudR’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
这是一个 hicloudR 的软件包，目前基于开源协议 MIT 进行创作。
所有版权归属汉云投资。
@williamlfang
** help
No man pages found in package  ‘hicloudR’
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (hicloudR)
```

### 使用 `devtools`

`devtools` 提供了更加优雅的方式，可以直接在 `R` 运行环境中进行构建

- `devtools::build()`
- `devtools::install()`

```R
❯ setwd(&#39;/home/william/Documents/hicloudR&#39;)

✔ 95.6 MiB master*
❯ devtools::build()
✔  checking for file ‘/home/william/Documents/hicloudR/DESCRIPTION’ ...
─  preparing ‘hicloudR’:
✔  checking DESCRIPTION meta-information
─  checking for LF line-endings in source and make files and shell scripts
─  checking for empty or unneeded directories
─  building ‘hicloudR_0.1.tar.gz’

[1] &#34;/home/william/Documents/hicloudR_0.1.tar.gz&#34;

❯ devtools::install()
✔  checking for file ‘/home/william/Documents/hicloudR/DESCRIPTION’ ...
─  preparing ‘hicloudR’:
✔  checking DESCRIPTION meta-information
─  checking for LF line-endings in source and make files and shell scripts
─  checking for empty or unneeded directories
─  building ‘hicloudR_0.1.tar.gz’

Running /usr/lib/R/bin/R CMD INSTALL /tmp/RtmpDbpRnz/hicloudR_0.1.tar.gz --install-tests
* installing to library ‘/home/william/R/x86_64-pc-linux-gnu-library/3.6’
* installing *source* package ‘hicloudR’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
这是一个 hicloudR 的软件包，目前基于开源协议 MIT 进行创作。
所有版权归属汉云投资。
@williamlfang
** help
No man pages found in package  ‘hicloudR’
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (hicloudR)
```

## 托管到 `github`

### 添加 `repo`

```bash
git add ./*
git commit -m &#39;init&#39;
git push
```

### 安装

然后就可以直接安装了

- `devtools::install_github(&#34;williamlfang/hicloudR&#34;)`

```bash
❯ devtools::install_github(&#34;williamlfang/hicloudR&#34;)
Downloading GitHub repo williamlfang/hicloudR@master
✔  checking for file ‘/tmp/RtmpDbpRnz/remotes41d42dcbca76/williamlfang-hicloudR-20b2dbf/DESCRIPTION’ ...
─  preparing ‘hicloudR’:
✔  checking DESCRIPTION meta-information
─  checking for LF line-endings in source and make files and shell scripts
─  checking for empty or unneeded directories
─  building ‘hicloudR_0.1.tar.gz’

Installing package into &#39;/home/william/R/x86_64-pc-linux-gnu-library/3.6&#39;
(as &#39;lib&#39; is unspecified)
* installing *source* package ‘hicloudR’ ...
** using staged installation
** R
** byte-compile and prepare package for lazy loading
这是一个 hicloudR 的软件包，目前基于开源协议 MIT 进行创作。
所有版权归属汉云投资。
@williamlfang
** help
No man pages found in package  ‘hicloudR’
*** installing help indices
** building package indices
** testing if installed package can be loaded from temporary location
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (hicloudR)

```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-21-r--package-%E5%BC%80%E5%8F%91%E6%8C%87%E5%8D%97/  

