# 中国期货交易日历




# 期货交易日

利用`R`语言对日期的处理功能，我们可以借此来编制中国期货市场的交易日历表，用于策略回测（Backtesting）、自动化执行行情订阅（mdApi）、进行程序化交易（tdAip）等。

## 要点

在处理中国期货市场交易日期时，主要有以下几个要点需要特别注意：

- 在当年年末，期货交易所会（提前）公布来年的所有节假日安排，这个可以通过查询[上期所公告网站](http://www.shfe.com.cn/news/)
- 因为我们的历史数据最早可以追踪到`2010`年，所以这里的第一个起始年度为`2010`。更加具体地，第一个真正开始接收数据的日期是 `2010-04-16`
- 如果未来第二日开始放假，则当天的夜盘不交易。这个通过判断`days`与`nights`日期相差的时间超过**3天**来处理，因为正常的周五至下周一的相差刚好是**3天**，而节假日则破坏了这个规律
- `2015`年的中秋节放假比较特别，只有放假两天，当时交易所规定了`2015-09-25`当天的夜盘不交易，所以这个需要在`nights`里面排除。请注意，这是一个大坑。

## 代码


```r
## =============================================================================
## myChinaFuturesCalendar.R
##
## 生成中国期货交易日
## 1. days  :日盘时间
## 2. nights:夜盘时间
##
## =============================================================================
rm(list = ls())
setwd(&#39;/home/fl/myData&#39;)

## =============================================================================
## 需要安装的 package: bizdays
pkgs &lt;- c(&#34;data.table&#34;,&#39;magrittr&#39;)

if (length(pkgs[!pkgs %in% installed.packages()]) != 0) {
  sapply(pkgs[!pkgs %in% installed.packages()], install.packages)
}

sapply(pkgs, require, character.only = TRUE)

## -----------------------------------------------------------------------------
## 这里需要做选择
## 对于周末的时间，日盘和夜盘的间隔不应该超过 3 天
## 但是，如果是节假日，有可能超过 3 天，那么夜盘就是 NA 了。
## 这个应该很好理解。
setNights &lt;- function(x) {
    for (i in 1:nrow(x)) {
        if (is.na(x$nights[i])) next

        if( (x$days[i] - x$nights[i]) &gt; 3){
          #-- 如果有休假，则日盘与夜盘差超过 3 天
          x$nights[i] &lt;- NA
        }
    }
    x[, &#34;:=&#34;(
        nights = gsub(&#39;-&#39;,&#39;&#39;, nights),
        days   = gsub(&#39;-&#39;,&#39;&#39;, days))]
    return(x)
}
## =============================================================================

## =============================================================================
## 查询交易所对节假日的安排
## http://www.shfe.com.cn/news/
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/911232224.html
yearID &lt;- 2010
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2010-01-01&#34; &amp; . &lt;= &#34;2010-01-03&#34;),
             which(. &gt;= &#34;2010-02-13&#34; &amp; . &lt;= &#34;2010-02-19&#34;),
             which(. &gt;= &#34;2010-04-03&#34; &amp; . &lt;= &#34;2010-04-05&#34;),
             which(. &gt;= &#34;2010-05-01&#34; &amp; . &lt;= &#34;2010-05-03&#34;),
             which(. &gt;= &#34;2010-06-14&#34; &amp; . &lt;= &#34;2010-06-16&#34;),
             which(. &gt;= &#34;2010-09-22&#34; &amp; . &lt;= &#34;2010-09-24&#34;),
             which(. &gt;= &#34;2010-10-01&#34; &amp; . &lt;= &#34;2010-10-07&#34;)
          )] %&gt;%
          .[which(. &gt;= &#39;2010-04-16&#39;)]
nights &lt;- NA

calendar2010 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/11272678.html
yearID &lt;- 2011
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2011-01-01&#34; &amp; . &lt;= &#34;2011-01-03&#34;),
             which(. &gt;= &#34;2011-02-02&#34; &amp; . &lt;= &#34;2011-02-08&#34;),
             which(. &gt;= &#34;2011-04-03&#34; &amp; . &lt;= &#34;2011-04-05&#34;),
             which(. &gt;= &#34;2011-04-30&#34; &amp; . &lt;= &#34;2011-05-02&#34;),
             which(. &gt;= &#34;2011-06-04&#34; &amp; . &lt;= &#34;2011-06-06&#34;),
             which(. &gt;= &#34;2011-09-10&#34; &amp; . &lt;= &#34;2011-09-12&#34;),
             which(. &gt;= &#34;2011-10-01&#34; &amp; . &lt;= &#34;2011-10-07&#34;)
          )]
nights &lt;- NA

calendar2011 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/111211125.html
yearID &lt;- 2012
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2012-01-01&#34; &amp; . &lt;= &#34;2012-01-03&#34;),
             which(. &gt;= &#34;2012-01-22&#34; &amp; . &lt;= &#34;2012-01-28&#34;),
             which(. &gt;= &#34;2012-04-02&#34; &amp; . &lt;= &#34;2012-04-04&#34;),
             which(. &gt;= &#34;2012-04-29&#34; &amp; . &lt;= &#34;2012-05-01&#34;),
             which(. &gt;= &#34;2012-06-22&#34; &amp; . &lt;= &#34;2012-06-24&#34;),
             which(. &gt;= &#34;2012-09-30&#34; &amp; . &lt;= &#34;2012-10-07&#34;)
          )]
nights &lt;- NA

calendar2012 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/211216642.html
yearID &lt;- 2013
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2013-01-01&#34; &amp; . &lt;= &#34;2013-01-03&#34;),
             which(. &gt;= &#34;2013-01-01&#34; &amp; . &lt;= &#34;2013-01-03&#34;),
             which(. &gt;= &#34;2013-02-09&#34; &amp; . &lt;= &#34;2013-02-15&#34;),
             which(. &gt;= &#34;2013-04-04&#34; &amp; . &lt;= &#34;2013-04-06&#34;),
             which(. &gt;= &#34;2013-04-29&#34; &amp; . &lt;= &#34;2013-05-01&#34;),
             which(. &gt;= &#34;2013-06-10&#34; &amp; . &lt;= &#34;2013-06-12&#34;),
             which(. &gt;= &#34;2013-09-19&#34; &amp; . &lt;= &#34;2013-09-21&#34;),
             which(. &gt;= &#34;2013-10-01&#34; &amp; . &lt;= &#34;2013-10-07&#34;)
          )]
nights &lt;- c(NA, days[-length(days)]) %&gt;% as.Date(., origin = &#34;1970-01-01&#34;)
nights[which(nights &lt; &#34;2013-07-05&#34;)] &lt;- NA

calendar2013 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/211216642.html
yearID &lt;- 2014
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2014-01-01&#34; &amp; . &lt;= &#34;2014-01-01&#34;),
             which(. &gt;= &#34;2014-01-31&#34; &amp; . &lt;= &#34;2014-02-06&#34;),
             which(. &gt;= &#34;2014-04-05&#34; &amp; . &lt;= &#34;2014-04-07&#34;),
             which(. &gt;= &#34;2014-05-01&#34; &amp; . &lt;= &#34;2014-05-03&#34;),
             which(. &gt;= &#34;2014-05-31&#34; &amp; . &lt;= &#34;2014-06-02&#34;),
             which(. &gt;= &#34;2014-09-06&#34; &amp; . &lt;= &#34;2014-09-08&#34;),
             which(. &gt;= &#34;2014-10-01&#34; &amp; . &lt;= &#34;2014-10-07&#34;)
          )]
nights &lt;- c(NA, days[-length(days)]) %&gt;% as.Date(., origin = &#34;1970-01-01&#34;)

calendar2014 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/211216642.html
yearID &lt;- 2014
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2014-01-01&#34; &amp; . &lt;= &#34;2014-01-01&#34;),
             which(. &gt;= &#34;2014-01-31&#34; &amp; . &lt;= &#34;2014-02-06&#34;),
             which(. &gt;= &#34;2014-04-05&#34; &amp; . &lt;= &#34;2014-04-07&#34;),
             which(. &gt;= &#34;2014-05-01&#34; &amp; . &lt;= &#34;2014-05-03&#34;),
             which(. &gt;= &#34;2014-05-31&#34; &amp; . &lt;= &#34;2014-06-02&#34;),
             which(. &gt;= &#34;2014-09-06&#34; &amp; . &lt;= &#34;2014-09-08&#34;),
             which(. &gt;= &#34;2014-10-01&#34; &amp; . &lt;= &#34;2014-10-07&#34;)
          )]
nights &lt;- c(NA, days[-length(days)]) %&gt;% as.Date(., origin = &#34;1970-01-01&#34;)

calendar2014 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/911321768.html
yearID &lt;- 2015
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2015-01-01&#34; &amp; . &lt;= &#34;2015-01-03&#34;),
             which(. &gt;= &#34;2015-02-18&#34; &amp; . &lt;= &#34;2015-02-24&#34;),
             which(. &gt;= &#34;2015-04-05&#34; &amp; . &lt;= &#34;2015-04-06&#34;),
             which(. &gt;= &#34;2015-05-01&#34; &amp; . &lt;= &#34;2015-05-01&#34;),
             which(. &gt;= &#34;2015-06-20&#34; &amp; . &lt;= &#34;2015-06-22&#34;),
             which(. &gt;= &#34;2015-09-03&#34; &amp; . &lt;= &#34;2015-09-05&#34;),
             which(days&gt;=&#34;2015-09-27&#34;&amp;days&lt;=&#34;2015-09-27&#34;),
             which(. &gt;= &#34;2015-10-01&#34; &amp; . &lt;= &#34;2015-10-07&#34;)
          )]
nights &lt;- c(NA, days[-length(days)]) %&gt;% as.Date(., origin = &#34;1970-01-01&#34;)
nights[which(nights == &#39;2015-09-25&#39;)] &lt;- NA

calendar2015 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/911323994.html
yearID &lt;- 2016
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2016-01-01&#34; &amp; . &lt;= &#34;2016-01-03&#34;),
             which(. &gt;= &#34;2016-02-07&#34; &amp; . &lt;= &#34;2016-02-13&#34;),
             which(. &gt;= &#34;2016-04-02&#34; &amp; . &lt;= &#34;2016-04-04&#34;),
             which(. &gt;= &#34;2016-04-30&#34; &amp; . &lt;= &#34;2016-05-02&#34;),
             which(. &gt;= &#34;2016-06-09&#34; &amp; . &lt;= &#34;2016-06-11&#34;),
             which(. &gt;= &#34;2016-09-15&#34; &amp; . &lt;= &#34;2016-09-17&#34;),
             which(. &gt;= &#34;2016-10-01&#34; &amp; . &lt;= &#34;2016-10-07&#34;)
          )]
nights &lt;- c(NA, days[-length(days)]) %&gt;% as.Date(., origin = &#34;1970-01-01&#34;)

calendar2016 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================


## =============================================================================
## http://www.shfe.com.cn/news/notice/911326468.html
yearID &lt;- 2017
daysInYear &lt;- as.numeric(as.Date(paste0(yearID, &#39;-12-31&#39;)) -
                         as.Date(paste0(yearID, &#39;-01-01&#39;)))
days &lt;- as.Date(0:daysInYear, origin = paste0(yearID, &#39;-01-01&#39;)) %&gt;%
        .[-which(weekdays(.) %in% c(&#34;Saturday&#34;, &#34;Sunday&#34;))] %&gt;%
        .[-c(which(. &gt;= &#34;2017-01-01&#34; &amp; . &lt;= &#34;2017-01-02&#34;),
             which(. &gt;= &#34;2017-01-27&#34; &amp; . &lt;= &#34;2017-02-02&#34;),
             which(. &gt;= &#34;2017-04-02&#34; &amp; . &lt;= &#34;2017-04-04&#34;),
             which(. &gt;= &#34;2017-04-29&#34; &amp; . &lt;= &#34;2017-05-01&#34;),
             which(. &gt;= &#34;2017-05-28&#34; &amp; . &lt;= &#34;2017-05-30&#34;),
             which(. &gt;= &#34;2017-10-01&#34; &amp; . &lt;= &#34;2017-10-08&#34;),
             which(. == &#34;2017-12-31&#34;)
          )]
nights &lt;- c(NA, days[-length(days)]) %&gt;% as.Date(., origin = &#34;1970-01-01&#34;)

calendar2017 &lt;- data.table(nights, days) %&gt;% setNights()
## =============================================================================

calendar &lt;- rbind(calendar2010, calendar2011, calendar2012, calendar2013,
                  calendar2014, calendar2015, calendar2016, calendar2017)
fwrite(calendar, &#39;./data/ChinaFuturesCalendar/ChinaFuturesCalendar.csv&#39;)

## =============================================================================
## 录入 MySQL 数据库
library(RMySQL)
mysql &lt;-   dbConnect(MySQL(),
                     dbname   = &#39;dev&#39;,
                     host     = &#39;192.168.1.166&#39;,
                     port     = 3306,
                     user     = &#39;fl&#39;,
                     password = &#39;******&#39;)
dbSendQuery(mysql, &#34;
            CREATE TABLE IF NOT EXISTS dev.ChinaFuturesCalendar(
              nights Date,
              days Date NOT NULL
            )
            &#34;)
dbSendQuery(mysql,&#34;truncate table ChinaFuturesCalendar&#34;)
dbWriteTable(mysql, &#34;ChinaFuturesCalendar&#34;,
             calendar, row.names=FALSE, append=TRUE)
## =============================================================================
```

# 数据下载

从`2010`年至`2017`年的交易日期已经存放在我的`github`网站，[点击查看](https://github.com/williamlfang/myData/blob/master/data/ChinaFuturesCalendar/ChinaFuturesCalendar.csv)。



---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-10-10-%E4%B8%AD%E5%9B%BD%E6%9C%9F%E8%B4%A7%E4%BA%A4%E6%98%93%E6%97%A5%E5%8E%86/  

