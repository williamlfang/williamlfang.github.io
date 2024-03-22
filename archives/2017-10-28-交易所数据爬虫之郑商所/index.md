# 交易所数据爬虫之郑商所


上回我介绍了如何[对中金所进行网络爬虫](https://williamlfang.github.io/post/2017-10-23-%E4%BA%A4%E6%98%93%E6%89%80%E6%95%B0%E6%8D%AE%E7%88%AC%E8%99%AB%E4%B9%8B%E4%B8%AD%E9%87%91%E6%89%80/)，获得了股指期货相关的历史日行情数据和成交排名数据。同样的，我们也可以使用类似的爬虫技术，对郑商所进行网络爬虫。

&lt;!--more--&gt;

# 诡异的郑商所

不过与中金所网络爬虫不一样的一点是，中金所本身提供了数据文件的**静态链接地址**，我们只需要解析到不同交易日期所对应的链接，就能够把数据下载到本地。而郑商所虽然也同样提供了文件的静态链接，**但是**，我在爬虫的过程中发现了一个小小的问题：有部分的交易数据，郑商所不知道出于何种原因（有可能是原始的数据文件丢失，或者路径存储错误），竟然找不到当日对应的数据文件链接。也就是说，对于这些交易日，我们是无法直接下载文件的。因此，对于这些没有提供链接的数据，我们只能采用页面爬虫的技术，通过读取网页的数据，经过数据清理、规整等步骤，再保存到本地文件。

针对网站页面的数据进行爬虫，会涉及到 `DOM` 构造、`HTML` 元素解析、文本识别、正则表达等诸多方面的技术。在接下来的内容里，我会重点介绍如何在网页中找到我们需要的数据。


![郑商所网站提供期货与期权相关的数据](./czce01.png &#34;郑商所网站提供期货与期权相关的数据&#34;)

# 工具箱

对于网页内容进行爬虫、识别网页内容、获取目标数据或文本等，我们需要使用到 `HTML` 相关的技术手段。最原始的一种办法是通过 `wget` 把整个网页下载到本地，然后再进行内容解析；或者使用 `libcur` 来读取远程的内容并传递到系统的内存。这些技术难度较大，而且得到的数据并不是结构性的，使用正则获取目标数据比较坎坷。万幸的是，已经有人通过软件包的形式，为我们把这些基础的工作都处理完成了，我们只需要调用相关的函数，即可实现简单的网页爬虫。

以下两个 `R` 的扩展包就是针对网络爬虫而开发的。

## `RSelenium`

`Selenium` 是一款网络驱动，作为**无头浏览器**(headless webdriver)驱动，提供了高性能的网络测试、页面加载、网络解析等功能。基于这项技术所提供的 `API` 调用端口，我们可以使用不同的编程语言来调用浏览器功能，从而实现了开发-测试的无缝连接。

`RSelenium` 就是 `Selenium` 在 `R` 语言下的扩展包，集成了大量可供调用的函数，使得我们只需要在 `R` 中调用函数并传入参数，即可对网页进行解析。

## `rvest`

这个是大神 **Wickham Hadley** 编写的一个针对网页爬虫的扩展包，封装了 `Linux` 下的 `libcur` 库，因此能够提供对网页页面的 `DOM` 解析。这个包返回一个结构化的对象，可以通过 `R` 的函数对其进行数据清理；同时它还针对不同的编码进行自动化的识别，这点对于中文网站尤其重要，否则，编码错误会导致我们爬虫的数据出现乱码的悲剧。


# 日行情数据

## 静态链接

我们在对中金所进行爬虫的那篇博客里面，已经讲到如何通过 `Chrome` 的 `Inspect` 功能来获取网页的元素。通过查找特定位置的 `HTML` 标签，我们可以得到该位置所对应的具体信息。

### 定位网页

首先我们需要做的是先尝试定位某个交易日的日行情数据存放网页，通过输入交易日，然后点击查询，我们便可以看到需要查找的交易数据。

![通过交易日期查找日行情数据](./daily01.png &#34;通过交易日期查找日行情数据&#34;)

这个便是我们需要进行爬虫的单独网页。

![承载数据的具体网页](./daily02.png &#34;承载数据的具体网页&#34;)

我们来看看当天的网页地址，比如：`http://www.czce.com.cn/portal/DFSStaticFiles/Future/2017/20171026/FutureDataDaily.htm`。主要是由以下几个部分组成的：

- `http://www.czce.com.cn/portal/DFSStaticFiles/Future/`：这个可以当成是日行情的根目录。
- `2017/20171026/FutureDataDaily.htm`：这个命名规则很明显，由 `YYYY/YYYYmm/FutureDataDaily.htm` 构成。我们可以根据交易日来提取日期组成。


### 下载数据文件

在数据文件对应的 `excel` / `txt` 点击右键，然后使用 `Ctrl &#43; F` 查找 `excel`，我们便可以定位到数据文件了。

![通过元素审查获取标签的具体信息](./daily03.png &#34;通过元素审查获取标签的具体信息&#34;)

一看吓一跳，似乎这个数据文件是一个动态的脚本，好像很难识别的样子。不过，各位不要被这个「纸老虎」吓到了，我们可以手动打开一个网页试试看，有木有惊喜呢。

![原来也是一个静态文件地址](./daily04.png &#34;原来也是一个静态文件地址&#34;)

具体地，我们看到这个数据文件对应的链接地址是：`http://www.czce.com.cn/portal/DFSStaticFiles/Future/2017/20171026/FutureDataDaily.xls`，对其进行拆解看：

- `http://www.czce.com.cn/portal/DFSStaticFiles/Future/`：数据文件所在的根目录
- `2017/20171026/FutureDataDaily.xls`：具体的文件地址，通用格式为 `YYYY/YYYYmmdd/FutureDataDaily.xls`，也就是说，我们可以根据历史的交易日期来生成所以交易日的文件链接，然后呢，通过遍礼下载得到我们想要的数据即可。

不过，这里有一个小小的坑，就是郑商所在 `2015-10-01` 前后有变动过相对路径的根目录的名称，也就是说，这个地方需要我们用交易日期来判断。我们来看看这段代码是这样写的：


```r
## 在 2015-10-01 之前
exchURL1 &lt;- &#34;http://www.czce.com.cn/portal/exchange/&#34;

## 在 2015-10-01 之后
exchURL2 &lt;- &#34;http://www.czce.com.cn/portal/DFSStaticFiles/Future/&#34;

tempDir &lt;- paste0(dataPath,exchCalendar[i,calendarYear])

if (!dir.exists(tempDir)) dir.create(tempDir)

tempYear &lt;- exchCalendar[i,calendarYear]
tempTradingDay &lt;- exchCalendar[i,days]

## 需要改变根目录地址
tempURL &lt;- ifelse(tempTradingDay &lt; &#39;20151001&#39;,
                  paste0(exchURL1, tempYear, &#39;/datadaily/&#39;, tempTradingDay, &#39;.txt&#39;),
                  paste0(exchURL2, tempYear, &#39;/&#39;, tempTradingDay, &#39;/FutureDataDaily.xls&#39;))

destFile &lt;-  paste0(dataPath, &#39;/&#39;, exchCalendar[i,calendarYear],
                    &#34;/&#34;, tempTradingDay,
                    ifelse(tempTradingDay &lt; &#39;20151001&#39;,&#39;.txt&#39;,&#39;.xls&#39;))
```

然后便可以开启并行模式下载数据了：


```r
try(download.file(tempURL, destFile, mode = &#39;wb&#39;))
```


## 网页内容爬虫

如果事情都是按照我们预期，作为强迫症的我，必然要求这个世界能够按照自然界最优雅的方式来运行。可以，世界太大，坏人太多，结局很不好。

以上介绍了使用静态网页链接地址来下载文件，可惜对于部分的交易日期，郑商所似乎把原始的数据文件弄丢了。这个不得了，我们得程序现在罢工了，无法再继续下载数据了。

不过所幸的是，我们还有另外一套网页爬虫的技术。

### 识别网页内容

我们知道，任何的网页，后面其实都是一堆的 `HTML` 代码而已，无他。所以，即使我们无法找到（郑商所没有提供）数据文件的链接地址，我们还是可以通过爬虫抓取网页的数据。这个就需要用到 `Selenium`。

首先需要做的是，开启 `selenium` 驱动，通过命令行来模拟网页访问，读取网页内容。


```bash
java -jar selenium-server-standalone-3.5.1.jar
```

接下来，我们可以通过 `RSelenium` 提供的端口，把数据载入内容。这样，我们通过使用 `Firefox` 来模拟登陆网页，然后读取具体的信息，找到相应的数据节点，并正确的识别节点内容。


```r
tempPage &lt;- paste0(&#39;http://www.czce.com.cn/portal/exchange/jyxx/hq/hq&#39;, tempTradingDay, &#39;.html&#39;)

remDr &lt;- remoteDriver(remoteServerAddr =&#39;localhost&#39;
                ,port = 4444
                ,browserName = &#39;firefox&#39;)
remDr$getStatus()

remDr$open(silent = TRUE)
remDr$navigate(tempPage)
tempTable &lt;- remDr$findElements(using = &#39;tag&#39;, value = &#39;table&#39;)[[3]]
tempHTML &lt;- tempTable$getElementAttribute(&#39;outerHTML&#39;)[[1]]
```

现在，我们把整个网页的内容加载到 `R` 的工作空间，接下来便可以使用 `rvest` 来解析网页内容了：


```r
webData &lt;- tempHTML %&gt;%
    read_html(encoding=&#39;GB18030&#39;) %&gt;%
    html_node(&#39;table&#39;) %&gt;%
    html_table(fill = TRUE, header=FALSE) %&gt;%
    as.data.table() %&gt;%
    .[-1] %&gt;%
    rbind(data.table(X1 = c(&#39;&#39;)), ., fill = TRUE)

webData[1, X1 := paste0(&#39;郑州商品交易所每日行情表(&#39;,
                         as.Date(as.character(tempTradingDay), format = &#39;%Y%m%d&#39;),
                         &#39;)&#39;)]
```

整理数据，并写入文件


```r
cols &lt;- colnames(webData)[2:ncol(webData)]
webData[, (cols) := lapply(.SD, function(x){
  gsub(&#39;,&#39;,&#39;&#39;,x)
}), .SDcols = cols]

print(webData)

fwrite(webData, destFile, col.names = FALSE)
```

最后是扫尾工作，记得把不用的内存空间释放出来，下面是在 `Linux` 操作系统的命令，`Windows` 的各位可以自行 Google 搜索（不要用百度！不要用百度！不要用百度！）


```r
# remDr$quit()
try({
  system(&#39;pkill -f firefox&#39;)
  system(&#39;pkill -f geckodriver&#39;)
  system(&#39;rm -rf /tmp/rust_mozprofile*&#39;)
})
```

## Demo


```r
################################################################################
##! czce.R
## 这是主函数:
## 用于从 郑商所 网站爬虫期货交易的日行情数据
## daily
##
##
## 注意:
##
## Author: fl@hicloud-investment.com
## CreateDate: 2017-10-16
################################################################################


################################################################################
## STEP 0: 初始化，载入包，设定初始条件
################################################################################
rm(list = ls())
logMainScript &lt;- c(&#34;czce.R&#34;)

if (class(try(setwd(&#39;/home/fl/myData/&#39;))) == &#39;try-error&#39;) {
  setwd(&#39;/run/user/1000/gvfs/sftp:host=192.168.1.166,user=fl/home/fl/myData&#39;)
}
suppressMessages({
  source(&#39;./R/Rconfig/myInit.R&#39;)
})
library(RSelenium)
################################################################################
## STEP 1: 获取对应的交易日期
################################################################################
ChinaFuturesCalendar &lt;- fread(&#34;./data/ChinaFuturesCalendar/ChinaFuturesCalendar.csv&#34;,
                              colClasses = list(character = c(&#34;nights&#34;,&#34;days&#34;))) %&gt;%
                              .[days &lt; format(Sys.Date(),&#39;%Y%m%d&#39;)]

exchCalendar &lt;- ChinaFuturesCalendar[,&#34;:=&#34;(calendarYear = substr(days,1,4),
                                           calendarYearMonth = substr(days,1,6),
                                           calendarMonth = substr(days,5,6),
                                           calendarDay = substr(days,7,8))]
dataPath &lt;- &#39;/home/william/Documents/Exchange/CZCE/&#39;
# dataPath &lt;- &#34;./data/Bar/Exchange/CZCE/&#34;

##------------------------------------------------------------------------------
if(Sys.info()[&#39;sysname&#39;] == &#39;Windows&#39;){
  Sys.setenv(&#34;R_ZIPCMD&#34; = &#34;D:/Program Files/Rtools/bin/zip.exe&#34;) ## path to zip.exe
}
##------------------------------------------------------------------------------

################################################################################
## CZCE: 郑商所
## 1.持仓排名
## 2.仓单日报
################################################################################
## 在 2015-10-01 之前
exchURL1 &lt;- &#34;http://www.czce.com.cn/portal/exchange/&#34;

## 在 2015-10-01 之后
exchURL2 &lt;- &#34;http://www.czce.com.cn/portal/DFSStaticFiles/Future/&#34;
## =============================================================================

czceData &lt;- function(i) {
  tempDir &lt;- paste0(dataPath,exchCalendar[i,calendarYear])

  if (!dir.exists(tempDir)) dir.create(tempDir)

  tempYear &lt;- exchCalendar[i,calendarYear]
  tempTradingDay &lt;- exchCalendar[i,days]

  tempURL &lt;- ifelse(tempTradingDay &lt; &#39;20151001&#39;,
                    paste0(exchURL1, tempYear, &#39;/datadaily/&#39;, tempTradingDay, &#39;.txt&#39;),
                    paste0(exchURL2, tempYear, &#39;/&#39;, tempTradingDay, &#39;/FutureDataDaily.xls&#39;))

  destFile &lt;-  paste0(dataPath, &#39;/&#39;, exchCalendar[i,calendarYear],
                      &#34;/&#34;, tempTradingDay,
                      ifelse(tempTradingDay &lt; &#39;20151001&#39;,&#39;.txt&#39;,&#39;.xls&#39;))

  tryNo &lt;- 0
  ## ---------------------------------------------------------------------------
  while( (!file.exists(destFile) | file.size(destFile) &lt; 1000) &amp; (tryNo &lt; 20)){
    if (class(try(download.file(tempURL, destFile, mode = &#39;wb&#39;))) == &#39;try-error&#39;) {
      tempPage &lt;- paste0(&#39;http://www.czce.com.cn/portal/exchange/jyxx/hq/hq&#39;, tempTradingDay, &#39;.html&#39;)

      remDr &lt;- remoteDriver(remoteServerAddr =&#39;localhost&#39;
                      ,port = 4444
                      ,browserName = &#39;firefox&#39;)
      remDr$getStatus()

      remDr$open(silent = TRUE)
      remDr$navigate(tempPage)
      tempTable &lt;- remDr$findElements(using = &#39;tag&#39;, value = &#39;table&#39;)[[3]]
      tempHTML &lt;- tempTable$getElementAttribute(&#39;outerHTML&#39;)[[1]]

      webData &lt;- tempHTML %&gt;%
          read_html(encoding=&#39;GB18030&#39;) %&gt;%
          html_node(&#39;table&#39;) %&gt;%
          html_table(fill = TRUE, header=FALSE) %&gt;%
          as.data.table() %&gt;%
          .[-1] %&gt;%
          rbind(data.table(X1 = c(&#39;&#39;)), ., fill = TRUE)

      webData[1, X1 := paste0(&#39;郑州商品交易所每日行情表(&#39;,
                               as.Date(as.character(tempTradingDay), format = &#39;%Y%m%d&#39;),
                               &#39;)&#39;)]

      cols &lt;- colnames(webData)[2:ncol(webData)]
      webData[, (cols) := lapply(.SD, function(x){
        gsub(&#39;,&#39;,&#39;&#39;,x)
      }), .SDcols = cols]

      print(webData)

      fwrite(webData, destFile, col.names = FALSE)

      # remDr$quit()
      try({
        system(&#39;pkill -f firefox&#39;)
        system(&#39;pkill -f geckodriver&#39;)
        system(&#39;rm -rf /tmp/rust_mozprofile*&#39;)
      })
    }
    tryNo &lt;- tryNo &#43; 1
  }
  ## ---------------------------------------------------------------------------
}

################################################################################
## STEP 2: 开启并行计算模式，下载数据
################################################################################
# cl &lt;- makeCluster(max(round(detectCores()*3/4),4), type=&#39;FORK&#39;)
# parSapply(cl, 1:nrow(ChinaFuturesCalendar), function(i){
#   ## ---------------------------------------------------------------------------
#   try(czceData(i))
#   ## ---------------------------------------------------------------------------
# })
# stopCluster(cl)


## =============================================================================
sapply(1:nrow(ChinaFuturesCalendar), function(i){
  try(czceData(i))
})
## =============================================================================
```


# 成交持仓排名

## 持仓排名地址

与日行情数据爬虫相类似，我们也一样可以对期货公司层面的成交持仓排名数据进行网络爬虫。这里需要做的，其实就是把日行情数据的网页地址换成持仓排名的网页地址，即


```r
## 直接下载文件的链接
tempURL &lt;- ifelse(tempTradingDay &lt; &#39;20151001&#39;,
                  paste0(exchURL1, tempYear, &#39;/datatradeholding/&#39;, tempTradingDay, &#39;.txt&#39;),
                  paste0(exchURL2, tempYear, &#39;/&#39;, tempTradingDay, &#39;/FutureDataHolding.xls&#39;))

## 数据爬虫的网页地址
tempPage &lt;- paste0(&#39;http://www.czce.com.cn/portal/exchange/jyxx/pm/pm&#39;, tempTradingDay, &#39;.html&#39;)
```

## Demo

好吧，剩下就就直接上干货喽。


```r
################################################################################
## czce.R
## 用于下载郑商所期货公司持仓排名数据
##
## Author: William Fang
## Date  : 2017-08-21
################################################################################

################################################################################
## STEP 0: 初始化，载入包，设定初始条件
################################################################################
rm(list = ls())
logMainScript &lt;- c(&#34;czce.R&#34;)

# setwd(&#39;/home/fl/myData/&#39;)
if (class(try(setwd(&#39;/home/fl/myData/&#39;))) == &#39;try-error&#39;) {
  setwd(&#39;/run/user/1000/gvfs/sftp:host=192.168.1.166,user=fl/home/fl/myData&#39;)
}

suppressMessages({
  source(&#39;./R/Rconfig/myInit.R&#39;)
})
library(RSelenium)
Sys.setlocale(&#34;LC_ALL&#34;, &#39;en_US.UTF-8&#39;)

ChinaFuturesCalendar &lt;- fread(&#34;./data/ChinaFuturesCalendar/ChinaFuturesCalendar.csv&#34;,
                              colClasses = list(character = c(&#34;nights&#34;,&#34;days&#34;))) %&gt;%
                              .[days &lt; format(Sys.Date(),&#39;%Y%m%d&#39;)]

exchCalendar &lt;- ChinaFuturesCalendar[,&#34;:=&#34;(calendarYear = substr(days,1,4),
                                           calendarYearMonth = substr(days,1,6),
                                           calendarMonth = substr(days,5,6),
                                           calendarDay = substr(days,7,8))]
dataPath &lt;- &#39;/home/william/Documents/oiRank/CZCE/&#39;
# dataPath &lt;- &#34;./data/Bar/Exchange/CZCE/&#34;

##------------------------------------------------------------------------------
if(Sys.info()[&#39;sysname&#39;] == &#39;Windows&#39;){
  Sys.setenv(&#34;R_ZIPCMD&#34; = &#34;D:/Program Files/Rtools/bin/zip.exe&#34;) ## path to zip.exe
}
##------------------------------------------------------------------------------

################################################################################
## CZCE: 郑商所
## 1.持仓排名
## 2.仓单日报
################################################################################
## 在 2015-10-01 之前
exchURL1 &lt;- &#34;http://www.czce.com.cn/portal/exchange/&#34;

## 在 2015-10-01 之后
exchURL2 &lt;- &#34;http://www.czce.com.cn/portal/DFSStaticFiles/Future/&#34;
## =============================================================================


czceData &lt;- function(i) {
  tempDir &lt;- paste0(dataPath,exchCalendar[i,calendarYear])

  if (!dir.exists(tempDir)) dir.create(tempDir, recursive = TRUE)

  tempYear &lt;- exchCalendar[i,calendarYear]
  tempTradingDay &lt;- exchCalendar[i,days]

  tempURL &lt;- ifelse(tempTradingDay &lt; &#39;20151001&#39;,
                    paste0(exchURL1, tempYear, &#39;/datatradeholding/&#39;, tempTradingDay, &#39;.txt&#39;),
                    paste0(exchURL2, tempYear, &#39;/&#39;, tempTradingDay, &#39;/FutureDataHolding.xls&#39;))

  destFile &lt;-  paste0(dataPath, &#39;/&#39;, exchCalendar[i,calendarYear],
                      &#34;/&#34;, tempTradingDay,
                      ifelse(tempTradingDay &lt; &#39;20151001&#39;,&#39;.txt&#39;,&#39;.xls&#39;))

  tryNo &lt;- 0
  ## ---------------------------------------------------------------------------
  while( (!file.exists(destFile) | file.size(destFile) &lt; 1000) &amp; (tryNo &lt; 20)){
    if (class(try(download.file(tempURL, destFile, mode = &#39;wb&#39;))) == &#39;try-error&#39;) {
      tempPage &lt;- paste0(&#39;http://www.czce.com.cn/portal/exchange/jyxx/pm/pm&#39;, tempTradingDay, &#39;.html&#39;)

      webData &lt;- tempPage %&gt;%
                  read_html(encoding = &#39;GB18030&#39;) %&gt;%
                  html_nodes(&#39;table&#39;) %&gt;%
                  html_table(fill=TRUE, header=FALSE) %&gt;%
                  .[-1] %&gt;%
                  .[[1]] %&gt;%
                  as.data.table() %&gt;%
                  rbind(data.table(X1 = c(&#39;&#39;,&#39;&#39;)), ., fill = TRUE)
      webData[1, X1 := paste0(&#39;郑州商品交易所持仓排行表(&#39;,
                               as.Date(as.character(tempTradingDay), format = &#39;%Y%m%d&#39;),
                               &#39;)&#39;)]

      cols &lt;- colnames(webData)[2:ncol(webData)]
      webData[, (cols) := lapply(.SD, function(x){
        gsub(&#39;,&#39;,&#39;&#39;,x)
      }), .SDcols = cols]

      # grep(&#34;名次&#34;, tempData$X1) %&gt;% length()

      webTitle &lt;- tempPage %&gt;%
                  read_html(encoding = &#39;GB18030&#39;) %&gt;%
                  html_nodes(&#39;font&#39;) %&gt;%
                  html_text() %&gt;%
                  .[grep(&#39;品种|合约代码&#39;,.)]

      for (j in 1:length(webTitle)) {
        tempRow &lt;- grep(&#34;名次&#34;, webData$X1)[j] - 1
        webData[tempRow, X1 := webTitle[j]]
      }

      print(webData)

      fwrite(webData, destFile, col.names = FALSE)
    }
    tryNo &lt;- tryNo &#43; 1
  }
  ## ---------------------------------------------------------------------------
}

################################################################################
## STEP 2: 开启并行计算模式，下载数据
################################################################################
cl &lt;- makeCluster(max(round(detectCores()*3/4),4), type=&#39;FORK&#39;)
parSapply(cl, 1:nrow(ChinaFuturesCalendar), function(i){
  ## ---------------------------------------------------------------------------
  try(czceData(i))
  ## ---------------------------------------------------------------------------
})
stopCluster(cl)


# ## =============================================================================
# sapply(1:nrow(ChinaFuturesCalendar), function(i){
#   try(czceData(i))
# })
# ## =============================================================================
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2017-10-28-%E4%BA%A4%E6%98%93%E6%89%80%E6%95%B0%E6%8D%AE%E7%88%AC%E8%99%AB%E4%B9%8B%E9%83%91%E5%95%86%E6%89%80/  

