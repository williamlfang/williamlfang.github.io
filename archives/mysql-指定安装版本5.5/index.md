# MySQL: 指定安装版本5.5


参考连接：[Is it possible to install MySQL 5.5 or 5.6 on Ubuntu 16.04?](https://askubuntu.com/questions/763240/is-it-possible-to-install-mysql-5-5-or-5-6-on-ubuntu-16-04)

# StackOverFlow

Step by step guide* to install mysql 5.5.x on Ubuntu 16.04 Xenial-Xerus. Please see this [documentation](https://www.scribd.com/document/320972085/Install-MySQL-5-5-Ubuntu16-04-Xenial-Xerus)

OR

See steps below:

Installing MySQL 5.5.51 on Ubuntu 16.06

1. Uninstall any existing version of MySQL

    ```
    sudo rm /var/lib/mysql/ -R
    ```

2. Delete the MySQL profile

    ```
    sudo rm /etc/mysql/ -R
    ```

3. Automatically uninstall mysql

    ```
    sudo apt-get autoremove mysql* --purge
    sudo apt-get remove apparmor
    ```

4. Download version 5.5.51 from MySQL site

    ```
    wget https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.56-linux-glibc2.5-x86_64.tar.gz
    ```

5. Add `mysql` user group

    ```
    sudo groupadd mysql
    ```

6. Add `mysql` (not the current user) to `mysql` user group

    ```
    sudo useradd -g  mysql mysql
    ```

7. Extract `mysql-5.5.51-linux2.6-x86_64.tar.gz` to `/usr/local`

    ```
    cd /usr/local
    sudo tar -xvf mysql-5.5.49-linux2.6-x86_64.tar.gz
    ```

8. Create `mysql` folder in `/usr/local`

    ```
    sudo mv mysql-5.5.49-linux2.6-x86_64 mysql
    ```

9. Set `mysql` directory owner and user group

    ```
    cd mysql
    sudo chown -R mysql:mysql *
    ```

10. Install the required lib package

    ```
    sudo apt-get install libaio1
    ```

11. Execute mysql installation script

    ```
    sudo scripts/mysql_install_db --user=mysql
    ```

12. Set mysql directory owner from outside the mysql directory

    ```
    sudo chown -R root .
    ```

13. Set data directory owner from inside mysql directory

    ```
    sudo chown -R mysql data
    ```

14. Copy the mysql configuration file

    ```
    sudo cp support-files/my-medium.cnf /etc/my.cnf 
    ```

15. Start mysql

    ```
    sudo bin/mysqld_safe --user=mysql &amp;
    sudo cp support-files/mysql.server /etc/init.d/mysql.server
    ```

16. Initialize root user password

    ```
    sudo bin/mysqladmin -u root password &#39;111111&#39;
    ```

17. Start mysql server

    ```
    sudo /etc/init.d/mysql.server start
    ```

18. Stop mysql server

    ```
    sudo /etc/init.d/mysql.server stop
    ```

19. Check status of mysql

    ```
    sudo /etc/init.d/mysql.server status
    ```

20. Enable myql on startup

    ```
    sudo update-rc.d -f mysql.server defaults 
    ```

21. Disable mysql on startup (Optional)

    ```
    sudo update-rc.d -f mysql.server remove
    ```

22. Add mysql path to the system

    ```
    sudo ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
    ```

23. Now directly use the command below to start mysql

    ```
    mysql -u root -p 
    ```

PS: One needs to reboot in order for the changes to take place.

Based on a Chinese [blog](http://quangelab.com/ubuntu-mysql/)



# ubuntu 16.04 mysql 相关

# ubuntu 16.04 mysql 相关

### 如何彻底卸载某一版本的数据库

彻底删除ubuntu下的mysql： 1、删除mysql的数据文件

```
sudo rm /var/lib/mysql/ -R
```

2、删除mqsql的配置文件

```
sudo rm /etc/mysql/ -R
```

3自动卸载mysql的程序

```
sudo apt-get autoremove mysql* --purge
sudo apt-get remove apparmor
```

### ubuntu 16.04上如何安装mysql 5.5.49版本

[此网址打开以后选择linux－generic平台，最后一个文件](http://dev.mysql.com/downloads/mysql/5.5.html#downloads)

然后按以下步骤安装 [参考官方原文](http://dev.mysql.com/doc/refman/5.5/en/binary-installation.html)

1、添加mysql用户组

```
sudo groupadd mysql
```

2、添加 mysql（不是当前用户）添加到 mysql 用户组

```
sudo useradd -g  mysql mysql
```

3、解压 mysql-5.5.49-linux2.6-x86_64.tar.gz（我将此文件放在了git［当前用户］的`文档`文件夹中） 到 /usr/local 进入 /usr/local

```
cd /usr/local
sudo tar zvxf /home/git/文档/mysql-5.5.49-linux2.6-x86_64.tar.gz
sudo mv mysql-5.5.49-linux2.6-x86_64 mysql 
```

4、设置 mysql 目录的拥有者和所属的用户组

```
cd mysql
sudo chown -R mysql .
sudo chgrp -R mysql .
```

5、安装所需要lib包

```
sudo apt-get install libaio1 
```

6、执行mysql 安装脚本

```
sudo scripts/mysql_install_db --user=mysql  
```

7、再次设置 mysql 目录的拥有者

```
sudo chown -R root .
```

8、设置 data 目录的拥有者

```
sudo chown -R mysql data
```

9、复制 mysql 配置文件

```
sudo cp support-files/my-medium.cnf /etc/my.cnf  
```

10、启动 mysql

```
sudo bin/mysqld_safe --user=mysql &amp; 
sudo cp support-files/mysql.server /etc/init.d/mysql.server
```

11、初始化 root 用户密码

```
sudo bin/mysqladmin -u root password &#39;111111&#39;
```

12、启动

```
sudo /etc/init.d/mysql.server start
```

13、停止

```
sudo /etc/init.d/mysql.server stop
```

14、查看状态

```
sudo /etc/init.d/mysql.server status 
```

15、开机启动

```
sudo update-rc.d -f mysql.server defaults  
```

16、停止开机启动

```
sudo update-rc.d -f mysql.server remove 
```

17、把 /usr/local/mysql/bin/mysql 命令加到用户命令中，这样就不用每次都加 mysql命令的路径

```
sudo ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql 
现在就直接可以使用 mysql 命令了
 mysql -u root -p  
```

Written on April 30, 2016



# Ubuntu 完全卸载、源代码安装 MySQL8.0

首先用 dpkg --list|grep mysql 查看自己的 mysql 有哪些依赖

```bash
dpkg --list|grep mysql
```

先卸载 

```bash
sudo apt-get remove mysql-common
```

然后：

```bash
sudo apt-get autoremove --purge mysql-server-5.0 
```



再查看，还剩什么就卸载什么

```bash
dpkg --list|grep mysql 
```



最后清楚残留数据：

```bash
dpkg -l |grep ^rc|awk &#39;{print $2}&#39; |sudo xargs dpkg -P
```

就可以了



# CentOS7：安装 MySQL5.5

```bash
## 有可能报错：myriadb-libs
## 需要删除
rpm -qa | grep mariadb
sudo rpm -ev --nodeps mariadb-libs-5.5.65-1.el7.x86_64
rpm -ev --nodeps mariadb-5.5.65-1.el7.x86_64
rpm -ev --nodeps mariadb-devel-5.5.65-1.el7.x86_64

rm /usr/lib64/mysql/libmysqlclient.so.18
rm -rf /var/lib/mysql/
rm -rf /usr/mysql/
rm -rf /usr/share/mysql
rm -rf /etc/my.cnf
rm -rf /var/log/mysqld.log  ## 如果不删除，会影响新安装的 MySQL 无法写入密码

## 安装 net-tools
yum install net-tools

## 1. 先安装 MySQL-shared-compat
sudo rpm -ivh MySQL-shared-compat-5.5.60-1.el7.x86_64.rpm

## 2. 接着安装
rpm -ivh MySQL-server-5.5.60-1.el7.x86_64.rpm

## 3. 然后安装
rpm -ivh MySQL-client-5.5.60-1.el7.x86_64.rpm

## 4. 继续安装
rpm -ivh MySQL-devel-5.5.60-1.el7.x86_64.rpm

## 5. 最后安装依赖包
rpm -ivh MySQL-shared-5.5.60-1.el7.x86_64.rpm
rpm -ivh MySQL-shared-compat-5.5.60-1.el7.x86_64.rpm

## 启动
/etc/init.d/mysql start
## 修改密码
/usr/bin/mysqladmin -u root password &#39;******&#39;
sudo mysql_install_db --datadir=/var/lib/mysql
sudo chown mysql:mysql /var/lib/mysql -R
## 安全设置
/usr/bin/mysql_secure_installation
## 帮助
/usr/sbin/mysqld --help
service mysql start
mysql -uroot -p
```

https://www.jianshu.com/p/fbd2686e3acb

---

> 作者:   
> URL: https://williamlfang.github.io/archives/mysql-%E6%8C%87%E5%AE%9A%E5%AE%89%E8%A3%85%E7%89%88%E6%9C%AC5.5/  

