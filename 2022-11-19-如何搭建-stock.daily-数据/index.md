# 如何搭建 Stock.Daily 数据



# 如何搭建 Stock.Daily 数据

Created: November 18, 2022 10:09 PM
Last Edited Time: November 18, 2022 11:43 PM
Type: Technical Spec

对于股票研究与交易，我们需要一份内容正确且规则统一的历史数据 ，尽可能的降低数据噪音，避免因为数据错误导致的谬误，提高实证研究的可靠性与准确性。

根据现有的数据，我们复原了2014年1月至今的股票日频数据（`stock.daly`），运用统一的规则，对历史数据与每日更新的实盘数据进行获取、清洗、转换、验证、入库。

本文档旨在介绍股票日盘数据库的整理规则与入库标准，以供参考。

&lt;!--more--&gt;


# 数据概览

## 数据来源

- 历史数据（2014.01.01 ~ 2022.11.18）
    - PreClose、OHLC、Volume、Turnover 来自交易所
        - 上海：根据购买的交易所历史数据（Day.csv）
        - 深圳：从深交所网站爬虫获取
    - UpperLimit、LowerLimit：来自 RiceQuant api 获取
- 每日更新数据（2022-11-18起）
    - PreClose、UpperLimit、LowerLimit：来自交易柜台查询（xtp_info, xeleq_info）
    - OHLC、Volume、Turnover  来自万得落地数据库（MySQL）、交易所网站爬虫
- BeginDay、EndDay：爬虫交易所股票列表
- TotalShare、FloatAShare：万得落地数据库（MySQL）、交易所网站爬虫
- STStatus：根据股票名称是否包含 `ST|退` 判断，实盘数据来自交易柜台查询、历史数据来自网易财经 `Net163Scraper`

## 每日更新时间：18:30/19:30

## 数据库格式

```sql
CREATE TABLE stock.daily
(
    `TradingDay` Date,
    `Exchange` LowCardinality(String),
    `Category` Enum(&#39;X&#39;=0,&#39;FUTURES&#39;=1,&#39;STOCK&#39;=2,&#39;BOND&#39;=3,&#39;FUND&#39;=4),
    `Product` Enum(&#39;X&#39;=0,&#39;STK&#39;=1,&#39;ETF&#39;=2,&#39;INDEX&#39;=3),
    `Symbol` LowCardinality(String),
    `PreClose` Nullable(Float32),
    `Open` Nullable(Float32),
    `High` Nullable(Float32),
    `Low` Nullable(Float32),
    `Close` Float32,
    `UpperLimit` Nullable(Float32),
    `LowerLimit` Nullable(Float32),
    `Volume` Nullable(UInt64),
    `Amount` Nullable(Float64),
    `BeginDay` Nullable(Date),
    `EndDay` Nullable(Date),
    `STStatus` Enum(&#39;TRUE&#39;=1,&#39;FALSE&#39;=0) DEFAULT 0,
    `TradeStatus` Enum(&#39;X&#39;=0,&#39;NEW&#39;=1,&#39;TRADING&#39;=2,&#39;SUSPENDED&#39;=3),
    `TotalShare` Nullable(Float32),
    `FloatAShare` Nullable(Float32)
)
ENGINE = MergeTree
ORDER BY (TradingDay, Exchange, Symbol)
SETTINGS index_granularity = 8192
```

## 字段说明

- `Category` 与 `Product` 用于区分不同交易市场
    - `FUTURES：期货类`
    - `STOCK：证券类`
        - `STK`
        - `INDEX`
    - `BOND：债券类`
    - `FUND：基金类`
        - `ETF`
- `PreClose` : 交易所除权除息后的昨收，可结合 LastClose 计算复权因子（`AdjFactor`）
- `BeginDay` : 股票上市日期
- `EndDay` : 股票退市日期
- `STStatus` : 股票是否出于 ST 状态（ST|S|*ST|SST|退市），每日根据股票名称是否包含ST或退来判断
- `TradeStatus` : 当天的交易状态
    - `NEW` : 上市第一日
    - `TRADING` : 正常交易
    - `SUSPENDED` : 当日停牌
- `TotalShare` : 总股本（万得对应：TOT_SHARE_TODAY）
- `FloatAShare` : 流通股（总股本减去限售股）

## 数据清洗规则

