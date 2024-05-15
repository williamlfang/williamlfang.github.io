# clickhouse 运维



## 重启服务

```bash
sudo service clickhouse-server restart

## 可以待配置启动，方便查找问题
sudo -u clickhouse clickhouse-server --config-file=/etc/clickhouse-server/config.xml
```

&lt;!--more--&gt;

## 修改 default 用户配置

```bash
vim /etc/clickhouse-server/users.xml

&lt;access_management&gt;1&lt;/access_management&gt;
&lt;named_collection_control&gt;1&lt;/named_collection_control&gt;
&lt;show_named_collections&gt;1&lt;/show_named_collections&gt;
&lt;show_named_collections_secrets&gt;1&lt;/show_named_collections_secrets&gt;
```


## 开放远程访问

```bash
vim /etc/clickhouse-server/config.xml

## 将以下配置行注释去掉，允许所以访问
&lt;listen_host&gt;::&lt;/listen_host&gt;
```

## 添加用户

```mysql
CREATE USER IF NOT EXISTS dataops IDENTIFIED WITH sha256_password BY &#39;xxxxxxxxxxx&#39;;
GRANT ALL ON bardata.* TO dataops;
```

## 登录

```bash
clickhouse-client -h 192.168.2.100  -u dataops  --password
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-13-clickhouse-%E8%BF%90%E7%BB%B4/  

