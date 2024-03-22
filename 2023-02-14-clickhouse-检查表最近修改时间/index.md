# clickhouse 检查表最近修改时间


`clickhouse` 检查某张表的数据最后修改时间，通过判断以决定是否同步数据。

&lt;!--more--&gt;

```sql
select max(modification_time) from system.parts where table=&#39;sse_cv_snaps&#39; and database=&#39;raven&#39;;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-02-14-clickhouse-%E6%A3%80%E6%9F%A5%E8%A1%A8%E6%9C%80%E8%BF%91%E4%BF%AE%E6%94%B9%E6%97%B6%E9%97%B4/  