- 对于没有涨跌停的合约（上市前五日），统一设置涨跌停价格为

    ```python
    UPPER_LIMIT_PX_THRES = 999999.999
    LOWER_LIMIT_PX_THRES = 0.001

    df.fillna({&#39;UpperLimit&#39;: self.UPPER_LIMIT_PX_THRES}, inplace = True)
    df.fillna({&#39;LowerLimit&#39;: self.LOWER_LIMIT_PX_THRES}, inplace = True)
    df.loc[((df[&#39;days&#39;] &lt;= 5) | (df.TradeStatus.isin([&#39;NEW&#39;]))) &amp; (df.UpperLimit &lt;= 0.01), &#39;UpperLimit&#39;] = self.UPPER_LIMIT_PX_THRES
    df.loc[((df[&#39;days&#39;] &lt;= 5) | (df.TradeStatus.isin([&#39;NEW&#39;]))) &amp; (df.LowerLimit &lt;= 0.01), &#39;LowerLimit&#39;] = self.LOWER_LIMIT_PX_THRES
    ```

- 对于停牌的股票：
    - 有可能拿不到当日的数据，这时候需要先把当日所有的合约补齐（TRADING &#43; SUSPENDED）

        ```python
        _day = cal.ymd(df.TradingDay.values[0])
        sql = f&#34;&#34;&#34;
        		select Exchange,Symbol,
                   OnlistingDay,
                   DelistingDay
            from bardata.listing
            where OnlistingDay &lt;= &#39;{_day}&#39;
            and DelistingDay &gt; &#39;{_day}&#39;
            &#34;&#34;&#34;
        df_listing = ch.read(sql)

        ## 先合成所有的上市合约
        df = pd.merge(df, df_listing, on = &#39;Symbol&#39;, how = &#39;outer&#39;, suffixes = [&#39;&#39;, &#39;_listing&#39;])
        ```

    - 使用上一次有效交易日的收盘价作为当天的 OHLC，Volume = 0, Turnover = 0.0, UpperLimit = LowerLimit = PreClose

        ```python
        ## 获取上一次有效交易日的数据
        sql = f&#34;&#34;&#34;
        		select stock.daily.* from stock.daily as a,
                   (select Symbol, max(TradingDay) as LastDay
                    from stock.daily
                    where TradingDay &lt; &#39;{_day}&#39;
                    and Volume &gt; 0
                    group by Symbol) as b
             where a.Symbol = b.Symbol and a.TradingDay = b.LastDay
             and BeginDay &lt;= &#39;{_day}&#39;
             and EndDay &gt; &#39;{_day}&#39;
        		&#34;&#34;&#34;
        df_last = self.ch.read(sql)
        ## 然后使用上一次最后交易的数据来补充
        df = pd.merge(df, df_last, on = &#39;Symbol&#39;, how = &#39;outer&#39;, suffixes = [&#39;&#39;, &#39;_last&#39;])

        l = [&#39;PreClose&#39;, &#39;Open&#39;, &#39;High&#39;, &#39;Low&#39;, &#39;Close&#39;, &#39;UpperLimit&#39;, &#39;LowerLimit&#39;,
             &#39;Volume&#39;, &#39;Amount&#39;, &#39;STStatus&#39;, &#39;TradeStatus&#39;, &#39;TotalShare&#39;, &#39;FloatAShare&#39;]
        for col in l:
        		if col in [&#39;Volume&#39;, &#39;Amount&#39;]:
        		    val = 0
        		elif col in [&#39;PreClose&#39;, &#39;Open&#39;, &#39;High&#39;, &#39;Low&#39;, &#39;Close&#39;, &#39;UpperLimit&#39;, &#39;LowerLimit&#39;]:
                val = df.loc[(df.Product_last == &#39;STK&#39;) &amp;
                             (df.Exchange_last.isin([&#39;sse&#39;, &#39;szse&#39;])) &amp;
                             ((pd.isna(df[col])) | (df.Volume &lt;= 0.0001)), &#34;Close_last&#34;]
            elif col in [&#39;TradeStatus&#39;]:
        		    val = &#39;SUSPENDED&#39;
            else:
                val = df.loc[(df.Product_last == &#39;STK&#39;) &amp;
                             (df.Exchange_last.isin([&#39;sse&#39;, &#39;szse&#39;])) &amp;
                             ((pd.isna(df[col])) | (df.Volume &lt;= 0.0001)), f&#34;{col}_last&#34;]

            df.loc[(df.Product_last == &#39;STK&#39;) &amp;
                   (df.Exchange_last.isin([&#39;sse&#39;, &#39;szse&#39;])) &amp;
                   ((pd.isna(df[col]) | (df.Volume &lt;= 0.0001))), col] = val
        ```

