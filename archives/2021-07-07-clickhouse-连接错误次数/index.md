# Clickhouse 连接错误次数


问题：

```bash
&gt;     DBI::dbSendQuery(conn, sql)
Error in select(conn@ptr, statement) :
DB::Exception: All attempts to get table structure failed. Log:
Code: 279, e.displayText() = DB::NetException: All connection tries failed. Log:
Code: 209, e.displayText() = DB::NetException: Timeout: connect timed out: 10.20.140.3:9000 (10.20.140.3:9000) (version 21.4.7.3 (official bui
ld))
Code: 209, e.displayText() = DB::NetException: Timeout: connect timed out: 10.20.140.3:9000 (10.20.140.3:9000) (version 21.4.7.3 (official bui
ld))
Code: 209, e.displayText() = DB::NetException: Timeout: connect timed out: 10.20.140.3:9000 (10.20.140.3:9000) (version 21.4.7.3 (official bui
ld))
```

解决方案参考：[Inconsistent behaviour of Distributed table engine and `remote` table function when called with cluster and with list of addresses](https://github.com/ClickHouse/ClickHouse/issues/4211)

```bash
SET connections_with_failover_max_tries = 5
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-07-07-clickhouse-%E8%BF%9E%E6%8E%A5%E9%94%99%E8%AF%AF%E6%AC%A1%E6%95%B0/  

