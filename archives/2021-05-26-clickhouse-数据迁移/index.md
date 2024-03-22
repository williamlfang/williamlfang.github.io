# clickhouse 数据迁移




# 使用 Remote 方式

```SQL
INSERT INTO tickdata.szse_tbt_Colo102
SELECT * FROM remote(&#39;192.168.1.192:9000&#39;, &#39;tickdata&#39;, &#39;szse_tbt_Colo102&#39;, &#39;sig&#39;, &#39;sig@R7_ch&#39;) WHERE TradingDay = &#39;2021-05-25&#39;
```

&lt;!--more--&gt;


# 使用 Clickhouse Copier 方式



# 使用文件冷备份



# 参考链接

1. [记一次 ClickHouse 数据迁移](https://zhuanlan.zhihu.com/p/220172155)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-05-26-clickhouse-%E6%95%B0%E6%8D%AE%E8%BF%81%E7%A7%BB/  

