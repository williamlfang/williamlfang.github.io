# 使用hugo&#43;github搭建博客


使用 Hugo &#43; Github 搭建个人博客系统，并托管在 `Github Page` 服务。
&lt;!--more--&gt;

# 思路

- 在 `Github` 创建一个项目用于托管博客代码、markdown 文件等，比如 `myblog`
- 在 `Github` 创建 `Page` 项目。`Page` 项目是静态网页渲染，并可以托管在 `Github` 服务器。这样，我们就可以把网站内容发布到 `Github`。

    &gt; 这个 `Page` 的特别之处在于：我们将其项目名称设置为 `williamlfang.github.io`，即 `yourusename.github.io`。

- `Hugo` 是一个优秀的静态网页生成框架，提供了灵活的配置。我们可以通过设置不同的主题（theme）来渲染网页，达到内容与形式分离的目地。

    &gt; 由于部分主题的功能需要使用到新特性，我们最好安装 `hugo-extended` 版本。

    ```bash
    ## 需要安装 hugo extended version
    wget https://github.com/gohugoio/hugo/releases/download/v0.123.8/hugo_extended_0.123.8_linux-amd64.deb
    sudo dpkg -i hugo_extended_0.123.8_linux-amd64.deb
    hugo version
    ```

# 步骤

## 建立 Github 项目

- 在 `Github` 创建 `myblog` 项目
    - 原教程是将源仓库与 `Page` 放在同一个项目，所以需要设置成 `public`。不过我的做法是将源仓库与发布仓库`Page`分离，内容托管在 `myblog` 的 `private` 项目，然后将 `hugo` 渲染后的 `html` **拷贝到发布仓库 `Page`**。

- 在 `Github` 创建 `williamlfang.github.io` 项目
    - 如上所述，需要将发布仓库 `Page` 设置为 `public` 开放互联网访问。

## Hugo 搭建

- 初始化 `hugo` 目录

    ```bash
    git clone git@github.com:williamlfang/myblog.git

    ## 初始化项目，如果存在目录，则需要添加 --force
    hugo new site myblog
    cd myblog

    ## 添加主题，这里我使用来 FixIt
    git submodule add https://github.com/hugo-fixit/FixIt.git themes/FixIt
    ```

- 根据对应 `theme` 提供的配置文件进行修改，可以查看参考配置 `themes/FixIt/hugo.toml`

    ```bash
    vim hugo.toml
    ```

    比如我的配置是这样的：

    - `title` 设置博客名称
    - `baseURL` 对应域名（如果是托管在 `Github Page`，则填写`https://williamlfang.github.io/`）
    - `theme` 配置相应的名称（需要在 `themes/` 目录下）
    - `avatar` 是头像设置（如果是 `FixIt`，需要替换为自己的头像文件，在 `themes/FixIt/assets/images`）

- 创建博客 markdown 文章，可以使用命令

    ```bash
    ## create new post
    ## 这个命令会调用参数模板，位于 `theme/FixIt/archetypes`
    ## 我们可以自行修改
    hugo new posts/first_post.md
    ```

## 添加月历

主要是看到这篇优秀的博客，受到启发。于是我也准备在博客添加一个月历，用于查看文章发布的情况。


## 预览与发布

- 预览效果

    ```bash
    ## preview
    hugo server --disableFastRender
    ```

- 生成静态页面：把 `.md` 文件转化成 `html` 页面，并保存到 `public`。这个就是我们托管在 `Github Page` 上的网站。后面需要把这个文件夹拷贝到 `Page` 项目，并进行发布。

    ```bash
    ## 准备发布静态 html ，会生成一个 public 目录
    hugo
    ```

- 发布静态生成的网站页面

## deploy.sh 一键发布脚本

可以在项目建立一个脚本，用于一键发布最新变动。
&lt;!--more--&gt;

```bash
#!/usr/bin/env bash
# Set the English locale for the `date` command.
export LC_TIME=en_US.UTF-8
## -------------------------------------------
msg() {
    printf &#34;\033[1;32m :: %s\n\033[0m&#34; &#34;$1&#34;
}
## -------------------------------------------

## -------------------------------------------
# GitHub username.
USERNAME=williamlfang
# Name of the branch containing the Hugo source files.
SOURCE=myblog
# Github Page for public website
SITE=williamlfang.github.io
# The commit message.
MESSAGE=&#34;Site rebuild $(date)&#34;
## -------------------------------------------

cd ../${SITE}
pwd
msg &#34;Pulling down from ${SITE}&#34;
git pull

msg &#34;Building the website&#34;

cd ../${SOURCE}
pwd
msg &#34;Pulling down from ${SOURCE}&#34;
git pull

## ------------------------------------------------
# Rscript -e &#34;blogdown::build_site(build_rmd = TRUE)&#34;
## ------------------------------------------------

msg &#34;Pushing new info to Github&#34;

git add -A
git commit -m &#34;$MESSAGE&#34;
git push

cp -r public/* ../${SITE}
cd ../${SITE}
git add -A
git commit -m &#34;$MESSAGE&#34;
git push origin master

msg &#34;We&#39;ve happily done.&#34;
```

# 使用技巧

## 内容

### 排序

- [X] 默认以日期排序
- [X] 通过设置 `weight` 以改变文章排序（前置功能）

    ```Markdown
    ---
    title: 使用hugo&#43;github搭建博客
    weight: 1  &lt;!--实现文章置顶功能--&gt;
    ---
    ```

### 注释[^fixit_basic]

- [X] 要创建脚注引用，请在方括号中添加插入符号和标识符 (`[^1]`)。
- [X] 标识符可以是数字或单词，但不能包含空格或制表符。
- [X] 标识符仅将脚注引用与脚注本身相关联 - 在脚注输出中，脚注按顺序编号。

