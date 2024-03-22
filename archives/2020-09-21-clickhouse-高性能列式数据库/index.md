# Clickhouse 高性能列式数据库


OLAP方案与其他常见方案（如OLTP或Key-Value访问）有很大不同。所以，如果你想获得不错的表现，尝试使用OLTP或Key-ValueDB来处理分析查询是没有意义的。例如，如果您尝试使用MongoDB或Elliptics进行分析，与OLAP数据库相比，您的性能会很差。

面向列的数据库更适合于OLAP方案（对于大多数查询，处理速度至少提高了100倍），原因如下：

1. 对于I/O, 进行碎片化存储
2. 对于CPU由于执行查询需要处理大量的行，因此它有助于为整个向量调度所有操作，而不是单独的行，或者实现查询引擎，这样就几乎没有调度成本。如果你不这样做，任何半象限的磁盘子系统(half-decent disk subsystem)，查询解释器不可避免地中断(阻塞)CPU。将数据存储在列中并在可能的情况下按列处理是有意义的。
3. 对于分析查询，只需要读取少量的列。在面向列的数据库中，您只能读取所需的数据。例如，如果您需要100列中的5列，则I/O可能会减少20倍。
4. 由于数据是以数据包的形式读取的，因此压缩比较容易。列中的数据也更容易压缩。这进一步减少了I/O量。
5. 由于减少的I/O，更多的数据适合在系统缓存中。

# 安装

# 使用

# 高性能技巧

# 参考链接

1. [什么是ClickHouse](https://blog.csdn.net/jiangshouzhuang/article/details/80256853)
2. [ClickHouse到底是什么？凭啥这么牛逼！](https://blog.csdn.net/chenssy/article/details/108570896)
3. [行式和列式存储说明以及OLAP特点介绍](https://blog.csdn.net/paicMis/article/details/104741413)
4. [clickhouse的安装和使用（单机&#43;集群）](https://blog.csdn.net/wyee000/article/details/90027301)
5. [ClickHouse深度解析](https://blog.csdn.net/weixin_38255219/article/details/106809690)
6. [ClickHouse - LowCardinality 数据类型的神秘之旅](https://blog.csdn.net/jiangshouzhuang/article/details/103268340)
7. [深入理解ClickHouse-本地表和分布式表](https://blog.csdn.net/jiangshouzhuang/article/details/100762451)
8. [ClickHouse - 多卷存储扩大存储容量（生产环境必备）](https://blog.csdn.net/jiangshouzhuang/article/details/103650360)
9. [深入理解ClickHouse-本地表和分布式表](https://blog.csdn.net/jiangshouzhuang/article/details/100762451)
10. [ClickHouse 新特性 Live View 体验](https://blog.csdn.net/jiangshouzhuang/article/details/104981269)
11. [ClickHouse - 创建漂亮的 Grafana 仪表盘](https://blog.csdn.net/jiangshouzhuang/article/details/103759969)
12. [clickhouse的索引结构和查询优化](https://blog.csdn.net/h2604396739/article/details/86172756)
13. [A MAGICAL MYSTERY TOUR OF THE LOWCARDINALITY DATA TYPE](https://altinity.com/blog/2019/3/27/low-cardinality)
14. [Use of LowCardinality and/or INDEX to speed up query performance #4796](https://github.com/ClickHouse/ClickHouse/issues/4796)
15. [Building Infrastructure for ClickHouse Performance](https://minervadb.com/index.php/2019/12/05/building-infrastructure-for-clickhouse-performance/)
16. [Should You Use ClickHouse as a Main Operational Database?](https://www.percona.com/blog/2019/01/14/should-you-use-clickhouse-as-a-main-operational-database/)
17. [https://www.slideshare.net/Altinity/clickhouse-query-performance-tips-and-tricks-by-robert-hodges-altinity-ceo](https://www.slideshare.net/Altinity/clickhouse-query-performance-tips-and-tricks-by-robert-hodges-altinity-ceo)
18. [https://blog.csdn.net/zhangpeterx/article/details/96494877](https://blog.csdn.net/zhangpeterx/article/details/96494877)
19. [CLICKHOUSE-COPIER IN PRACTICE](https://altinity.com/blog/2018/8/22/clickhouse-copier-in-practice)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-09-21-clickhouse-%E9%AB%98%E6%80%A7%E8%83%BD%E5%88%97%E5%BC%8F%E6%95%B0%E6%8D%AE%E5%BA%93/  

