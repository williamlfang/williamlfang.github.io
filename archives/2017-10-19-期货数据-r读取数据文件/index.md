# 期货数据：R读取数据文件





在上一期的 **「期货数据」** 系列，我介绍了 [数据清理要点](https://williamlfang.github.io/post/2017-10-18-%E6%9C%9F%E8%B4%A7%E6%95%B0%E6%8D%AE-%E6%95%B0%E6%8D%AE%E6%B8%85%E7%90%86%E8%A6%81%E7%82%B9/)。这一期，我将介绍如何使用统计编程语言 `R` 来读取从交易所接收下来的数据文件。

&lt;!--more--&gt;

-----

# `R` 读取数据

## 萝卜与青菜

我在之前的一篇博客谈到了如何使用 `readr` 包[读取包含中文字段的数据文件](https://williamlfang.github.io/post/2017-10-10-r%E8%AF%BB%E5%8F%96%E4%B8%AD%E6%96%87%E5%AD%97%E6%AE%B5%E7%9A%84%E6%AD%A3%E7%A1%AE%E5%A7%BF%E5%8A%BF/)。同时，文件也提到，`readr` 对于读取大文件存在性能上的不足。因此，我日常仍然以另外一个软件包为主要工具。

这个神奇的软件包，就是大名鼎鼎的 `data.table`，提高了从读取数据、数据清洗、数据汇总到数据写入的全方位功能函数，而且难能可贵的是，它的处理效率惊人得强大。我估计会在以后单独写一篇博客来介绍这个扩展包。不过这里作为引子，请允许我隆重介绍今天的主角：`fread`。

## `read_csv`


```r
library(readr)
help(read_csv)
```


## `fread`


```r
library(data.table)
help(fread)
```

-----

# `myFread.R`

`myFraed.R` 是我编写的一个函数脚本，集成了以上两个函数的功能，并在此基础上对数据文件进行初步的判断：

- 如果数据文件支持使用 `fread` 进行读取，则优先使用这个函数，因为这个读取速度极快，对于一个 `1Gb
 大小的文件，大概只需要 `10 ~ 15 秒`
- 如果对于部分数据文件，有可能由于里面包含中文字段、数据格式异常等问题，这时候就需要借助 `read_csv` 更加强大的底层支撑来处理，不过读取的速度稍微有所降低

## FromDC


```r
## =============================================================================
## FUN: myFreadBar
## 从　DC 那份数据文件读取数据，用于制作　Bar
myFreadFromDC &lt;- function(x){
  ## -- 如果使用　fread 可以正常读取数据文件
  if(class(try(fread(x, showProgress = FALSE, fill = TRUE, nrows = 1000),
               silent = TRUE))[1] != &#34;try-error&#34;){
    dt &lt;- fread(x, showProgress = TRUE, fill = TRUE,
                select = c(&#39;TradingDay&#39;,&#39;UpdateTime&#39;,&#39;UpdateMillisec&#39;
                           ,&#39;InstrumentID&#39;,&#39;LastPrice&#39;
                           ,&#34;OpenPrice&#34;, &#34;HighestPrice&#34;, &#34;LowestPrice&#34;,&#34;ClosePrice&#34;
                           ,&#39;Volume&#39;,&#39;Turnover&#39;,&#39;OpenInterest&#39;
                           ,&#39;SettlementPrice&#39;,&#39;UpperLimitPrice&#39;,&#39;LowerLimitPrice&#39;
                           ,&#39;BidPrice1&#39;,&#39;BidVolume1&#39;,&#39;BidPrice2&#39;,&#39;BidVolume2&#39;
                           ,&#39;BidPrice3&#39;,&#39;BidVolume3&#39;,&#39;BidPrice4&#39;,&#39;BidVolume4&#39;
                           ,&#39;BidPrice5&#39;,&#39;BidVolume5&#39;
                           ,&#39;AskPrice1&#39;,&#39;AskVolume1&#39;,&#39;AskPrice2&#39;,&#39;AskVolume2&#39;
                           ,&#39;AskPrice3&#39;,&#39;AskVolume3&#39;,&#39;AskPrice4&#39;,&#39;AskVolume4&#39;
                           ,&#39;AskPrice5&#39;,&#39;AskVolume5&#39;,&#39;AveragePrice&#39;
                ),
                colClasses = list(character = c(&#34;TradingDay&#34;,&#34;InstrumentID&#34;,&#34;UpdateTime&#34;),
                                  numeric   = c(&#34;Volume&#34;,&#34;Turnover&#34;) ))
  }else{
  ## -- 如果使用　fread 读取失败，则使用　read_csv
    dt &lt;- read_csv(x,
                   col_types = list(TradingDay   = col_character(),
                                    InstrumentID = col_character(),
                                    UpdateTime   = col_character(),
                                    Volume       = col_number(),
                                    Turnover     = col_number())
    ) %&gt;% as.data.table() %&gt;%
      .[,.(TradingDay, UpdateTime, UpdateMillisec
           ,InstrumentID,LastPrice
           ,OpenPrice, HighestPrice, LowestPrice,ClosePrice
           ,Volume,Turnover,OpenInterest
           ,SettlementPrice,UpperLimitPrice,LowerLimitPrice
           ,BidPrice1,BidVolume1,BidPrice2,BidVolume2
           ,BidPrice3,BidVolume3,BidPrice4,BidVolume4
           ,BidPrice5,BidVolume5
           ,AskPrice1,AskVolume1,AskPrice2,AskVolume2
           ,AskPrice3,AskVolume3,AskPrice4,AskVolume4
           ,AskPrice5,AskVolume5,AveragePrice)]
  }
  ##----------------------------------------------------------------------------
  return(dt)
}
```


## CTPMD


```r
## =============================================================================
## FUN: myFreadBarCTP
## 用于制作 bar
myFreadBarCTP &lt;- function(x){
  ## -- 如果使用　fread 可以正常读取数据文件
  if(class(try(fread(x, showProgress = FALSE, fill = TRUE, nrows = 1000),
               silent = TRUE))[1] != &#34;try-error&#34;){
    dt &lt;- fread(x, showProgress = TRUE, fill = TRUE,
                select = c(&#39;TimeStamp&#39;,&#39;TradingDay&#39;,&#39;UpdateTime&#39;,&#39;UpdateMillisec&#39;
                           ,&#39;InstrumentID&#39;,&#39;LastPrice&#39;
                           ,&#34;OpenPrice&#34;, &#34;HighestPrice&#34;, &#34;LowestPrice&#34;,&#34;ClosePrice&#34;
                           ,&#39;Volume&#39;,&#39;Turnover&#39;,&#39;OpenInterest&#39;
                           ,&#39;SettlementPrice&#39;,&#39;UpperLimitPrice&#39;,&#39;LowerLimitPrice&#39;
                           ,&#39;BidPrice1&#39;,&#39;BidVolume1&#39;,&#39;BidPrice2&#39;,&#39;BidVolume2&#39;
                           ,&#39;BidPrice3&#39;,&#39;BidVolume3&#39;,&#39;BidPrice4&#39;,&#39;BidVolume4&#39;
                           ,&#39;BidPrice5&#39;,&#39;BidVolume5&#39;
                           ,&#39;AskPrice1&#39;,&#39;AskVolume1&#39;,&#39;AskPrice2&#39;,&#39;AskVolume2&#39;
                           ,&#39;AskPrice3&#39;,&#39;AskVolume3&#39;,&#39;AskPrice4&#39;,&#39;AskVolume4&#39;
                           ,&#39;AskPrice5&#39;,&#39;AskVolume5&#39;
                ),
                colClasses = list(character = c(&#34;TradingDay&#34;,&#34;InstrumentID&#34;,&#34;UpdateTime&#34;),
                                  numeric   = c(&#34;Volume&#34;,&#34;Turnover&#34;) )) %&gt;%
      .[grep(&#34;^[0-9]{8}:[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{4,6}$&#34;, TimeStamp)]
  }else{
  ## -- 如果使用　fread 读取失败，则使用　read_csv
    dt &lt;- read_csv(x,
                   col_types = list(TradingDay   = col_character(),
                                    InstrumentID = col_character(),
                                    UpdateTime   = col_character(),
                                    Volume       = col_number(),
                                    Turnover     = col_number())
    ) %&gt;% as.data.table() %&gt;%
      .[grep(&#34;^[0-9]{8}:[0-9]{2}:[0-9]{2}:[0-9]{2}:[0-9]{4,6}$&#34;, TimeStamp)] %&gt;%
      .[,.(TimeStamp, TradingDay, UpdateTime, UpdateMillisec
           ,InstrumentID,LastPrice
           ,OpenPrice, HighestPrice, LowestPrice,ClosePrice
           ,Volume,Turnover,OpenInterest
           ,SettlementPrice,UpperLimitPrice,LowerLimitPrice
           ,BidPrice1,BidVolume1,BidPrice2,BidVolume2
           ,BidPrice3,BidVolume3,BidPrice4,BidVolume4
           ,BidPrice5,BidVolume5
           ,AskPrice1,AskVolume1,AskPrice2,AskVolume2
           ,AskPrice3,AskVolume3,AskPrice4,AskVolume4
           ,AskPrice5,AskVolume5)]
  }
  ##----------------------------------------------------------------------------
  return(dt)
}
```


## vnpyData


```r
## =============================================================================
## FUN: myFreadvnpy
myFreadvnpy &lt;- function(x){
  ## -- 如果使用　fread 可以正常读取数据文件
  if(class(try(fread(x, showProgress = FALSE, fill = TRUE, nrows = 100000),
               silent = TRUE))[1] != &#34;try-error&#34;){
    dt &lt;- fread(x, showProgress = TRUE, fill = TRUE,
                select = c(&#39;timeStamp&#39;,&#39;date&#39;,&#39;time&#39;
                           ,&#39;symbol&#39;,&#39;lastPrice&#39;
                           ,&#34;openPrice&#34;, &#34;highestPrice&#34;, &#34;lowestPrice&#34;,&#34;closePrice&#34;
                           ,&#39;volume&#39;,&#39;turnover&#39;,&#39;openInterest&#39;
                           ,&#39;settlementPrice&#39;,&#39;upperLimit&#39;,&#39;lowerLimit&#39;
                           ,&#39;bidPrice1&#39;,&#39;bidVolume1&#39;,&#39;bidPrice2&#39;,&#39;bidVolume2&#39;
                           ,&#39;bidPrice3&#39;,&#39;bidVolume3&#39;,&#39;bidPrice4&#39;,&#39;bidVolume4&#39;
                           ,&#39;bidPrice5&#39;,&#39;bidVolume5&#39;
                           ,&#39;askPrice1&#39;,&#39;askVolume1&#39;,&#39;askPrice2&#39;,&#39;askVolume2&#39;
                           ,&#39;askPrice3&#39;,&#39;askVolume3&#39;,&#39;askPrice4&#39;,&#39;askVolume4&#39;
                           ,&#39;askPrice5&#39;,&#39;askVolume5&#39;
                ),
                colClasses = list(character = c(&#34;date&#34;,&#34;symbol&#34;,&#34;time&#34;),
                                  numeric   = c(&#34;volume&#34;,&#34;turnover&#34;) )) %&gt;%
      .[grep(&#34;^[0-9]{8} [0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{4,6}$&#34;, timeStamp)]
      ## 考虑到部分文件可能使用的　Timestamp 是乱码
  }else{
  ## -- 如果使用　fread 读取失败，则使用　read_csv
    dt &lt;- read_csv(x,
                   col_types = list(timeStamp = col_character(),
                                    date      = col_character(),
                                    symbol    = col_character(),
                                    time      = col_character(),
                                    volume    = col_number(),
                                    turnover  = col_number())
                   ) %&gt;% as.data.table() %&gt;%
      .[grep(&#34;^[0-9]{8} [0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{4,6}$&#34;, timeStamp)] %&gt;%
      .[,.(timeStamp, date, time
           ,symbol,lastPrice
           ,openPrice,highestPrice,lowestPrice,closePrice
           ,volume,turnover,openInterest
           ,settlementPrice,upperLimit,lowerLimit
           ,bidPrice1,bidVolume1,bidPrice2,bidVolume2
           ,bidPrice3,bidVolume3,bidPrice4,bidVolume4
           ,bidPrice5,bidVolume5
           ,askPrice1,askVolume1,askPrice2,askVolume2
           ,askPrice3,askVolume3,askPrice4,askVolume4
           ,askPrice5,askVolume5)]
  }
  ##----------------------------------------------------------------------------
  return(dt)
}
```



---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-10-19-%E6%9C%9F%E8%B4%A7%E6%95%B0%E6%8D%AE-r%E8%AF%BB%E5%8F%96%E6%95%B0%E6%8D%AE%E6%96%87%E4%BB%B6/  

