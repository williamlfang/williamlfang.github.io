# 修改MySQL数据存储目录


`MySQL`默认的数据存储路径是在 `/var` 下面。由于该目录可能设置空间不大，后期会影响使用，我准备把数据存储在 `/data/DataBase` 这个目录下面，用于集中的管理，后期也可以把磁盘空间增加到足够大。

本文参考了这篇[文章](http://www.cnblogs.com/kerrycode/p/4371938.html)。

# 确认当前存储路径

```bash
[root@localhost ~]# mysqladmin -u root -p variables | grep datadir
Enter password:
| datadir                                           | /var/lib/mysql/
```

# 停止 `MySQL` 服务

在 `CentOS7` 下，统一使用 `systemctl` 来管理所有的服务进程。同时，需要注意的是，从 `MySQL5.5` 开始，默认的存储引擎改成了 `mariadb`。因此，为了停止 `MySQL` 服务进程，我们可以使用命令：

```bash
[root@localhost ~]# systemctl stop mariadb.service
Warning: mariadb.service changed on disk. Run &#39;systemctl daemon-reload&#39; to reload units.
```

# 把数据移动到指定目录

事先在 `/data/` 文件夹下面建立 `/data/DataBase` 用来专门存储 `MySQL` 所有的数据。我们需要把原来的数据库移动到该目录下：

```bash
[root@localhost data]# mv /var/lib/mysql /data/DataBase/
```

# 修改配置文件

一般是在 `/etc/my.cnf` 这个文件：

```bash
vim /etc/my.cnf

 [mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
## datadir=/var/lib/mysql
datadir=/data/DataBase/mysql
## socket=/var/lib/mysql/mysql.sock
socket=/data/DataBase/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

[client]
socket=/data/DataBase/mysql/mysql.sock
```

# 检查是否已经生效

```bash
[root@localhost data]# systemctl start mariadb.service
[root@localhost data]# mysqladmin -u root -p variables | grep datadir
Enter password:
| datadir                                           | /data/DataBase/mysql/
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-12-11-%E4%BF%AE%E6%94%B9mysql%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E7%9B%AE%E5%BD%95/  