- 对于指数，统一设置：

    ```python
    for col in [&#39;Open&#39;, &#39;High&#39;, &#39;Low&#39;]:
    		df.loc[(df.Product == &#39;INDEX&#39;) &amp; (df[col] &lt;= 0.0001), col] = df.loc[(df.Product == &#39;INDEX&#39;) &amp; (df[col] &lt;= 0.0001), &#39;Close&#39;]
    for col in [&#39;UpperLimit&#39;, &#39;LowerLimit&#39;, &#39;TotalShare&#39;, &#39;FloatAShare&#39;]:
    		df.loc[df.Product == &#39;INDEX&#39;, col] = np.nan

    df.loc[df.Product == &#39;INDEX&#39;, &#39;TradeStatus&#39;] = &#39;TRADING&#39;
    df.loc[df.Product == &#39;INDEX&#39;, &#39;STStatus&#39;] = False
    ```

- STStatue 规则：

    ```python
    _day = cal.ymd(df.TradingDay.values[0])[:10]
    df_xtp = self.read_xtp_info(_day)

    df = pd.merge(df, df_xtp,
                  left_on = [&#39;Symbol&#39;],
                  right_on = [&#39;Symbol&#39;],
                  how = &#39;left&#39;,
                  suffixes = [&#39;&#39;, &#39;_xtp&#39;])
    df[&#39;STStatus&#39;] = df[&#39;TickerName&#39;].apply(
        lambda x: True if re.search(r&#34;sT|St|st|ST|退|退市|^退&#34;, str(x), re.IGNORECASE) else False
        )
    ```

- 其他字段设置：

    ```python
    df[&#39;Category&#39;] = df[[&#39;Category&#39;, &#39;Symbol&#39;]].apply(
        lambda x:
            self.convert_category(
                x[0] if x[0] in self.CATEGORY_DICT
                else self.guess_category_from_symbol(x[1])
                ),
        axis = 1)
    df[&#39;Product&#39;] = df[[&#39;Product&#39;, &#39;Symbol&#39;]].apply(
        lambda x:
            self.convert_product(
                x[0] if not pd.isna(x[0])
                else self.guess_product_from_symbol(x[1])
                ),
        axis = 1)
    df[&#39;STStatus&#39;] = df[&#39;STStatus&#39;].apply(lambda x: 1 if x else 0)
    df[&#39;TradeStatus&#39;] = df[&#39;TradeStatus&#39;].apply(self.convert_tradestatus)
    ```


## 入库前检查规则

&gt; PreClose, Open, High, Low, Close, UpperLimit, LowerLimit, (Amount/Volume), 这几个应该是同一个数量级；
TotalShare, FloatAShare, FreeShare, (NetAsset/Close) 应该是差不多是一个。
&gt;
&gt;
&gt; ```
&gt;     检查项目：
&gt;     1. vwap vs close
&gt;     2. turnover = Volume/FloatAShare &lt; 1.0，
&gt;     3. lower_limit &lt;= px &lt;= upper_limit
&gt;     4. pb &gt; 0.2(去掉负的 NetAsset)
&gt;     5. 涨跌停幅度（去掉新股）
&gt;     6. 关于 TotalShare vs TotalShareToday: 前面是全部股本,后面是当日股本,比如
&gt;         TotalShare &lt; FloatAShare: ---------------------------
&gt;         TradingDay     Symbol         TotalShare        FloatAShare
&gt;         2020-10-19  603882.SH 457,884,577.000000 459,487,577.000000
&gt;     7. 如果是 ST, 涨跌幅是 5%
&gt;
&gt;     可以再加两个检查，
&gt;     1. 就是&#39;STK&#39;里TradeStatus不应该出现&#39;X&#39;(我这边现在就是用Suspen来判断股票不交易)。
&gt;     2. 也可以检查一下每天，Volume=0, Amount=0和TradeStatus=&#39;Sus&#39; 是不是同一批股票
&gt;
&gt;     对于index的检查(000016.SH, 000300.SH, 000905.SH, 000852.SH, 000985.CSI)暂时只需要检查这五个就行了。
&gt;     1. 每天都有数据
&gt;     2. PreClose, Open, High, Low, Close，Volume, Amount不能有NaN。UpperLimit, LowerLimit，Totalshare, FloatAshares强制是NaN.
&gt; ```
&gt;

# 历史数据

# 每日更新数据


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-19-%E5%A6%82%E4%BD%95%E6%90%AD%E5%BB%BA-stock.daily-%E6%95%B0%E6%8D%AE/  

