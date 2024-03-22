# 期货数据：Tick 转 Bar





继续 **期货数据** 系列。上一期我们已经[从数据文件读取](https://williamlfang.github.io/post/2017-10-19-%E6%9C%9F%E8%B4%A7%E6%95%B0%E6%8D%AE-r%E8%AF%BB%E5%8F%96%E6%95%B0%E6%8D%AE%E6%96%87%E4%BB%B6/)相关的数据，今天来介绍如何把 `Tick Data` 转化为 `Bar Data`。

- 通过清洗数据，获得真实、可靠、符合逻辑的[干净数据](https://williamlfang.github.io/post/2017-10-18-%E6%9C%9F%E8%B4%A7%E6%95%B0%E6%8D%AE%E6%95%B0%E6%8D%AE%E6%B8%85%E7%90%86%E8%A6%81%E7%82%B9/)
- 通过分笔数据来计算汇总日间（daily）的`OHLC`、`Volume`、`Turnover`、`OI`、`SettlementPrice`
- 通过计算分笔数据的 `Delta` 来汇总分钟之内的 `OHLC`、`Volume`、`Turnover`
- 对于每一笔交易的数据，我们要去其是**真实成交的记录**，因此需要提取的是 `\(DeltaX \neq 0\)` 的数据行
- 由于需要计算的分钟数据比较大，函数里面运用到了并行计算，默认开启 `parallel`:
  
    - 我们采用的是 `CentOS` 服务器，默认开始的模式是 `FORK`
      
        
        ```r
        cl &lt;- makeCluster(no.cores, type=&#34;FORK&#34;)
        ```
      
    - 如果在 `Windows` 操作系统，则需要开启 `PSOCK` 模式




# Daily

## 文件

文件在 `/Rconfig/dt2DailyBar.R`

## 代码


```r
##! dt2DailyBar.R
##
## 功能：
## 用于把 tick data 的数据转化为 daily 的数据，
## 1. dt2DailyBar(dt,&#34;allday&#34;)：全天的数据
## 2. dt2DailyBar(dt,&#34;day&#34;)：日盘的数据
## 3. dt2DailyBar(dt,&#34;night&#34;)：夜盘的数据
##############################################################################
##----------------------------------------------------------------------------
## 全天
## dt_1d    &lt;- dt2DailyBar(dt,&#34;allday&#34;)
## 日盘
## dt_day   &lt;- dt2DailyBar(dt,&#34;day&#34;)
## 夜盘
## dt_night &lt;- dt2DailyBar(dt,&#34;night&#34;)
dt2DailyBar &lt;- function(x, daySector){
  #-----------------------------------------------------------------------------
  if(daySector == &#34;allday&#34;){
    temp &lt;- x
  }else{
    if(daySector == &#34;day&#34;){##-------------- dn == &#34;night&#34;
      temp &lt;- x[UpdateTime %between% c(&#34;08:30:00&#34;, &#34;15:30:00&#34;)]
    }else{##-------------- dn == &#34;night&#34;
      temp &lt;- x[!(UpdateTime %between% c(&#34;08:30:00&#34;, &#34;15:30:00&#34;))]
    }
  }
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  tempRes &lt;- temp %&gt;%
    .[,.SD[,.(
      OpenPrice = ifelse(nrow(.SD[DeltaVolume != 0]) != 0,
                .SD[DeltaVolume != 0][1, ifelse(is.na(OpenPrice) | OpenPrice == 0 | daySector == &#39;day&#39;,
                  LastPrice, OpenPrice)],
                .SD[Volume != 0][1, ifelse(is.na(OpenPrice) | OpenPrice == 0 | daySector == &#39;day&#39;,
                  LastPrice, OpenPrice)]),
      HighPrice = ifelse(all(is.na(.SD$HighestPrice)) | sum(.SD$HighestPrice, na.rm=TRUE) == 0,
                         max(.SD[Volume != 0]$LastPrice, na.rm=TRUE),
                         max(.SD[Volume != 0]$HighestPrice, na.rm=TRUE)),
      LowPrice  = ifelse(all(is.na(.SD$LowestPrice)) | sum(.SD$LowestPrice, na.rm=TRUE) == 0,
                         min(.SD[Volume != 0][LastPrice !=0]$LastPrice, na.rm=TRUE),
                         min(.SD[Volume != 0]$LowestPrice, na.rm=TRUE)),
      ## CZCE 郑商所的 ClosePrice 是有问题的，需要用到 LastPrice
      ClosePrice = ifelse(all(is.na(.SD$ClosePrice)) | sum(.SD$ClosePrice, na.rm=TRUE) == 0 |
                            .SD[,nchar(unique(gsub(&#39;[a-zA-Z]&#39;,&#39;&#39;,InstrumentID))) == 3],
                          .SD[Volume != 0][.N,LastPrice],
                          .SD[Volume != 0][.N,ClosePrice]),
      #-----------------------------------------------------------------------------
      Volume            = sum(.SD$DeltaVolume, na.rm=TRUE),
      Turnover          = sum(.SD$DeltaTurnover, na.rm=TRUE),
      #                 -----------------------------------------------------------------------------
      OpenOpenInterest  = .SD[1,OpenInterest],
      HighOpenInterest  = .SD[,max(OpenInterest, na.rm=TRUE)],
      LowOpenInterest   = .SD[,min(OpenInterest, na.rm=TRUE)],
      CloseOpenInterest = .SD[.N,OpenInterest],
      #                 -----------------------------------------------------------------------------
      UpperLimitPrice   = unique(na.omit(.SD$UpperLimitPrice)),
      LowerLimitPrice   = unique(na.omit(.SD$LowerLimitPrice)),
      SettlementPrice   = .SD[.N, SettlementPrice]
    )], by = .(TradingDay, InstrumentID)] %&gt;%
    .[Volume != 0 &amp; Turnover != 0] %&gt;%
    .[, Sector := daySector]
  #-----------------------------------------------------------------------------
  #&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;
  setcolorder(tempRes, c(&#39;TradingDay&#39;, &#39;Sector&#39;,
                          colnames(tempRes)[2:(ncol(tempRes)-1)]))
  return(tempRes)
  #&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;&gt;
}
##############################################################################
```

# Minute

## 文件

文件位于 `/Rconfig/dt2MinuteBar.R`

## 代码


```r
##! dt2MinuteBar.R
##
## 功能：
## 用于把 tick data 的数据转化为 分钟 的数据，
## 1. dt2MinuteBar(dt)
##############################################################################
##----------------------------------------------------------------------------
dt2MinuteBar &lt;- function(dt){
  setkey(dt,InstrumentID)
  temp &lt;- lapply(unique(dt$InstrumentID), function(ii){ dt[ii] })

  no.cores &lt;- max(round(detectCores()/3), 4)
  # no.cores &lt;- max(round(detectCores()/4), 4)
  cl &lt;- makeCluster(no.cores, type=&#34;FORK&#34;)
  # clusterExport(cl, c(&#34;dt&#34;,&#34;temp&#34;))
  # clusterEvalQ(cl,{library(data.table);library(magrittr)})
  dtMinute &lt;- parLapply(cl, 1:length(temp), function(ii){
    ## -------------------------------------------------------------------------
    temp[[ii]] %&gt;%
      .[, .SD[,.(
        #-----------------------------------------------------------------------------
        NumericExchTime = .SD[1,NumericExchTime],
        #-----------------------------------------------------------------------------
        OpenPrice = .SD[DeltaVolume != 0][1,LastPrice],
        HighPrice = .SD[DeltaVolume != 0, max(LastPrice, na.rm=TRUE)],
        LowPrice  = .SD[DeltaVolume != 0, min(LastPrice, na.rm=TRUE)],
        ClosePrice = ifelse(nrow(.SD[DeltaVolume != 0]) != 0,
                      .SD[DeltaVolume != 0][nrow(.SD[DeltaVolume != 0]), LastPrice],
                      .SD[.N,LastPrice]),
        #-----------------------------------------------------------------------------
        Volume            = sum(.SD$DeltaVolume, na.rm=TRUE),
        Turnover          = sum(.SD$DeltaTurnover, na.rm=TRUE),
        #                 -----------------------------------------------------------------------------
        OpenOpenInterest  = .SD[1,OpenInterest],
        HighOpenInterest  =.SD[,max(OpenInterest, na.rm=TRUE)],
        LowOpenInterest   = .SD[,min(OpenInterest, na.rm=TRUE)],
        CloseOpenInterest = .SD[.N,OpenInterest],
        #                 -----------------------------------------------------------------------------
        UpperLimitPrice   = unique(na.omit(.SD$UpperLimitPrice)),
        LowerLimitPrice   = unique(na.omit(.SD$LowerLimitPrice)),
        SettlementPrice   = .SD[.N, SettlementPrice]
      )], by = .(TradingDay, InstrumentID, Minute)] %&gt;%
      .[Volume != 0 &amp; Turnover != 0]
    ## -------------------------------------------------------------------------
  }) %&gt;% rbindlist()
  stopCluster(cl)

  return(dtMinute)
}
##############################################################################
```




---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-10-20-%E6%9C%9F%E8%B4%A7%E6%95%B0%E6%8D%AE-tick-%E8%BD%AC-bar/  

