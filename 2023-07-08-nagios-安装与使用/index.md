# nagios 安装与使用



&lt;!--more--&gt;

# Docker 安装 nagios4

## 安装 nagios

```bash
docker pull jasonrivers/nagios
docker run --rm --name nagios4 -p 0.0.0.0:8080:80 jasonrivers/nagios:latest

## 我们需要配置一个用户，我们让docker容器中的nagios配置文件跟虚拟机磁盘建立联系
mkdir -p /opt/nagios4/etc
docker cp nagios4:/opt/nagios/etc /opt/nagios4/
```

然后退出这个 `docker` (ctl-c)。接下来我们需要给账户设置密码，使用了 `htpasswd` 这个工具。


## 安装 apache2 与 httpd

```bash
## ubuntu
sudo apt install apache2

## CentOS
sudo yum install httpd

## 生成密码
sudo htpasswd -c /opt/nagios4/etc/htpasswd.users nagiosadmin

New password:
Re-type new password:
Adding password for user nagiosadmin
```

## 启动服务

```bash
docker run -d --name nagios4 -p 0.0.0.0:8080:80 -v /opt/nagios4/etc:/opt/nagios/etc jasonrivers/nagios:latest
```

现在可以使用账号访问网页：http://127.0.0.1:8080/。

# 使用

## 配置 nagios4/etc

通过指定目录，实现以任意添加 `*.cfg` 文件的方式来增加客户端监控项目。

```bash
mkdir -p /opt/nagios4
sudo docker cp nagios4:/opt/nagios/etc /opt/nagios4

vim /opt/nagios4/etc/nagios.cfg

#cfg_dir=/opt/nagios/etc/servers
#cfg_dir=/opt/nagios/etc/printers
#cfg_dir=/opt/nagios/etc/switches
#cfg_dir=/opt/nagios/etc/routers
cfg_dir=/opt/nagios/etc/colo-machines
cfg_dir=/opt/nagios/etc/research-machines
```

## 添加 host

可以参考 `/opt/nagios/etc/objectes/localhost.cfg`， 比如这个客户端 `/opt/nagios4/etc/research-machines/m2.cfg`

```bash
# 中间的内容块是用于设置设备信息的
define host {
    # use 关键字表示使用的模版，模版将在后续讲解，此处使用的是 linux-server 模版
    use                             linux-server
    # host_name 关键字表示机器的名字，也是在 Web 界面中显示的名字
    host_name                       M2
    # alias 表示机器的别名，一般用作机器别名的描述
    alias                           M2@WuyaCapital
    # address 设置该机器的 IP 地址，以便与数据的获取与被动监控的请求
    address                         192.168.1.162
    # 最大的尝试次数，也就是在某服务监控出错再次运行监控命令获取数据的次数
    max_check_attempts              3
    # 检测的时间段
    check_period                    24x7
    # 发送消息提醒的时间间隔
    notification_interval           30
    # 发送消息提醒的时间段
    notification_period             24x7
}

define service{
    use                             local-service,graphed-service         ; Name of service template to use
    host_name                       M2
    service_description             Current Users
    check_command                   check_nrpe!check_users
    check_interval                  1
    retry_interval                  1
    check_period                    24x7
    notification_interval           1
    notification_period             24x7
    notifications_enabled           1
    register                        1
}

define service{
    use                             local-service,graphed-service         ; Name of service template to use
    host_name                       M2
    service_description             Total Procs
    check_command                   check_nrpe!check_total_procs
    check_interval                  1
    retry_interval                  1
    check_period                    24x7
    notification_interval           1
    notification_period             24x7
    notifications_enabled           1
    register                        1
}
```


同时，我们需要修改命令

```bash
vim /opt/nagios4/etc/objects/command.cfg

# &#39;check_NRPE&#39; command definition
define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
        }
```

# 客户端安装 nrpe

## 配置

```bash
vim /etc/nagios/nrpe.cfg

command[check_users]=/usr/local/nagios/libexec/check_users -w 5 -c 10
command[check_load]=/usr/local/nagios/libexec/check_load -r -w .15,.10,.05 -c .30,.25,.20
command[check_hda1]=/usr/local/nagios/libexec/check_disk -w 20% -c 10% -p /dev/hda1
command[check_zombie_procs]=/usr/local/nagios/libexec/check_procs -w 5 -c 10 -s Z
command[check_total_procs]=/usr/local/nagios/libexec/check_procs -w 150 -c 200

allowed_hosts=127.0.0.1,192.168.1.82
```

```bash
systemctl enable nrpe
systemctl start nrpe
```

## 测试

```bash
## 服务器测试
/opt/nagios/libexec/check_nrpe  -H 192.168.1.162 -p 5666 -c check_total_procs

PROCS CRITICAL: 605 processes | procs=605;150;200;0;
```

# Ref

- [Nagios on CentOS 7](https://gist.github.com/evanjuang/d81ca6f05aa02e2d92ad68f5f867235c)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-07-08-nagios-%E5%AE%89%E8%A3%85%E4%B8%8E%E4%BD%BF%E7%94%A8/  

