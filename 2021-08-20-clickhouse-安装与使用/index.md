# Clickhouse 安装与使用


`Clickhouse` 是一款高性能的列式存储数据库。

&lt;!--more--&gt;

# 安装

参考官网[安装页面](https://clickhouse.tech/docs/en/getting-started/install/)。

## 源代码安装

可以通过下载源代码的方式进行安装，网址：

```bash
# export LATEST_VERSION=`curl https://api.github.com/repos/ClickHouse/ClickHouse/tags 2&gt;/dev/null | grep -Eo &#39;[0-9]&#43;\.[0-9]&#43;\.[0-9]&#43;\.[0-9]&#43;&#39; | head -n 1`
export LATEST_VERSION=21.8.4.51

wget https://repo.clickhouse.tech/tgz/stable/clickhouse-common-static-${LATEST_VERSION}.tgz
wget https://repo.clickhouse.tech/tgz/stable/clickhouse-common-static-dbg-${LATEST_VERSION}.tgz
wget https://repo.clickhouse.tech/tgz/stable/clickhouse-server-${LATEST_VERSION}.tgz
wget https://repo.clickhouse.tech/tgz/stable/clickhouse-client-${LATEST_VERSION}.tgz


tar -xzvf clickhouse-common-static-$LATEST_VERSION.tgz
sudo bash clickhouse-common-static-$LATEST_VERSION/install/doinst.sh

tar -xzvf clickhouse-common-static-dbg-$LATEST_VERSION.tgz
sudo bash clickhouse-common-static-dbg-$LATEST_VERSION/install/doinst.sh

tar -xzvf clickhouse-server-$LATEST_VERSION.tgz
sudo bash clickhouse-server-$LATEST_VERSION/install/doinst.sh
sudo /etc/init.d/clickhouse-server start

tar -xzvf clickhouse-client-$LATEST_VERSION.tgz
sudo bash clickhouse-client-$LATEST_VERSION/install/doinst.sh
```

# 配置

- `server` 的配置文件位于：`/etc/clickhouse-server`
    &#43; `config.xml`
    &#43; `users.xml`
- `client`

## 设置访问 IP

默认只能在本机访问，可以修改 `/etc/clickhouse-server/config.xml`

```bash
&lt;!-- Default values - try listen localhost on IPv4 and IPv6. --&gt;
&lt;!--
&lt;listen_host&gt;::1&lt;/listen_host&gt;
&lt;listen_host&gt;127.0.0.1&lt;/listen_host&gt;
--&gt;

&lt;!-- Default values - try listen localhost on IPv4 and IPv6. --&gt;
&lt;listen_host&gt;::1&lt;/listen_host&gt;
&lt;listen_host&gt;0.0.0.0&lt;/listen_host&gt;
```

## 添加 admin 管理员

取消用户管理的注释：

```bash
&lt;!-- User can create other users and grant rights to them. --&gt;
&lt;!-- &lt;access_management&gt;1&lt;/access_management&gt; --&gt;

&lt;!-- User can create other users and grant rights to them. --&gt;
&lt;access_management&gt;1&lt;/access_management&gt;

## 使用 default 账户登录并创建其他用户
clickhouse-client -h 127.0.0.1 -u default --password ilove

## 创建账户
CREATE USER lfang IDENTIFIED WITH plaintext_password BY &#39;XIA...qq&#39; DEFAULT ROLE ALL;
## 权限
GRANT all ON default to lfang;

## 使用新账户登录，可以看到数据库了
clickhouse-client -h 127.0.0.1 -u lfang --password
data101 :) show databases;
SHOW DATABASES

Query id: 005f9f65-7183-4dcc-b3b6-5187685c168c

┌─name────┐
│ default │
└─────────┘

1 rows in set. Elapsed: 0.003 sec.
```


# 使用

```bash
clickhouse-client -h 127.0.0.1 -u default --password ilove

~/anaconda3/bin/python3 -m pip install clickhouse-cli

~/anaconda3/bin/clickhouse-cli -h 127.0.0.1 -p8123 -u default -Pilove
~/anaconda3/bin/clickhouse-cli -h 192.168.1.101 -p8123 -u default -Pilove

show databases;
```

# 技巧


---

> 作者: william  
> URL: https://williamlfang.github.io/2021-08-20-clickhouse-%E5%AE%89%E8%A3%85%E4%B8%8E%E4%BD%BF%E7%94%A8/  

