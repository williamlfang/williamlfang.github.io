# influxDB 入坑指北


# 安装

```bash
cd ~/Downloads
## 官网下载 https://portal.influxdata.com/downloads/
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.7.9_amd64.deb

## 开始安装
sudo dpkg -i influxdb_1.7.9_amd64.deb

## 启动服务
/bin/systemctl start influxdb.service
```
&lt;!--more--&gt;

```bash
## 打开服务
influx

Connected to http://localhost:8086 version 1.7.9
InfluxDB shell version: 1.7.9
&gt;
&gt; help
Usage:
        connect &lt;host:port&gt;   connects to another node specified by host:port
        auth                  prompts for username and password
        pretty                toggles pretty print for the json format
        chunked               turns on chunked responses from server
        chunk size &lt;size&gt;     sets the size of the chunked responses.  Set to 0 to reset to the default chunked size
        use &lt;db_name&gt;         sets current database
        format &lt;format&gt;       specifies the format of the server responses: json, csv, or column
        precision &lt;format&gt;    specifies the format of the timestamp: rfc3339, h, m, s, ms, u or ns
        consistency &lt;level&gt;   sets write consistency level: any, one, quorum, or all
        history               displays command history
        settings              outputs the current settings for the shell
        clear                 clears settings such as database or retention policy.  run &#39;clear&#39; for help
        exit/quit/ctrl&#43;d      quits the influx shell

        show databases        show database names
        show series           show series information
        show measurements     show measurement information
        show tag keys         show tag key information
        show field keys       show field key information

        A full list of influxql commands can be found at:
        https://docs.influxdata.com/influxdb/latest/query_language/spec/

```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-02-influxdb-%E5%85%A5%E5%9D%91%E6%8C%87%E5%8C%97/  