- [X] 在中括号内使用插入符号和数字以及用冒号和文本来添加脚注内容 (`[^1]：这是一段脚注`)。
- [X] 你不一定要在文档末尾添加脚注。可以将它们放在除列表，引用和表格等元素之外的任何位置。

    ```markdown
    这是一个数字脚注 [^1]
    这是一个带标签的脚注 [^label]

    [^1]: 这是一个数字脚注
    [^label]: 这是一个带标签的脚注
    ```

    - 这是一个数字脚注[^1]
    - 这是一个带标签的脚注[^label]

    [^1]: 这是一个数字脚注
    [^label]: 这是一个带标签的脚注
    [^fixit_basic]: 这个主要参考了 [FixIt:Markdown](https://fixit.lruihao.cn/zh-cn/documentation/content-management/markdown-syntax/basics/#%E6%B3%A8%E9%87%8A)


## 图片

### 路径

- [X] 在根目录下面有一个 `static` 目录，当`hugo`执行时，这个目录会被拷贝到 `public` 目录下，`html` 静态页面解析时会从这个路径开始寻找。因此，我们可以利用这一点，把 `avatar`、`logo` 等图片放在 `static/images` 下面，然后就可以使用路径 `/images/xxx.png` 来引用图片了

### 缩放功能

- [X] 可以实现图片的全屏放大功能：需要在图片后面添加注释信息。需要注意的是，我在这里使用了**相对路径**，即与当前文档在同一个目录下面，这有赖于 `Hugo(&gt;0.6.2)` 提供的 `layout/_default/_markup` 功能。

    ```Markdown
    ![我的博客](./hugo-fixit.png &#34;William Fang&#39;s Hugo FixIt&#34;)
    ```

    ![我的博客](./hugo-fixit.png &#34;William Fang&#39;s Hugo FixIt&#34;)

## 代码块

### 自动折叠

- [X] 配置默认展开的代码块长度

    ```toml
    #  代码配置
    [params.page.code]
      # 是否显示代码块的复制按钮
      copy = true
      #  是否显示代码块的编辑按钮
      edit = true
      # 默认展开显示的代码行数
      # maxShownLines = 10
      maxShownLines = 25    ## &lt;-------------
    #  KaTeX 数学公式 (https://katex.org)
    [params.page.math]
      enable = true
      # 默认行内定界符是 $ ... $ 和 \( ... \)
      inlineLeftDelimiter = &#34;&#34;
      inlineRightDelimiter = &#34;&#34;
      # 默认块定界符是 $$ ... $$, \[ ... \],  \begin{equation} ... \end{equation} 和一些其它的函数
      blockLeftDelimiter = &#34;&#34;
      blockRightDelimiter = &#34;&#34;
      # KaTeX 插件 copy_tex
      copyTex = true
      # KaTeX 插件 mhchem
      mhchem = true
    #  Mapbox GL JS 配置 (https://docs.mapbox.com/mapbox-gl-js)
    ```

## 数学公式

# hugo.toml

```toml
title = &#34;William&#34;
# baseURL = &#34;http://example.org/&#34;
baseURL = &#34;https://williamlfang.github.io/&#34;
# 网站语言，仅在这里 CN 大写 [&#34;en&#34;, &#34;zh-CN&#34;, &#34;fr&#34;, &#34;pl&#34;, ...]
defaultContentLanguage = &#34;zh-cn&#34;
languageCode = &#34;zh-CN&#34;
# 是否包括中日韩文字
hasCJKLanguage = true

## ---------------------------------------------------------------------------&gt;[theme]
# 更改使用 Hugo 构建网站时使用的默认主题
theme = &#34;FixIt&#34;
## ---------------------------------------------------------------------------&lt;[theme]


# [menu]
#   [[menu.main]]
#     identifier = &#34;posts&#34;
#     name = &#34;文章&#34;
#     url = &#34;/posts/&#34;
#     weight = 1
#   [[menu.main]]
#     identifier = &#34;categories&#34;
#     name = &#34;分类&#34;
#     url = &#34;/categories/&#34;
#     title = &#34;&#34;
#     weight = 2
#   [[menu.main]]
#     identifier = &#34;tags&#34;
#     name = &#34;标签&#34;
#     url = &#34;/tags/&#34;
#     weight = 3
#
#   [[menu.main]]
#     identifier = &#34;about&#34;
#     name = &#34;关于&#34;
#     url = &#34;about/&#34;
#     weight = 20
#     icon = &#34;fa-solid fa-signature&#34;
#     [[menu.main.params]]
#         icon = &#34;fa-solid fa-signature&#34;

[menu]
  [[menu.main]]
    identifier = &#34;posts&#34;
    parent = &#34;&#34;
    # you can add extra information before the name (HTML format is supported), such as icons
    pre = &#34;&#34;
    # you can add extra information after the name (HTML format is supported), such as icons
    post = &#34;&#34;
    name = &#34;文章&#34;
    url = &#34;/posts/&#34;
    # title will be shown when you hover on this menu link
    title = &#34;&#34;
    weight = 1
    # FixIt 0.2.14 | NEW add user-defined content to menu items
    [menu.main.params]
      # add css class to a specific menu item
      class = &#34;&#34;
      # whether set as a draft menu item whose function is similar to a draft post/page
      draft = false
      # FixIt 0.2.16 | NEW add fontawesome icon to a specific menu item
      icon = &#34;fa-regular fa-newspaper&#34;
      # FixIt 0.2.16 | NEW set menu item type, optional values: [&#34;mobile&#34;, &#34;desktop&#34;]
      type = &#34;&#34;
  [[menu.main]]
    identifier = &#34;archives&#34;
    parent = &#34;&#34;
    # you can add extra information before the name (HTML format is supported), such as icons
    pre = &#34;&#34;
    # you can add extra information after the name (HTML format is supported), such as icons
    post = &#34;&#34;
    name = &#34;归档&#34;
    url = &#34;/archives/&#34;
    # title will be shown when you hover on this menu link
    title = &#34;&#34;
    weight = 2
    # FixIt 0.2.14 | NEW add user-defined content to menu items
    [menu.main.params]
      # add css class to a specific menu item
      class = &#34;&#34;
      # whether set as a draft menu item whose function is similar to a draft post/page
      draft = false
      # FixIt 0.2.16 | NEW add fontawesome icon to a specific menu item
      icon = &#34;fa-solid fa-archive&#34;
      # FixIt 0.2.16 | NEW set menu item type, optional values: [&#34;mobile&#34;, &#34;desktop&#34;]
      type = &#34;&#34;
  [[menu.main]]
    identifier = &#34;categories&#34;
    parent = &#34;&#34;
    pre = &#34;&#34;
    post = &#34;&#34;
    name = &#34;分类&#34;
    url = &#34;/categories/&#34;
    title = &#34;&#34;
    weight = 3
    [menu.main.params]
      icon = &#34;fa-solid fa-folder-tree&#34;
  [[menu.main]]
    identifier = &#34;tags&#34;
    parent = &#34;&#34;
    pre = &#34;&#34;
    post = &#34;&#34;
    name = &#34;标签&#34;
    url = &#34;/tags/&#34;
    title = &#34;&#34;
    weight = 3
    [menu.main.params]
      icon = &#34;fa-solid fa-tags&#34;
  [[menu.main]]
    identifier = &#34;about&#34;
    parent = &#34;&#34;
    pre = &#34;&#34;
    post = &#34;&#34;
    name = &#34;关于&#34;
    url = &#34;/about/&#34;
    title = &#34;&#34;
    weight = 20
    [menu.main.params]
      icon = &#34;fa-solid fa-signature&#34;

[params]
  #  FixIt 主题版本
  version = &#34;0.2.X&#34; # 例如：&#34;0.2.X&#34;, &#34;0.2.15&#34;, &#34;v0.2.15&#34; 等
  # 网站描述
  # description = &#34;这是我的 Hugo FixIt 网站&#34;
  description = &#34;William&#34;
  # 网站关键词
  keywords = [&#34;Hugo&#34;, &#34;FixIt&#34;]
  # 网站默认主题样式 [&#34;light&#34;, &#34;dark&#34;, &#34;auto&#34;]
  defaultTheme = &#34;auto&#34;
  #  哪种哈希函数用来 SRI, 为空时表示不使用 SRI
  # [&#34;sha256&#34;, &#34;sha384&#34;, &#34;sha512&#34;, &#34;md5&#34;]
  fingerprint = &#34;&#34;
  #  日期格式
  dateFormat = &#34;2006-01-02&#34;
  # 网站图片，用于 Open Graph 和 Twitter Cards
  images = [&#34;/logo.png&#34;]
  #  开启 PWA 支持
  enablePWA = true
  #  是否自动显示外链图标
  externalIcon = false
  #  是否反转导航菜单的顺序
  navigationReverse = false
  #  是否在每个页面标题中添加网站标题
  # 请记得在 `hugo.toml` 中设置网站标题 (例如 title = &#34;title&#34;)
  withSiteTitle = true
  #  当网站标题被添加到每个页面标题时的标题分隔符
  titleDelimiter = &#34;-&#34;
  #  是否在主页标题中添加网站副标题
  # 请记得通过 `params.header.subtitle.name` 设置网站副标题
  indexWithSubtitle = false
  #  默认情况下，FixIt 只会在主页的 HTML 头中注入主题元标记
  # 你可以将其关闭，但如果你不这样做，我们将不胜感激，因为这是观察 FixIt 受欢迎程度上升的好方法
  disableThemeInject = false

  # 作者配置
  [params.author]
    name = &#34;&#34;
    email = &#34;&#34;
    link = &#34;&#34;
    avatar = &#34;&#34;

  #  公共 Git 仓库信息，仅在 enableGitInfo 设为 true 时有效
  [params.gitInfo]
    # 例如 &#34;https://github.com/hugo-fixit/docs&#34;
    repo = &#34;&#34;
    branch = &#34;main&#34;
    # 相对于仓库根目录的内容目录路径
    dir = &#34;content&#34;
    # 用于报告文章问题的 issue 模板
    # 可用模板参数：{title} {URL} {sourceURL}
    issueTpl = &#34;title=[BUG]%20{title}&amp;body=|Field|Value|%0A|-|-|%0A|Title|{title}|%0A|URL|{URL}|%0A|Filename|{sourceURL}|&#34;

  #  应用图标配置
  [params.app]
    # 当添加到 iOS 主屏幕或者 Android 启动器时的标题，覆盖默认标题
    title = &#34;FixIt&#34;
    # 是否隐藏网站图标资源链接
    noFavicon = false
    # 更现代的 SVG 网站图标，可替代旧的 .png 和 .ico 文件
    svgFavicon = &#34;&#34;
    # Safari 图标颜色
    iconColor = &#34;#5bbad5&#34;
    # Windows v8-10 磁贴颜色
    tileColor = &#34;#da532c&#34;
    #  Android 浏览器主题色
    [params.app.themeColor]
      light = &#34;#f8f8f8&#34;
      dark = &#34;#252627&#34;

  #  搜索配置
  [params.search]
    enable = true
    # 搜索引擎的类型 [&#34;algolia&#34;, &#34;fuse&#34;]
    type = &#34;fuse&#34;
    # 文章内容最长索引长度
    contentLength = 4000
    # 搜索框的占位提示语
    placeholder = &#34;&#34;
    #  最大结果数目
    maxResultLength = 10
    #  结果内容片段长度
    snippetLength = 50
    #  搜索结果中高亮部分的 HTML 标签
    highlightTag = &#34;em&#34;
    #  是否在搜索索引中使用基于 baseURL 的绝对路径
    absoluteURL = false
    [params.search.algolia]
      index = &#34;&#34;
      appID = &#34;&#34;
      searchKey = &#34;&#34;
    [params.search.fuse]
      #  https://fusejs.io/api/options.html
      isCaseSensitive = false
      minMatchCharLength = 2
      findAllMatches = false
      location = 0
      threshold = 0.3
      distance = 100
      ignoreLocation = false
      useExtendedSearch = false
      ignoreFieldNorm = false

  # 页面头部导航栏配置
  [params.header]
    #  桌面端导航栏模式 [&#34;sticky&#34;, &#34;normal&#34;, &#34;auto&#34;]
    desktopMode = &#34;sticky&#34;
    #  移动端导航栏模式 [&#34;sticky&#34;, &#34;normal&#34;, &#34;auto&#34;]
    mobileMode = &#34;auto&#34;
    #  页面头部导航栏标题配置
    [params.header.title]
      # LOGO 的 URL
      # logo = &#34;/images/fixit.min.svg&#34;
      logo = &#34;&#34;
      # 标题名称
      # name = &#34;我的 Hugo FixIt 网站&#34;
      name = &#34;William&#34;
      # 你可以在名称（允许 HTML 格式）之前添加其他信息，例如图标
      pre = &#34;&#34;
      # 你可以在名称（允许 HTML 格式）之后添加其他信息，例如图标
      post = &#34;&#34;
      #  是否为标题显示打字机动画
      typeit = false
    #  页面头部导航栏副标题配置
    [params.header.subtitle]
      # 副标题名称
      name = &#34;&#34;
      # 是否为副标题显示打字机动画
      typeit = false

  #  面包屑导航配置
  [params.breadcrumb]
    enable = false
    sticky = false
    showHome = false

  # 页面底部信息配置
  [params.footer]
    enable = true
    #  自定义内容（支持 HTML 格式）
    # 进阶使用，见参数 `params.customFilePath.footer`
    custom = &#34;&#34;
    #  是否显示版权信息
    copyright = true
    #  是否显示作者
    author = true
    # 网站创立年份
    since = 2013
    #  公网安备信息，仅在中国使用（支持 HTML 格式）
    gov = &#34;&#34;
    #  ICP 备案信息，仅在中国使用（支持 HTML 格式）
    icp = &#34;&#34;
    # 许可协议信息（支持 HTML 格式）
    license = &#39;&lt;a rel=&#34;license external nofollow noopener noreferrer&#34; href=&#34;https://creativecommons.org/licenses/by-nc-sa/4.0/&#34; target=&#34;_blank&#34;&gt;CC BY-NC-SA 4.0&lt;/a&gt;&#39;
    #  是否显示 Hugo 和主题信息
    [params.footer.powered]
      enable = true
      hugoLogo = true
      themeLogo = true
    #  网站创立时间
    [params.footer.siteTime]
      enable = true
      animate = true
      icon = &#34;fa-solid fa-heartbeat&#34;
      pre = &#34;&#34;
      value = &#34;&#34; # e.g. &#34;2021-12-18T16:15:22&#43;08:00&#34;
    #  页面底部行排序，可选值：[&#34;first&#34;, 0, 1, 2, 3, 4, 5, &#34;last&#34;]
    [params.footer.order]
      powered = 0
      copyright = 0
      statistics = 0
      visitor = 0
      beian = 0

  #  Section（所有文章）页面配置
  [params.section]
    # section 页面每页显示文章数量
    paginate = 20
    # 日期格式（月和日）
    dateFormat = &#34;01-02&#34;
    # RSS 文章数目
    rss = 10
    #  最近更新文章设置
    [params.section.recentlyUpdated]
      enable = true
      rss = true
      days = 30
      maxCount = 10

  #  List（目录或标签）页面配置
  [params.list]
    # list 页面每页显示文章数量
    paginate = 20
    # 日期格式（月和日）
    dateFormat = &#34;01-02&#34;
    # RSS 文章数目
    rss = 10

  #  标签云配置
  [params.tagcloud]
    enable = false
    min = 14 # 最小字体大小，单位：px
    max = 32 # 最大字体大小，单位：px
    peakCount = 10 # 每个标签的最大文章数
    orderby = &#34;name&#34; # 标签排序方式，可选值：[&#34;name&#34;, &#34;count&#34;]

  # 主页配置
  [params.home]
    #  RSS 文章数目
    rss = 10
    # 主页个人信息
    [params.home.profile]
      enable = true
      # Gravatar 邮箱，用于优先在主页显示的头像
      gravatarEmail = &#34;&#34;
      # 主页显示头像的 URL
      # public/images/ =&gt; themes/FixIt/assets/images
      avatarURL = &#34;/images/william.jpg&#34;
      #  头像菜单链接的 identifier
      avatarMenu = &#34;&#34;
      #  主页显示的网站标题（支持 HTML 格式）
      title = &#34;&#34;
      # 主页显示的网站副标题
      # subtitle = &#34;这是我的 Hugo FixIt 网站&#34;
      subtitle = &#34;Keep Calm and Markdown.&#34;
      # 是否为副标题显示打字机动画
      typeit = true
      # 是否显示社交账号
      social = true
      #  免责声明（支持 HTML 格式）
      disclaimer = &#34;&#34;
    # 主页文章列表
    [params.home.posts]
      enable = true
      # 主页每页显示文章数量
      paginate = 6

  #  作者的社交信息设置
  [params.social]
    GitHub = &#34;williamlfang&#34;
    Linkedin = &#34;&#34;
    Twitter = &#34;&#34;
    Instagram = &#34;&#34;
    Facebook = &#34;&#34;
    Telegram = &#34;&#34;
    Medium = &#34;&#34;
    Gitlab = &#34;&#34;
    Youtubelegacy = &#34;&#34;
    Youtubecustom = &#34;&#34;
    Youtubechannel = &#34;&#34;
    Tumblr = &#34;&#34;
    Quora = &#34;&#34;
    Keybase = &#34;&#34;
    Pinterest = &#34;&#34;
    Reddit = &#34;&#34;
    Codepen = &#34;&#34;
    FreeCodeCamp = &#34;&#34;
    Bitbucket = &#34;&#34;
    Stackoverflow = &#34;&#34;
    Weibo = &#34;&#34;
    Odnoklassniki = &#34;&#34;
    VK = &#34;&#34;
    Flickr = &#34;&#34;
    Xing = &#34;&#34;
    Snapchat = &#34;&#34;
    Soundcloud = &#34;&#34;
    Spotify = &#34;&#34;
    Bandcamp = &#34;&#34;
    Paypal = &#34;&#34;
    Fivehundredpx = &#34;&#34;
    Mix = &#34;&#34;
    Goodreads = &#34;&#34;
    Lastfm = &#34;&#34;
    Foursquare = &#34;&#34;
    Hackernews = &#34;&#34;
    Kickstarter = &#34;&#34;
    Patreon = &#34;&#34;
    Steam = &#34;&#34;
    Twitch = &#34;&#34;
    Strava = &#34;&#34;
    Skype = &#34;&#34;
    Whatsapp = &#34;&#34;
    Zhihu = &#34;&#34;
    Douban = &#34;&#34;
    Angellist = &#34;&#34;
    Slidershare = &#34;&#34;
    Jsfiddle = &#34;&#34;
    Deviantart = &#34;&#34;
    Behance = &#34;&#34;
    Dribbble = &#34;&#34;
    Wordpress = &#34;&#34;
    Vine = &#34;&#34;
    Googlescholar = &#34;&#34;
    Researchgate = &#34;&#34;
    Mastodon = &#34;&#34;
    Thingiverse = &#34;&#34;
    Devto = &#34;&#34;
    Gitea = &#34;&#34;
    XMPP = &#34;&#34;
    Matrix = &#34;&#34;
    Bilibili = &#34;&#34;
    ORCID = &#34;&#34;
    Liberapay = &#34;&#34;
    Ko-Fi = &#34;&#34;
    BuyMeaCoffee = &#34;&#34;
    Linktree = &#34;&#34;
    QQ = &#34;&#34;
    QQGroup = &#34;&#34; # https://qun.qq.com/join.html
    Diaspora = &#34;&#34;
    CSDN = &#34;&#34;
    Discord = &#34;&#34;
    DiscordInvite = &#34;&#34;
    Lichess = &#34;&#34;
    Pleroma = &#34;&#34;
    Kaggle = &#34;&#34;
    MediaWiki= &#34;&#34;
    Plume = &#34;&#34;
    HackTheBox = &#34;&#34;
    RootMe = &#34;&#34;
    Feishu = &#34;&#34;
    TryHackMe = &#34;&#34;
    Phone = &#34;&#34;
    Email = &#34;&#34;
    RSS = true

  #  文章页面配置
  [params.page]
    #  是否启用文章作者头像
    authorAvatar = true
    #  是否在主页隐藏一篇文章
    hiddenFromHomePage = false
    #  是否在搜索结果中隐藏一篇文章
    hiddenFromSearch = false
    #  是否在 RSS 中隐藏一篇文章
    hiddenFromRss = false
    #  是否在相关文章中隐藏一篇文章
    hiddenFromRelated = false
    #  是否使用 twemoji
    twemoji = false
    # 是否使用 lightgallery
    #  如果设为 &#34;force&#34;，文章中的图片将强制按照画廊形式呈现
    lightgallery = true
    #  是否使用 ruby 扩展语法
    ruby = true
    #  是否使用 fraction 扩展语法
    fraction = true
    #  是否使用 fontawesome 扩展语法
    fontawesome = true
    # 许可协议信息（支持 HTML 格式）
    license = &#39;&lt;a rel=&#34;license external nofollow noopener noreferrer&#34; href=&#34;https://creativecommons.org/licenses/by-nc-sa/4.0/&#34; target=&#34;_blank&#34;&gt;CC BY-NC-SA 4.0&lt;/a&gt;&#39;
    # 是否显示原始 Markdown 文档内容的链接
    linkToMarkdown = true
    #  是否显示查看文章源码的链接
    linkToSource = true
    #  是否显示编辑文章的链接
    linkToEdit = true
    #  是否显示报告文章问题的链接
    linkToReport = true
    #  是否在 RSS 中显示全文内容
    rssFullText = false
    #  页面样式 [&#34;narrow&#34;, &#34;normal&#34;, &#34;wide&#34;, ...]
    pageStyle = &#34;normal&#34;
    #   强制使用 Gravatar 作为作者头像
    # gravatarForce = true
    #  开启自动书签支持
    # 如果为 true，则在关闭页面时保存阅读进度
    autoBookmark = true
    #  是否使用 字数统计
    wordCount = true
    #  是否使用 预计阅读
    readingTime = true
    #  文章结束标志
    endFlag = &#34;&#34;
    #  是否开启即时页面
    instantPage = false
    #  是否在侧边栏显示集合列表
    collectionList = false
    #  是否在文章末尾显示集合导航
    collectionNavigation = false

    #  转载配置
    [params.page.repost]
      enable = false
      url = &#34;&#34;
    #  目录配置
    [params.page.toc]
      # 是否使用目录
      enable = true
      #  是否保持使用文章前面的静态目录
      keepStatic = false
      # 是否使侧边目录自动折叠展开
      auto = true
      #  目录位置 [&#34;left&#34;, &#34;right&#34;]
      position = &#34;right&#34;
    #  在文章开头显示提示信息，提醒读者文章内容可能过时
    [params.page.expirationReminder]
      enable = false
      # 如果文章最后更新于这天数之前，显示提醒
      reminder = 90
      # 如果文章最后更新于这天数之前，显示警告
      warning = 180
      # 如果文章到期是否关闭评论
      closeComment = false
    #  页面标题配置
    [params.page.heading]
      # 配合 `markup.tableOfContents.ordered` 参数使用
      [params.page.heading.number]
        # 是否启用自动标题编号
        enable = false
        [params.page.heading.number.format]
          h1 = &#34;{title}&#34;
          h2 = &#34;{h2} {title}&#34;
          h3 = &#34;{h2}.{h3} {title}&#34;
          h4 = &#34;{h2}.{h3}.{h4} {title}&#34;
          h5 = &#34;{h2}.{h3}.{h4}.{h5} {title}&#34;
          h6 = &#34;{h2}.{h3}.{h4}.{h5}.{h6} {title}&#34;
    #  代码配置
    [params.page.code]
      # 是否显示代码块的复制按钮
      copy = true
      #  是否显示代码块的编辑按钮
      edit = true
      # 默认展开显示的代码行数
      # maxShownLines = 10
      maxShownLines = 25
    #  KaTeX 数学公式 (https://katex.org)
    [params.page.math]
      enable = true
      # 默认行内定界符是 $ ... $ 和 \( ... \)
      inlineLeftDelimiter = &#34;&#34;
      inlineRightDelimiter = &#34;&#34;
      # 默认块定界符是 $$ ... $$, \[ ... \],  \begin{equation} ... \end{equation} 和一些其它的函数
      blockLeftDelimiter = &#34;&#34;
      blockRightDelimiter = &#34;&#34;
      # KaTeX 插件 copy_tex
      copyTex = true
      # KaTeX 插件 mhchem
      mhchem = true
    #  Mapbox GL JS 配置 (https://docs.mapbox.com/mapbox-gl-js)
    [params.page.mapbox]
      # Mapbox GL JS 的 access token
      accessToken = &#34;&#34;
      # 浅色主题的地图样式
      lightStyle = &#34;mapbox://styles/mapbox/light-v9&#34;
      # 深色主题的地图样式
      darkStyle = &#34;mapbox://styles/mapbox/dark-v9&#34;
      # 是否添加 NavigationControl
      navigation = true
      # 是否添加 GeolocateControl
      geolocate = true
      # 是否添加 ScaleControl
      scale = true
      # 是否添加 FullscreenControl
      fullscreen = true
    #  [试验性功能] 缓存图床图片到本地，详见：https://github.com/hugo-fixit/FixIt/pull/362
    [params.page.cacheRemoteImages]
      enable = false
      # 用本地图片链接替换远程图片链接 (放置在 public/images/remote/)
      replace = false
    #  相关内容配置 (https://gohugo.io/content-management/related/)
    [params.page.related]
      enable = false
      count = 5
    #  赞赏设置
    [params.page.reward]
      enable = false
      animation = false
      # 相对于页脚的位置，可选值：[&#34;before&#34;, &#34;after&#34;]
      position = &#34;after&#34;
      # comment = &#34;Buy me a coffee&#34;
      #  二维码图片展示模式，可选值：[&#34;static&#34;, &#34;fixed&#34;]，默认：`static`
      mode = &#34;static&#34;
      [params.page.reward.ways]
        # wechatpay = &#34;/images/wechatpay.png&#34;
        # alipay = &#34;/images/alipay.png&#34;
        # paypal = &#34;/images/paypal.png&#34;
        # bitcoin = &#34;/images/bitcoin.png&#34;
    #  文章页面的分享信息设置
    [params.page.share]
      enable = true
      Twitter = true
      Facebook = true
      Linkedin = true
      Whatsapp = true
      Pinterest = false
      Tumblr = false
      HackerNews = false
      Reddit = true
      VK = false
      Buffer = false
      Xing = false
      Line = false
      Instapaper = false
      Pocket = false
      Flipboard = false
      Weibo = true
      Myspace = false
      Blogger = false
      Baidu = true
      Odnoklassniki = false
      Evernote = true
      Skype = false
      Trello = false
      Mix = false
    #  评论系统设置
    [params.page.comment]
      enable = false
      #  Artalk 评论系统设置 (https://artalk.js.org/)
      [params.page.comment.artalk]
        enable = false
        server = &#34;https://yourdomain&#34;
        site = &#34;默认站点&#34;
        placeholder = &#34;&#34;
        noComment = &#34;&#34;
        sendBtn = &#34;&#34;
        editorTravel = true
        flatMode = &#34;auto&#34;
        #  启用 lightgallery 支持
        lightgallery = false
        locale = &#34;&#34; #
        #
        emoticons = &#34;&#34;
        nestMax = 2
        nestSort = &#34;DATE_ASC&#34; # [&#34;DATE_ASC&#34;, &#34;DATE_DESC&#34;, &#34;VOTE_UP_DESC&#34;]
        vote = true
        voteDown = false
        uaBadge = true
        listSort = true
        imgUpload = true
        preview = true
        versionCheck = true
      #  Disqus 评论系统设置 (https://disqus.com)
      [params.page.comment.disqus]
        enable = false
        # Disqus 的 shortname，用来在文章中启用 Disqus 评论系统
        shortname = &#34;&#34;
      #  Gitalk 评论系统设置 (https://github.com/gitalk/gitalk)
      [params.page.comment.gitalk]
        enable = false
        owner = &#34;&#34;
        repo = &#34;&#34;
        clientId = &#34;&#34;
        clientSecret = &#34;&#34;
      # Valine 评论系统设置 (https://github.com/xCss/Valine)
      [params.page.comment.valine]
        enable = false
        appId = &#34;&#34;
        appKey = &#34;&#34;
        placeholder = &#34;&#34;
        avatar = &#34;mp&#34;
        meta = &#34;&#34;
        requiredFields = &#34;&#34;
        pageSize = 10
        lang = &#34;&#34;
        visitor = true
        recordIP = true
        highlight = true
        enableQQ = false
        serverURLs = &#34;&#34;
        #  emoji 数据文件名称，默认是 &#34;google.yml&#34;
        # [&#34;apple.yml&#34;, &#34;google.yml&#34;, &#34;facebook.yml&#34;, &#34;twitter.yml&#34;]
        # 位于 &#34;themes/FixIt/assets/lib/valine/emoji/&#34; 目录
        # 可以在你的项目下相同路径存放你自己的数据文件：
        # &#34;assets/lib/valine/emoji/&#34;
        emoji = &#34;&#34;
        commentCount = true #
      #  Waline 评论系统设置 (https://waline.js.org)
      [params.page.comment.waline]
        enable = false
        serverURL = &#34;&#34;
        pageview = false #
        emoji = [&#34;//unpkg.com/@waline/emojis@1.1.0/weibo&#34;]
        meta = [&#34;nick&#34;, &#34;mail&#34;, &#34;link&#34;]
        requiredMeta = []
        login = &#34;enable&#34;
        wordLimit = 0
        pageSize = 10
        imageUploader = false #
        highlighter = false #
        comment = false #
        texRenderer = false #
        search = false #
        recaptchaV3Key = &#34;&#34; #
        reaction = false #
      # Facebook 评论系统设置 (https://developers.facebook.com/docs/plugins/comments)
      [params.page.comment.facebook]
        enable = false
        width = &#34;100%&#34;
        numPosts = 10
        appId = &#34;&#34;
        languageCode = &#34;zh_CN&#34;
      #  Telegram Comments 评论系统设置 (https://comments.app)
      [params.page.comment.telegram]
        enable = false
        siteID = &#34;&#34;
        limit = 5
        height = &#34;&#34;
        color = &#34;&#34;
        colorful = true
        dislikes = false
        outlined = false
      #  Commento 评论系统设置 (https://commento.io)
      [params.page.comment.commento]
        enable = false
      #  Utterances 评论系统设置 (https://utteranc.es)
      [params.page.comment.utterances]
        enable = false
        # owner/repo
        repo = &#34;&#34;
        issueTerm = &#34;pathname&#34;
        label = &#34;&#34;
        lightTheme = &#34;github-light&#34;
        darkTheme = &#34;github-dark&#34;
      #  Twikoo 评论系统设置 (https://twikoo.js.org/)
      [params.page.comment.twikoo]
        enable = false
        envId = &#34;&#34;
        region = &#34;&#34;
        path = &#34;&#34;
        visitor = true
        commentCount = true
        #  启用 lightgallery 支持
        lightgallery = false
        #  启用 Katex 支持
        katex = false
      #  Giscus 评论系统设置
      [params.page.comment.giscus]
        enable = false
        repo = &#34;&#34;
        repoId = &#34;&#34;
        category = &#34;&#34;
        categoryId = &#34;&#34;
        mapping = &#34;&#34;
        strict = &#34;0&#34; #
        term = &#34;&#34;
        reactionsEnabled = &#34;1&#34;
        emitMetadata = &#34;0&#34;
        inputPosition = &#34;bottom&#34; # [&#34;top&#34;, &#34;bottom&#34;]
        lightTheme = &#34;light&#34;
        darkTheme = &#34;dark&#34;
        lazyLoad = true
    #  第三方库配置
    [params.page.library]
      [params.page.library.css]
        # someCSS = &#34;some.css&#34;
        # 位于 &#34;assets/&#34;
        # 或者
        # someCSS = &#34;https://cdn.example.com/some.css&#34;
      [params.page.library.js]
        # someJavascript = &#34;some.js&#34;
        # 位于 &#34;assets/&#34;
        # 或者
        # someJavascript = &#34;https://cdn.example.com/some.js&#34;
    #  页面 SEO 配置
    [params.page.seo]
      # 图片 URL
      images = []
      # 出版者信息
      [params.page.seo.publisher]
        name = &#34;&#34;
        logoUrl = &#34;&#34;

  #  TypeIt 配置
  [params.typeit]
    # 每一步的打字速度（单位是毫秒）
    speed = 100
    # 光标的闪烁速度（单位是毫秒）
    cursorSpeed = 1000
    # 光标的字符（支持 HTML 格式）
    cursorChar = &#34;|&#34;
    # 打字结束之后光标的持续时间（单位是毫秒，&#34;-1&#34; 代表无限大）
    duration = -1
    #  打字完成后是否会连续循环
    loop = false

  #  Mermaid 配置
  [params.mermaid]
    # 取值详见 https://mermaid.js.org/config/theming.html#available-themes
    themes = [&#34;default&#34;, &#34;dark&#34;]
    # themes = [&#34;auto&#34;]

  #  盘古之白配置
  [params.pangu]
    # 适用于中文写作用户
    enable = false
    selector = &#34;article&#34; #

  #  水印配置
  # 详细参数见 https://github.com/Lruihao/watermark#readme
  [params.watermark]
    enable = false
    # 水印内容（允许 HTML 格式）
    content = &#34;&#34;
    # 水印透明度
    opacity = 0.1
    # 单水印宽度 单位：px
    width = 150
    # 单水印高度 单位：px
    height = 20
    # 水印行间距 单位：px
    rowSpacing = 60
    # 水印列间距 单位：px
    colSpacing = 30
    # 水印旋转角度 单位：deg
    rotate = 15
    # 水印字体大小，单位：rem
    fontSize = 0.85
    #  水印字体
    fontFamily = &#34;inherit&#34;

  #  不蒜子统计
  [params.ibruce]
    enable = true
    # 在文章中开启
    enablePost = false

  # 网站验证代码，用于 Google/Bing/Yandex/Pinterest/Baidu/360/Sogou
  [params.verification]
    google = &#34;&#34;
    bing = &#34;&#34;
    yandex = &#34;&#34;
    pinterest = &#34;&#34;
    baidu = &#34;&#34;
    so = &#34;&#34;
    sogou = &#34;&#34;

  #  网站 SEO 配置
  [params.seo]
    # 图片 URL
    image = &#34;&#34;
    # 缩略图 URL
    thumbnailUrl = &#34;&#34;

  #  网站分析配置
  [params.analytics]
    enable = false
    # Google Analytics
    [params.analytics.google]
      id = &#34;&#34;
      # 是否匿名化用户 IP
      anonymizeIP = true
    # Fathom Analytics
    [params.analytics.fathom]
      id = &#34;&#34;
      # 自行托管追踪器时的主机路径
      server = &#34;&#34;

  #  Cookie 许可配置
  [params.cookieconsent]
    enable = true
    # 用于 Cookie 许可横幅的文本字符串
    [params.cookieconsent.content]
      message = &#34;&#34;
      dismiss = &#34;&#34;
      link = &#34;&#34;

  #  第三方库文件的 CDN 设置
  [params.cdn]
    # CDN 数据文件名称，默认不启用 [&#34;jsdelivr.yml&#34;, &#34;unpkg.yml&#34;, ...]
    # 位于 &#34;themes/FixIt/assets/data/cdn/&#34; 目录
    # 可以在你的项目下相同路径存放你自己的数据文件：&#34;assets/data/cdn/&#34;
    # data = &#34;unpkg.yml&#34;

  #  兼容性设置
  [params.compatibility]
    # 是否使用 Polyfill.io 来兼容旧式浏览器
    polyfill = false
    # 是否使用 object-fit-images 来兼容旧式浏览器
    objectFit = false

  #  在左上角或者右上角显示 GitHub 开源链接
  [params.githubCorner]
    enable = false
    permalink = &#34;https://github.com/hugo-fixit/FixIt&#34;
    title = &#34;在 GitHub 上查看源代码&#34;
    position = &#34;right&#34; # [&#34;left&#34;, &#34;right&#34;]

  #  Gravatar 设置
  [params.gravatar]
    #  取决于作者邮箱，作者邮箱未设置则使用本地头像
    enable = false
    # Gravatar 主机，默认：“www.gravatar.com”
    host = &#34;www.gravatar.com&#34; # [&#34;cn.gravatar.com&#34;, &#34;gravatar.loli.net&#34;, ...]
    style = &#34;&#34; # [&#34;&#34;, &#34;mp&#34;, &#34;identicon&#34;, &#34;monsterid&#34;, &#34;wavatar&#34;, &#34;retro&#34;, &#34;blank&#34;, &#34;robohash&#34;]

  #  返回顶部
  [params.backToTop]
    enable = true
    # 在 b2t 按钮中显示滚动百分比
    scrollpercent = false

  #  阅读进度条
  [params.readingProgress]
    enable = false
    # 可用值：[&#34;left&#34;, &#34;right&#34;]
    start = &#34;left&#34;
    # 可用值：[&#34;top&#34;, &#34;bottom&#34;]
    position = &#34;top&#34;
    reversed = false
    light = &#34;&#34;
    dark = &#34;&#34;
    height = &#34;2px&#34;

  #  页面加载期间顶部的进度条
  # 有关详细信息：https://github.com/CodeByZach/pace
  [params.pace]
    enable = false
    # 所有可用颜色：
    # [&#34;black&#34;, &#34;blue&#34;, &#34;green&#34;, &#34;orange&#34;, &#34;pink&#34;, &#34;purple&#34;, &#34;red&#34;, &#34;silver&#34;, &#34;white&#34;, &#34;yellow&#34;]
    color = &#34;blue&#34;
    # 所有可用主题：
    # [&#34;barber-shop&#34;, &#34;big-counter&#34;, &#34;bounce&#34;, &#34;center-atom&#34;, &#34;center-circle&#34;, &#34;center-radar&#34;, &#34;center-simple&#34;,
    # &#34;corner-indicator&#34;, &#34;fill-left&#34;, &#34;flash&#34;, &#34;flat-top&#34;, &#34;loading-bar&#34;, &#34;mac-osx&#34;, &#34;material&#34;, &#34;minimal&#34;]
    theme = &#34;minimal&#34;

  #  定义自定义文件路径
  # 在站点目录 `layouts/partials/custom` 中创建你的自定义文件，并取消注释下面需要的文件
  [params.customFilePath]
    # aside = &#34;custom/aside.html&#34;
    # profile = &#34;custom/profile.html&#34;
    # footer = &#34;custom/footer.html&#34;

  #  开发者选项
  [params.dev]
    enable = false
    # 检查更新
    c4u = false
    # 请勿公开展示！
    githubToken = &#34;&#34;
    # 移动端开发者工具配置
    [params.dev.mDevtools]
      enable = false
      # 支持 &#34;vConsole&#34;, &#34;eruda&#34;
      type = &#34;vConsole&#34;

# Hugo 解析文档的配置
[markup]
  # 语法高亮设置 (https://gohugo.io/content-management/syntax-highlighting)
  [markup.highlight]
    ################## 必要的配置 ##################
    # https://github.com/hugo-fixit/FixIt/issues/43
    codeFences = true
    lineNos = true
    lineNumbersInTable = true
    noClasses = false
    ################## 必要的配置 ##################
    guessSyntax = true
  # Goldmark 是 Hugo 0.60 以来的默认 Markdown 解析库
  [markup.goldmark]
    [markup.goldmark.extensions]
      definitionList = true
      footnote = true
      linkify = true
      strikethrough = true
      table = true
      taskList = true
      typographer = true
    [markup.goldmark.renderer]
      # 是否在文档中直接使用 HTML 标签
      unsafe = true
  # 目录设置
  [markup.tableOfContents]
    startLevel = 1
    endLevel = 6

# 网站地图配置
[sitemap]
  changefreq = &#34;weekly&#34;
  filename = &#34;sitemap.xml&#34;
  priority = 0.5

# Permalinks 配置 (https://gohugo.io/content-management/urls#permalinks)
[Permalinks]
  # posts = &#34;:year/:month/:filename&#34;
  posts = &#34;:filename&#34;

# 隐私信息配置 (https://gohugo.io/about/hugo-and-gdpr/)
[privacy]
  [privacy.twitter]
    enableDNT = true
  [privacy.youtube]
    privacyEnhanced = true

#
[mediaTypes]
  # 用于输出 Markdown 格式文档的设置
  [mediaTypes.&#34;text/markdown&#34;]
    suffixes = [&#34;md&#34;]
  # 用于输出 txt 格式文档的设置
  [mediaTypes.&#34;text/plain&#34;]
    suffixes = [&#34;txt&#34;]

[outputFormats]
  # 用于输出 Markdown 格式文档的设置
  [outputFormats.MarkDown]
    mediaType = &#34;text/markdown&#34;
    isPlainText = true
    isHTML = false
  #  用于输出 /archives/index.html 文件的设置
  [outputFormats.archives]
    path = &#34;archives&#34;
    baseName = &#34;index&#34;
    mediaType = &#34;text/html&#34;
    isPlainText = false
    isHTML = true
    permalinkable = true
  #  用于输出 /offline/index.html 文件的设置
  [outputFormats.offline]
    path = &#34;offline&#34;
    baseName = &#34;index&#34;
    mediaType = &#34;text/html&#34;
    isPlainText = false
    isHTML = true
    permalinkable = true
  #  用于输出 readme.md 文件的设置
  [outputFormats.README]
    baseName = &#34;readme&#34;
    mediaType = &#34;text/markdown&#34;
    isPlainText = true
    isHTML = false
  #  用于输出 baidu_urls.txt 文件的设置
  [outputFormats.baidu_urls]
    baseName = &#34;baidu_urls&#34;
    mediaType = &#34;text/plain&#34;
    isPlainText = true
    isHTML = false

# 用于 Hugo 输出文档的设置，可选值如下：
# home: [&#34;HTML&#34;, &#34;RSS&#34;, &#34;JSON&#34;, &#34;archives&#34;, &#34;offline&#34;, &#34;README&#34;, &#34;baidu_urls&#34;]
# page: [&#34;HTML&#34;, &#34;MarkDown&#34;]
# section: [&#34;HTML&#34;, &#34;RSS&#34;]
# taxonomy: [&#34;HTML&#34;, &#34;RSS&#34;]
# term: [&#34;HTML&#34;, &#34;RSS&#34;]
[outputs]
  home = [&#34;HTML&#34;, &#34;RSS&#34;, &#34;JSON&#34;, &#34;archives&#34;, &#34;offline&#34;]
  page = [&#34;HTML&#34;, &#34;MarkDown&#34;]
  section = [&#34;HTML&#34;, &#34;RSS&#34;]
  taxonomy = [&#34;HTML&#34;]
  term = [&#34;HTML&#34;, &#34;RSS&#34;]
```

# Ref

- [如何用 GitHub Pages &#43; Hugo 搭建个人博客](https://cuttontail.blog/blog/create-a-wesite-using-github-pages-and-hugo/)
- [FixIt Configuration](https://fixit-1vj5p4qii-lruihao.vercel.app/theme-documentation-basics/#site-configuration)
- [配置 Hugo-FixIt 主题：调整美化](https://www.newverse.wiki/knows/fixitmodify/)
- [DoIt 主题文档 - 扩展 Shortcodes](https://hugodoit.pages.dev/zh-cn/theme-documentation-extended-shortcodes/#showcase)


---

> 作者: william  
> URL: https://williamlfang.github.io/%E4%BD%BF%E7%94%A8hugo-github%E6%90%AD%E5%BB%BA%E5%8D%9A%E5%AE%A2/  

