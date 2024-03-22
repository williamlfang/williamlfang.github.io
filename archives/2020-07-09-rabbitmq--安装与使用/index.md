# RabbitMQ: 安装与使用




# 消息队列

`RabbitMQ` 是一个在 AMQP（Advanced Message Queuing Protocol ）基础上实现的、可复用的企业消息系统。它可以用于大型软件系统各个模块之间的高效通信，支持高并发，支持可扩展。

## AMQP

即 Advanced Message Queuing Protocol, 一个提供统一消息服务的应用层标准**高级消息队列协议**, 是应用层协议的一个开放标准, 为面向消息的中间件设计。基于此协议的客户端与消息中间件可传递消息，并不受客户端 / [中间件](https://link.jianshu.com/?t=https://baike.baidu.com/item/中间件)不同产品，不同的开发语言等条件的限制。

## MQ

全称为 Message Queue, 消息队列。是一种应用程序对应用程序的通信方法。应用程序通过读写出入队列的消息（针对应用程序的数据）来通信，而无需专用连接来链接它们。

**消息传递**指的是程序之间通过在消息中发送数据进行通信，而不是通过直接调用彼此来通信。队列的使用除去了接收和发送应用程序同时执行的要求。

在项目中，将一些无需即时返回且耗时的操作提取出来，进行了异步处理，而这种异步处理的方式大大的节省了服务器的请求响应时间，从而提高了系统的吞吐量。

## RabbitMQ 应用场景

1. 降低耦合
2. 削峰
3. 支持持久化
4. 支持消息的确认机制
5. 集群扩展
6. 提供了 Web 可视化管理和监控


![RabbitMQ 工作原理](/images/2020-07-09-RabbitMQ--安装与使用/工作原理.jpg &#34;RabbitMQ 工作原理&#34;)


# 安装

## Ubuntu

为了安装新版本，建议到[官网](https://www.rabbitmq.com/install-debian.html#manual-installation)

```bash
## 安装依赖包　socat
sudo apt install socat
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.5/rabbitmq-server_3.8.5-1_all.deb
sudo dpkg -i rabbitmq-server_3.8.5-1_all.deb
```



## CentOS7

```bash
sudo yum install -y socat

# 下载
$ wget https://github.com/rabbitmq/erlang-rpm/releases/download/v22.3/erlang-22.3-1.el7.x86_64.rpm

# 安装

$ rpm -ivh erlang-22.3-1.el7.x86_64.rpm
```

# 使用

## 启动服务

使用命令启动服务

```bash
# 直接启动
sudo rabbitmq-server

# -detached为可选参数，表示后台开启
sudo rabbitmq-server -detached

#关闭RabbitMQ服务：
sudo rabbitmqctl stop
```

启动成功后显示

```bash
  ##  ##      RabbitMQ 3.8.5
  ##  ##
  ##########  Copyright (c) 2007-2020 VMware, Inc. or its affiliates.
  ######  ##
  ##########  Licensed under the MPL 1.1. Website: https://rabbitmq.com

  Doc guides: https://rabbitmq.com/documentation.html
  Support:    https://rabbitmq.com/contact.html
  Tutorials:  https://rabbitmq.com/getstarted.html
  Monitoring: https://rabbitmq.com/monitoring.html

  Logs: /var/log/rabbitmq/rabbit@william-pc.log
        /var/log/rabbitmq/rabbit@william-pc_upgrade.log

  Config file(s): (none)

  Starting broker... completed with 0 plugins.
```

## 插件管理

&gt; 需要先启动插件，然后在启动 rabbitmq 服务

```bash
sudo rabbitmq-plugins enable rabbitmq_management
```

启动成功后

```bash
Enabling plugins on node rabbit@william-pc:
rabbitmq_management
The following plugins have been configured:
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_web_dispatch
Applying plugin configuration to rabbit@william-pc...
The following plugins have been enabled:
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_web_dispatch

started 3 plugins.
```

这样

1. 先启动插件管理

2. 然后启动服务

3. 产生以下结果

    ```bash
    ##  ##      RabbitMQ 3.8.5
    ##  ##
    ##########  Copyright (c) 2007-2020 VMware, Inc. or its affiliates.
    ######  ##
    ##########  Licensed under the MPL 1.1. Website: https://rabbitmq.com

    Doc guides: https://rabbitmq.com/documentation.html
    Support:    https://rabbitmq.com/contact.html
    Tutorials:  https://rabbitmq.com/getstarted.html
    Monitoring: https://rabbitmq.com/monitoring.html

    Logs: /var/log/rabbitmq/rabbit@william-pc.log
       /var/log/rabbitmq/rabbit@william-pc_upgrade.log

    Config file(s): (none)

    Starting broker... completed with 3 plugins.
    ```

4. 说明使用了 3 个插件：

    ```bash
    Starting broker... completed with 3 plugins.
    ```



## Web 访问

Web 管理程序的端口号是 15672，在浏览器中输入 [http://localhost:15672](https://link.zhihu.com/?target=http%3A//localhost%3A15672/)，即可以访问。

## 用户管理

登录以上 Web 管理界面后，需要我们输入账户和密码。

1. 增加用户

    ```bash
    ## 增加用户，并配置密码
    sudo rabbitmqctl add_user william &lt;Password&gt;
    ```



2. 删除用户

    ```bash
    sudo rabbitmqctl delete_user william
    ```

3. 修改用户密码

    ```bash
    sudo rabbitmqctl change_password william &lt;Password&gt;
    ```



4. 列出用户

    ```bash
    sudo rabbitmqctl list_users
    ```



5. 设置用户权限

    用户的角色可以分为5种:

    - 超级管理员 (administrator)：可登陆管理控制台 (启用 management plugin 的情况下)，可查看所有的信息，并且可以对用户，策略(policy) 进行操作。
    - 监控者 (monitoring)：可登陆管理控制台 (启用 management plugin 的情况下)，同时可以查看 rabbitmq 节点的相关信息 (进程数，内存使用情况，磁盘使用情况等)
    - 策略制定者 (policymaker)：可登陆管理控制台 (启用 management plugin 的情况下), 同时可以对 policy 进行管理。但无法查看节点的相关信息 (上图红框标识的部分)。
    - 普通管理者 (management)：仅可登陆管理控制台 (启用 management plugin 的情况下)，无法看到节点信息，也无法对策略进行管理。
    - 其他

    设置用户角色的命令为：

    ```bash
    ## 设置用户角色
    sudo rabbitmqctl set_user_tags william administrator

    ## 也可以给同一用户设置多个角色，例如

    sudo rabbitmqctl set_user_tags william administrator monitoring policymaker
    ```

# 应用

## 连接过程

消息队列的使用过程大概如下：

1. 客户端连接到消息队列服务器(broker)，打开一个 channel。

2. 客户端声明一个 exchange，并设置相关属性。

3. 客户端声明一个 queue，并设置相关属性。

4. 客户端使用 routing key，在 exchange 和 queue 之间建立好绑定关系。

5. 客户端投递消息到 exchange。



## Python

Python 环境下可以使用 `pika` 软件包

```bash
python -m pip install pika
```


### `server.py`

```python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(host=&#39;localhost&#39;))
channel = connection.channel()


try:
    channel.exchange_declare(exchange=&#39;logs&#39;,
                             exchange_type=&#39;fanout&#39;,
                             durable=True)
except:
    channel = connection.channel()
    channel.exchange_delete( exchange=&#39;logs&#39; )
    channel.exchange_declare(exchange=&#39;logs&#39;,
                             exchange_type=&#39;fanout&#39;,
                             durable=True)


from time import sleep
counter = 0

channel.basic_qos(prefetch_count=1)
while 1:
    counter &#43;= 1
    message = &#34;[{}] info: Hello World!&#34;.format(counter)
    channel.basic_publish(exchange=&#39;logs&#39;,
                          routing_key=&#39;&#39;,
                          body=message,
                          properties=pika.BasicProperties(delivery_mode = 2))
    print(&#34; [x] Sent %r&#34; % message)
    sleep(1)
connection.close()
```

### `client.py`

```python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(host=&#39;localhost&#39;))
channel = connection.channel()

channel.exchange_declare(exchange=&#39;logs&#39;,
                         exchange_type=&#39;fanout&#39;, durable=True)

result = channel.queue_declare(queue = &#34;&#34;, exclusive=True, durable=True)
queue_name = result.method.queue

channel.queue_bind(exchange=&#39;logs&#39;,
                   queue=queue_name)

print(&#39; [*] Waiting for logs. To exit press CTRL&#43;C&#39;)


def callback(ch, method, properties, body):
    print(&#34; [x] %r&#34; % body)

channel.basic_qos(prefetch_count=1)
channel.basic_consume(on_message_callback = callback,
                      queue = queue_name,
                      auto_ack = True)

channel.start_consuming()
```

## C&#43;&#43;

### AMQP-CPP

这个项目相对比较活跃，而且支持 C&#43;&#43;11 标准。

&gt; [AMQP-CPP](https://github.com/CopernicaMarketingSoftware/AMQP-CPP) is a C&#43;&#43; library for communicating with a RabbitMQ message broker. The library can be used to parse incoming data from a RabbitMQ server, and to generate frames that can be sent to a RabbitMQ server.
&gt;
&gt; AMQP-CPP is fully asynchronous and does not do any blocking (system) calls, so it can be used in high performance applications without the need for threads.

```bash
git clone git@github.com:CopernicaMarketingSoftware/AMQP-CPP.git

mkdir build
cd build
## cmake .. [-DAMQP-CPP_BUILD_SHARED] [-DAMQP-CPP_LINUX_TCP]
cmake .. -DAMQP-CPP_BUILD_SHARED=ON -DAMQP-CPP_LINUX_TCP=ON
sudo cmake --build . --target install
```

### Demo

```bash
git clone git@github.com:hoxnox/examples.amqp-cpp.git
cd examples.amqp-cpp
mkdir build
cd build
cmake ..
make -j

./receive

./send
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-07-09-rabbitmq--%E5%AE%89%E8%A3%85%E4%B8%8E%E4%BD%BF%E7%94%A8/  

