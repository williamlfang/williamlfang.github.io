# RShiny 使用指南


# RShiny 是什么

`Shiny` 是一个 `R` 语言的软件包，提供了用于制作 `Web-UI/app` 的便捷工具。这些应用提供了交互式的数据展示、实时的统计分析与高度可定制化的操作界面，并且可以以网站或者独立的应用分享和发布。通过 `RShiny`，我们可以非常方便的与他人分享自己的数据研究成果，随时监控关心的信号指标。

可以访问 `RShiny` 的官网查看[案例集](https://shiny.rstudio.com/gallery/)，你会发现原来可以通过在 `R` 中调用简单的几个命令，就可以制作出如此精妙的 `Web-UI`，而不用再纠结与 `HTML-CSS-Javascript` 的细枝末节里。实在是「居家旅行、获奖无数」的必备良品。

&gt; 是不是很期待？来吧，接下来请接受代码的暴风雨。。。。。。

# 怎么使用

## 安装

由于 `Shiny` 会开启 `systemd` 网站服务，因此安装 `Shiny` 需要管理员 `root` 权限。

&gt; 当然，我们也可以在 `Docker` 中安装，然后把相关的 `3838` 端口转发出来，一样可以在外部访问该服务。

### 安装 shiny 包

```bash
## 1. Shiny 包安装，一定要使用 root 权限，才可以添加服务项
$ sudo su -c &#34;R -e \&#34;install.packages(&#39;shiny&#39;, repos=&#39;https://cran.rstudio.com/&#39;, dep=TRUE)\&#34;&#34;
```

### 安装 gdebi

```bash
## 2. 安装 gdebi（用于安装 Shiny Server 及其所有依赖项）和 Shiny Server
$ sudo apt-get install gdebi-core
$ wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
$ sudo gdebi shiny-server-1.5.14.948-amd64.deb
```

### 开启 shiny-server 服务

```bash
## 3. shiny-server 命令
#启动
$ sudo systemctl start shiny-server
#停止
$ sudo systemctl stop shiny-server
#重启
$ sudo systemctl restart shiny-server
#查看状态
$ sudo systemctl status shiny-server
#服务器重新初始化，但不会中断服务器当前进程或任何连接。

$ sudo systemctl kill -s HUP --kill-who=main shiny-server
$ sudo reload shiny-server
#shiny-server状态
$ sudo systemctl status shiny-server
```

### 查看安装

```bash
## 4. 查看 shiny-server: http://localhost:3838/
## 查看 demo: http://localhost:3838/sample-apps/hello/
```

### 配置

```bash
## 5. 配置
/etc/shiny-server/shiny-server.conf
/opt/shiny-server/config/default.config

# Instruct Shiny Server to run applications as the user &#34;shiny&#34;
run_as shiny;

# Define a server that listens on port 3838
server {
  #listen 3838;
  listen 3838 0.0.0.0;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /srv/shiny-server;

    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
}
```

### 添加用户

```bash
## 6. 创建用户
## sudo /opt/shiny-server/bin/sspasswd /etc/shiny-server/passwd admin

## 7. Rmarkdown
$ sudo su - -c &#34;R -e \&#34;install.packages(&#39;rmarkdown&#39;,repos=&#39;http://mirror.bjtu.edu.cn/cran/&#39;)\&#34;&#34;

## 8. 所有的 app 都放在 /srv/shiny-server

## 9. 外部可以访问 192.168.1.88:3838
```



## Demo

```R
library(shiny)
library(ggplot2)
library(ggthemes)
library(plotly)

ui &lt;- fluidPage(
    titlePanel(&#34;Plotly&#34;),
    sidebarLayout(
        sidebarPanel(),
        mainPanel(
            plotlyOutput(&#34;plot2&#34;))))

server &lt;- function(input, output) {

    output$plot2 &lt;- renderPlotly({
        print(
            ggplotly(
                ggplot(data = mtcars, aes(x = disp, y = cyl)) &#43;
                    geom_smooth(method = lm, formula = y~x) &#43; geom_point() &#43; theme_gdocs()
            )
        )

    })
}

shinyApp(ui, server)
```



## 技术细节

为了搭建 `Shiny` 服务，我们首先需要制作一个快加，把需要的元素放在这里

```R
library(shiny)

# Define UI ----
ui &lt;- fluidPage(

)

# Define server logic ----
server &lt;- function(input, output) {

}

# Run the app ----
shinyApp(ui = ui, server = server)
```

### ui 前端

```R
ui &lt;- fluidPage(
  titlePanel(&#34;title panel&#34;),

  sidebarLayout(
    position = &#34;right&#34;,
    sidebarPanel(&#34;sidebar panel&#34;),
    mainPanel(&#34;main panel&#34;)
  )
)
```

`titlePanel` and `sidebarLayout` are the two most popular elements to add to `fluidPage`. They create a basic Shiny app with a sidebar.

`sidebarLayout` always takes two arguments:

- `sidebarPanel` function output
- `mainPanel` function output

The sidebar panel will appear on the left side of your app by default. You can move it to the right side by giving `sidebarLayout` the optional argument `position = &#34;right&#34;`.

&gt; 布局可以参考：[Application layout guide](https://shiny.rstudio.com/articles/layout-guide.html)



| shiny function | HTML5 equivalent | creates                                          |
| :------------- | :--------------- | :----------------------------------------------- |
| `p`            | `&lt;p&gt;`            | A paragraph of text                              |
| `h1`           | `&lt;h1&gt;`           | A first level header                             |
| `h2`           | `&lt;h2&gt;`           | A second level header                            |
| `h3`           | `&lt;h3&gt;`           | A third level header                             |
| `h4`           | `&lt;h4&gt;`           | A fourth level header                            |
| `h5`           | `&lt;h5&gt;`           | A fifth level header                             |
| `h6`           | `&lt;h6&gt;`           | A sixth level header                             |
| `a`            | `&lt;a&gt;`            | A hyper link                                     |
| `br`           | `&lt;br&gt;`           | A line break (e.g. a blank line)                 |
| `div`          | `&lt;div&gt;`          | A division of text with a uniform style          |
| `span`         | `&lt;span&gt;`         | An in-line division of text with a uniform style |
| `pre`          | `&lt;pre&gt;`          | Text ‘as is’ in a fixed width font               |
| `code`         | `&lt;code&gt;`         | A formatted block of code                        |
| `img`          | `&lt;img&gt;`          | An image                                         |
| `strong`       | `&lt;strong&gt;`       | Bold text                                        |
| `em`           | `&lt;em&gt;`           | Italicized text                                  |
| `HTML`         |                  | Directly passes a character string as HTML code  |

### 输入

![](https://shiny.rstudio.com/tutorial/written-tutorial/lesson3/images/basic-widgets.png)

The standard Shiny widgets are:

| function             | widget                                         |
| :------------------- | :--------------------------------------------- |
| `actionButton`       | Action Button                                  |
| `checkboxGroupInput` | A group of check boxes                         |
| `checkboxInput`      | A single check box                             |
| `dateInput`          | A calendar to aid date selection               |
| `dateRangeInput`     | A pair of calendars for selecting a date range |
| `fileInput`          | A file upload control wizard                   |
| `helpText`           | Help text that can be added to an input form   |
| `numericInput`       | A field to enter numbers                       |
| `radioButtons`       | A set of radio buttons                         |
| `selectInput`        | A box with choices to select from              |
| `sliderInput`        | A slider bar                                   |
| `submitButton`       | A submit button                                |
| `textInput`          | A field to enter text                          |

```R
library(shiny)

# Define UI ----
ui &lt;- fluidPage(
  titlePanel(&#34;Basic widgets&#34;),

  fluidRow(

    column(3,
           h3(&#34;Buttons&#34;),
           actionButton(&#34;action&#34;, &#34;Action&#34;),
           br(),
           br(),
           submitButton(&#34;Submit&#34;)),

    column(3,
           h3(&#34;Single checkbox&#34;),
           checkboxInput(&#34;checkbox&#34;, &#34;Choice A&#34;, value = TRUE)),

    column(3,
           checkboxGroupInput(&#34;checkGroup&#34;,
                              h3(&#34;Checkbox group&#34;),
                              choices = list(&#34;Choice 1&#34; = 1,
                                             &#34;Choice 2&#34; = 2,
                                             &#34;Choice 3&#34; = 3),
                              selected = 1)),

    column(3,
           dateInput(&#34;date&#34;,
                     h3(&#34;Date input&#34;),
                     value = &#34;2014-01-01&#34;))
  ),

  fluidRow(

    column(3,
           dateRangeInput(&#34;dates&#34;, h3(&#34;Date range&#34;))),

    column(3,
           fileInput(&#34;file&#34;, h3(&#34;File input&#34;))),

    column(3,
           h3(&#34;Help text&#34;),
           helpText(&#34;Note: help text isn&#39;t a true widget,&#34;,
                    &#34;but it provides an easy way to add text to&#34;,
                    &#34;accompany other widgets.&#34;)),

    column(3,
           numericInput(&#34;num&#34;,
                        h3(&#34;Numeric input&#34;),
                        value = 1))
  ),

  fluidRow(

    column(3,
           radioButtons(&#34;radio&#34;, h3(&#34;Radio buttons&#34;),
                        choices = list(&#34;Choice 1&#34; = 1, &#34;Choice 2&#34; = 2,
                                       &#34;Choice 3&#34; = 3),selected = 1)),

    column(3,
           selectInput(&#34;select&#34;, h3(&#34;Select box&#34;),
                       choices = list(&#34;Choice 1&#34; = 1, &#34;Choice 2&#34; = 2,
                                      &#34;Choice 3&#34; = 3), selected = 1)),

    column(3,
           sliderInput(&#34;slider1&#34;, h3(&#34;Sliders&#34;),
                       min = 0, max = 100, value = 50),
           sliderInput(&#34;slider2&#34;, &#34;&#34;,
                       min = 0, max = 100, value = c(25, 75))
    ),

    column(3,
           textInput(&#34;text&#34;, h3(&#34;Text input&#34;),
                     value = &#34;Enter text...&#34;))
  )

)

# Define server logic ----
server &lt;- function(input, output) {

}

# Run the app ----
shinyApp(ui = ui, server = server)
```

### server

Shiny provides a family of functions that turn R objects into output for your user interface. Each function creates a specific type of output.

| Output function      | Creates   |
| :------------------- | :-------- |
| `dataTableOutput`    | DataTable |
| `htmlOutput`         | raw HTML  |
| `imageOutput`        | image     |
| `plotOutput`         | plot      |
| `tableOutput`        | table     |
| `textOutput`         | text      |
| `uiOutput`           | raw HTML  |
| `verbatimTextOutput` | text      |

| render function   | creates                                         |
| :---------------- | :---------------------------------------------- |
| `renderDataTable` | DataTable                                       |
| `renderImage`     | images (saved as a link to a source file)       |
| `renderPlot`      | plots                                           |
| `renderPrint`     | any printed output                              |
| `renderTable`     | data frame, matrix, other table like structures |
| `renderText`      | character strings                               |
| `renderUI`        | a Shiny tag object or HTML                      |



# 一个实际的例子

![](/post/RShiny-demo.gif)

![](/home/william/Documents/blog/content/post/RShiny-demo.gif)

## 设计框架

 `RShiny` 包含两部分内容，一个是前端的 `UI` 界面部分，另一个是后端的 `Server` 服务。

### 前端 UI

我们首先需要定义前端，即需要先规划好想要表达的内容与方式。

```R
## ------------------------------------------------------------------------------------
## ui = header &#43; sidebar &#43; body
## icon: https://fontawesome.com/icons?d=gallery&amp;p=1
header &lt;- dashboardHeader(title = &#34;RShiny @william&#34;)
sidebar &lt;- dashboardSidebar(
    sidebarMenu(
        menuItem(&#34;CFFEX&#34;, tabName = &#34;CFFEX&#34;, icon = icon(&#34;warehouse&#34;)),
        menuItem(&#34;CFFEX_T&#34;, tabName = &#34;CFFEX_T&#34;, icon = icon(&#34;ticket-alt&#34;)),
        menuItem(&#34;SHFE&#34;, tabName = &#34;SHFE&#34;, icon = icon(&#34;city&#34;)),
        menuItem(&#34;DCE&#34;, tabName = &#34;DCE&#34;, icon = icon(&#34;shopping-basket&#34;)),
        menuItem(&#34;STOCKS&#34;, tabName = &#34;STOCKS&#34;, icon = icon(&#34;coins&#34;)),
        menuItem(&#34;ConvBond&#34;, tabName = &#34;CV&#34;, icon = icon(&#34;comment-dollar&#34;))
    )
)

tab_main &lt;- function(exch) {
	## some R code goes here
}

tab_product &lt;- function(exch) {
	## some R code goes here
}

body &lt;- dashboardBody(
    tabItems(
        ## CFFEX ---------------------------------------------- begin
        tabItem(tabName = &#34;CFFEX&#34;,
                navbarPage(&#34;&#34;,
                           id = &#34;CFFEX_nav&#34;,
                           theme = shinytheme(&#34;flatly&#34;),
                           tab_main(&#34;CFFEX&#34;),
                           tab_product(&#34;CFFEX&#34;),
                           tab_data(&#34;CFFEX&#34;),
                           tab_sig(&#34;CFFEX&#34;)
                )
        ),
        ## CFFEX ---------------------------------------------- end
    )
)

## gear up all
dashboardPage(header, sidebar, body)
ui = dashboardPage(header, sidebar, body)
```

### 后端 Server

`server` 其实是一个很大的函数，包含了三个具体的参数，这个函数有点类似 callback，允许我们在里面定义自己的操作，然后把这个函数传递给 `shiny` 进行具体的解析。

```R
server = function(input, output, session) {
	## some R code goes here
}
```

其中，

- `input` 是我们可以从 `UI` 界面交互获取的内容，比如 `input$CFFEX_main_select_session`，通过这个变量我们就可以实时的从界面获取用户想要我们执行的参数

- `output` 是我们想要 `server` 计算的结果返回给 `UI`。比如，我们在上面的 `UI` 定义了一个 `tab_main` 的组件，代码里面包含了这么一个命令

    ```R
    plotlyOutput(sprintf(&#34;%s_sig&#34;, exch), width = &#34;100%&#34;, height = &#34;620px&#34;)
    ```

    即 `UI` 期望可以通过 `Server` 获取到这个返回，那么我们的 `output` 就可以写成这样

    ```R
    output$CFFEX_T_main &lt;- renderPlotly({
      ## some R code goes here
    })
    ```

- 细心的你，还发现我添加了一些按钮，你只需要轻松的点击按钮或者选择框，就可以得到想要的结果。这个用编程语言讲，叫做事件触发。我们通过添加观察组，针对不同的事件执行相应的策略。比如，观察到用户选择不同的信号名称，那么我们就更新相应的图片：

    ```R
    observe({
      if (input$CFFEX_sig_reset == 0)
      {
          updateCheckboxGroupInput(session, inputId=&#34;CFFEX_sig_select_signame&#34;, label = NULL,
                                   choices = all.cffex.sig.names,
                                   selected = grep(&#34;pred&#34;, all.cffex.sig.names, value = T),
                                   inline = TRUE)
      }
      else
      {
          updateCheckboxGroupInput(session, inputId=&#34;CFFEX_sig_select_signame&#34;, label = NULL,
                                   choices = all.cffex.sig.names,
                                   selected = grep(&#34;pred&#34;, all.cffex.sig.names, value = T),
                                   inline = TRUE)
      }
    })
    ```

### 完工

最后，我们把 `UI` 和 `Server` 交给 `shiny`去解析并生成相应的网页信息即可

```R
## ------------------------------------------------------------------------------------
shinyApp(ui, server)
```



# Docker 安装 Rshiny

```bash
docker run --name rshiny -dit --privileged=true -p 58787:8787 -p 53838:3838 wuya-centos7-r4.0:v1.0 /sbin/init

## 添加用户，需要进入 docker 添加用户
docker exec -it rshiny bash
sudo adduser tester
sudo passwd tester

## 安装 R
https://www.osradar.com/how-to-install-r-and-rstudio-on-centos-8/
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-07-10-rshiny-%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97/  

