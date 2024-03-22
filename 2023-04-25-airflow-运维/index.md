# airflow 运维


使用 `airflow` 管理工作流。

&lt;!--more--&gt;



# Install

```bash
## 设置 DAG 目录
export AIRFLOW_HOME=/root/app

## 不显示 example 案例
export AIRFLOW__CORE__LOAD_EXAMPLES=False

airflow db init
```



## 添加用户

```bash
## 需要确保 $AIRFLOW_HOME 是存在的，否则触发不同的 db，会导致数据库匹配不对，进而引发账户-密码错误
airflow users create \
    --username admin \
    --firstname admin \
    --lastname admin \
    --role Admin \
    --email admin@example.org
```

## 启动

````bash
## 启动 webserver
airflow webserver -p 8080 -D

## 启动 scheduler
airflow scheduler -D

## 1. vim ariflow.cfg
default_timezone = utc 修改为 default_timezone = Asia/Shanghai
default_ui_timezone = UTC 修改为 default_ui_timezone = Asia/Shanghai
````

## 测试

```bash
## 先用 Python 测试代码
python hello.py

airflow tasks list hello

airflow tasks test hello print_date
airflow tasks test hello py_say_hello 20230514

## 启动一个 dag
airflow dags list
airflow dags trigger pretrading.all.csv
```

## 切换 db 数据库

`airflow` 内置的默认数据库是 `sqlite`，这个主要是为了方便测试，不需要额外的配置即可启动 `airflow`。但是这种情况下，只能使用 `SequencialOperator`，无法实现并行化，因此官方不推荐。

我们可以修改数据库为 `Postgre` 或者 `MySQl`，进行实现并行化。

### ~~MySQL~~



## MariaDB

```bash
## 需要这个 so 放在 /app
libmysqlclient.so.18

setenforce 0
getenforce
vim /etc/selinux/config
SELINUX=disabled

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
# targeted - Targeted processes are protected,
# minimum - Modification of targeted policy. Only selected processes are protected.
# mls - Multi Level Security protection.
SELINUXTYPE=targeted

sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum install -y mysql-community-server
sudo systemctl start mysqld

## 首次安装的密码
grep &#34;temporary password&#34; /var/log/mysqld.log
## 如果办法登录
## 则使用一下方法，可以直接 mysql -u root -p 不用输秘密
Open and edit /etc/my.cnf or /etc/mysql/my.cnf, depending on your distribution.
Add skip-grant-tables under [mysqld]
Restart MySQL
You should be able to log in to MySQL now using the below command mysql -u root -p
Run mysql&gt; flush privileges;
Set new password by ALTER USER &#39;root&#39;@&#39;localhost&#39; IDENTIFIED BY &#39;NewPassword&#39;;
Go back to /etc/my.cnf and remove/comment skip-grant-tables
Restart MySQL
Now you will be able to login with the new password mysql -u root -p

## 报错：Your password does not satisfy the current policy requirements
mysql&gt; SHOW VARIABLES LIKE &#39;validate_password%&#39;;
&#43;--------------------------------------&#43;--------&#43;
| Variable_name                        | Value  |
&#43;--------------------------------------&#43;--------&#43;
| validate_password_check_user_name    | OFF    |
| validate_password_dictionary_file    |        |
| validate_password_length             | 8      |
| validate_password_mixed_case_count   | 1      |
| validate_password_number_count       | 1      |
| validate_password_policy             | MEDIUM |
| validate_password_special_char_count | 1      |
&#43;--------------------------------------&#43;--------&#43;
7 rows in set (0.00 sec)

mysql&gt; SET GLOBAL validate_password_length = 6;
mysql&gt; SET GLOBAL validate_password_policy = LOW;


mysql -uroot -p
CREATE DATABASE IF NOT EXISTS airflow DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
create user &#39;airflow&#39;@&#39;%&#39; identified by &#39;xxxxxxxx&#39;;
grant all privileges on airflow.* to airflow@localhost identified by &#39;xxxxxxxx&#39;;
grant all privileges on airflow.* to &#39;airflow&#39;@&#39;%&#39; identified by &#39;xxxxxxxx&#39;;
flush privileges;
select user,authentication_string,host from mysql.user;

&#43;---------------&#43;-------------------------------------------&#43;-----------&#43;
| user          | authentication_string                     | host      |
&#43;---------------&#43;-------------------------------------------&#43;-----------&#43;
| root          | *51F9815BB277B91759503A29D46EC9364D361F1C | localhost |
| mysql.session | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | localhost |
| mysql.sys     | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | localhost |
| airflow       | *51F9815BB277B91759503A29D46EC9364D361F1C | %         |
&#43;---------------&#43;-------------------------------------------&#43;-----------&#43;
4 rows in set (0.00 sec)


executor = LocalExecutor
sql_alchemy_conn = mysql://airflow:xxxxxxxx@localhost:3306/airflow?charset=utf8
#初始化数据库
#如果前面的两个utf8没写好，可能会出现/airflow/lib/python3.7/encodings/cp1252.py错误
# 若之前使用sqllite初始化过,需要
# 重置数据库
airflow db reset
# 初始化数据库
airflow db init

## 1067 - Invalid default value for ‘update_at‘
## MySQLdb.OperationalError: (1067, &#34;Invalid default value for &#39;updated_at&#39;&#34;)
set GLOBAL sql_mode =&#39;STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION&#39;
```

# Ref



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-25-airflow-%E8%BF%90%E7%BB%B4/  

