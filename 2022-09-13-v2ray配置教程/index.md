# v2ray配置教程


使用 v2ray 实现江湖失传已久的轻功。

&lt;!--more--&gt;

# 安装 v2ray 服务器

```bash
bash &lt;(curl -s -L https://git.io/v2ray.sh)
```

可以顺便给 `vps` 测速

```bash
## superspeed
bash &lt;(curl -Lso- https://git.io/superspeed)

————————————————————————SuperSpeed 全面测速版—————————————————————————
     使用方法:      bash &lt;(curl -Lso- https://git.io/superspeed)
     查看全部节点:  https://git.io/superspeedList
     节点更新日期:  2019/12/23       脚本更新日期:  2020/03/09
——————————————————————————————————————————————————————————————————————
     选择测速类型:
     1. 三网测速 (各取部分节点)                2. 取消本次测速
     3. 电信节点测速      4. 联通节点测速      5. 移动节点测速
     请输入数字选择: 1
——————————————————————————————————————————————————————————————————————
ID    测速服务器信息        上传速度        下载速度        延迟
3633  电信|上海　　　　　　 128.98 Mbit/s   384.05 Mbit/s   160.994 ms
24012 电信|内蒙古呼和浩特　　　　　　 66.38 Mbit/s    49.28 Mbit/s    198.881 ms
27377 电信|北京５Ｇ　　　　　　 116.61 Mbit/s   321.02 Mbit/s   161.536 ms
17145 电信|安徽安徽合肥　　　　　　 124.96 Mbit/s   373.35 Mbit/s   144.317 ms
27594 电信|广东广州５Ｇ　　　　　　 4.84 Mbit/s     23.16 Mbit/s    197.118 ms
27810 电信|广西南宁　　　　　　 60.62 Mbit/s    119.87 Mbit/s   172.267 ms
27575 电信|新疆乌鲁木齐　　　　　　 71.01 Mbit/s    147.04 Mbit/s   206.973 ms
26352 电信|江苏南京５Ｇ　　　　　　 141.18 Mbit/s   365.73 Mbit/s   138.398 ms
5396  电信|江苏苏州　　　　　　 141.03 Mbit/s   335.99 Mbit/s   138.572 ms
7509  电信|浙江杭州　　　　　　 112.69 Mbit/s   63.09 Mbit/s    210.463 ms
28225 电信|湖南长沙　　　　　　 98.16 Mbit/s    135.78 Mbit/s   188.638 ms
3973  电信|甘肃兰州　　　　　　 65.89 Mbit/s    30.87 Mbit/s    181.112 ms
19076 电信|重庆　　　　　　 55.81 Mbit/s    111.58 Mbit/s   252.101 ms
24447 联通|上海５Ｇ　　　　　　 117.29 Mbit/s   107.46 Mbit/s   187.886 ms
5103  联通|云南昆明　　　　　　 18.49 Mbit/s    7.01 Mbit/s     341.216 ms
5145  联通|北京　　　　　　 114.97 Mbit/s   278.81 Mbit/s   160.176 ms
9484  联通|吉林长春　　　　　　 111.22 Mbit/s   273.19 Mbit/s   174.654 ms
2461  联通|四川成都　　　　　　 78.93 Mbit/s    190.73 Mbit/s   201.194 ms
27154 联通|天津５Ｇ　　　　　　 129.92 Mbit/s   342.59 Mbit/s   155.246 ms
——————————————————————————————————————————————————————————————————————
     测试完成, 本次测速耗时: 7 分 52 秒
     当前时间: 2020-03-18 18:02:46
     # 三网测速中为避免节点数不均及测试过久，每部分未使用所有节点，
     # 如果需要使用全部节点，可分别选择三网节点检测。
# Superspeed.sh
wget https://raw.githubusercontent.com/oooldking/script/master/superspeed.sh
chmod &#43;x superspeed.sh
./superspeed.sh
## SuperBench.sh
## 一键检测VPS的CPU、内存、负载、IO读写、机房带宽等脚本
wget -qO- https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
#或者
curl -Lso- https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
## Zench
## Zench可以看作是Bench.sh 和 SuperBench的结合版本，加入 Ping 以及 路由测试 功能，会生成测评报告，可以很方便地分享给其他朋友看自己的测评数据
wget -N --no-check-certificate https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZBench-CN.sh &amp;&amp; bash ZBench-CN.sh
# 项目：https://github.com/FunctionClub/ZBench

--------------------------------------------------------------------------
CPU 型号             : QEMU Virtual CPU version (cpu64-rhel6)
CPU 核心数           : 2
CPU 频率             : 2699.998 MHz
总硬盘大小           : 20.4 GB (2.6 GB Used)
总内存大小           : 1007 MB (240 MB Used)
SWAP大小             : 259 MB (3 MB Used)
开机时长             : 0 days, 3 hour 42 min
系统负载             : 1.78, 0.57, 0.20
系统                 : CentOS 7.7.1908
架构                 : x86_64 (64 Bit)
内核                 : 4.10.4-1.el7.elrepo.x86_64
虚拟化平台           : kvm
--------------------------------------------------------------------------
硬盘I/O (第一次测试) : 389 MB/s
硬盘I/O (第二次测试) : 622 MB/s
硬盘I/O (第三次测试) : 568 MB/s
--------------------------------------------------------------------------
节点名称                  IP地址            下载速度            延迟
CacheFly                  205.234.175.175   112MB/s             0.433 ms
ping: speedtest.tokyo.linode.com: Name or service not known
Usage: ping [-aAbBdDfhLnOqrRUvV64] [-c count] [-i interval] [-I interface]
            [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
            [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]
            [-w deadline] [-W timeout] [hop1 ...] destination
Usage: ping -6 [-aAbBdDfhLnOqrRUvV] [-c count] [-i interval] [-I interface]
             [-l preload] [-m mark] [-M pmtudisc_option]
             [-N nodeinfo_option] [-p pattern] [-Q tclass] [-s packetsize]
             [-S sndbuf] [-t ttl] [-T timestamp_option] [-w deadline]
             [-W timeout] destination
Linode, Tokyo, JP                                                ms
Linode, Singapore, SG     139.162.23.4      12.1MB/s            180.628 ms
Linode, London, UK        176.58.107.39     17.6MB/s            135.277 ms
Linode, Frankfurt, DE     139.162.130.8     15.5MB/s            144.360 ms
Linode, Fremont, CA       50.116.14.9       58.2MB/s            10.185 ms
Softlayer, Dallas, TX     173.192.68.18     54.2MB/s            32.237 ms
Softlayer, Seattle, WA    67.228.112.250    62.5MB/s            26.613 ms
Softlayer, Frankfurt, DE  159.122.69.4      4.32MB/s            144.804 ms
Softlayer, Singapore, SG  119.81.28.170     10.6MB/s            183.570 ms
Softlayer, HongKong, CN   119.81.130.170    10.7MB/s            154.140 ms
--------------------------------------------------------------------------
节点名称                  上传速度          下载速度            延迟
上海电信                  144.60 Mbit/s     380.44 Mbit/s       157.919 ms
西安电信                  77.58 Mbit/s      172.21 Mbit/s       335.629 ms
北京联通                  120.90 Mbit/s     293.52 Mbit/s       158.144 ms
--------------------------------------------------------------------------
合肥        : 135.61 ms  北京        : 149.33 ms  武汉        : 162.61 ms
昌吉        : Fail       成都        : Fail       上海        : Fail
太原        : 0.56 ms    杭州        : 131.26 ms  宁夏        : 191.48 ms
呼和浩特    : 168.02 ms  南昌        : Fail       拉萨        : Fail
乌鲁木齐    : 206.72 ms  天津        : 163.47 ms  襄阳        : Fail
郑州        : 156.75 ms  沈阳        : Fail       兰州        : 192.39 ms
哈尔滨      : Fail       宁波        : Fail       苏州        : Fail
济南        : 138.37 ms  西安        : 179.44 ms  西宁        : Fail
重庆        : 234.12 ms  深圳        : Fail       南京        : Fail
长沙        : Fail       长春        : 161.75 ms  福州        : 154.07 ms
--------------------------------------------------------------------------
```

# 安装 v2ray 客户端

1. 下载客户端安装包，去 [官网](https://github.com/v2ray/v2ray-core/releases)下载相应的版本，即在 `Linux` 操作系统需要下载 `v2ray-linux-64.zip`
2. 把下载得到的安装包解压后，复制到 `/usr/local/v2ray`
3. 编辑配置文件 `config.json`
4. 创建配置文件目录 `/etc/v2ray`，并将以上的配置文件 `config.json` 拷贝到此目录
5. 开始启动

```bash
## 下载安装包
cd ~/Downloads
## https://github.com/v2ray/v2ray-core/releases
wget https://github.com/v2ray/v2ray-core/releases/download/v4.22.1/v2ray-linux-64.zip
unzip v2ray-linux-64.zip

## 拷贝安装包到 /usr/local
sudo cp -r v2ray-linux-64 /usr/local/v2ray

## 复制配置文件 ----------------------------------
mkdir -p /etc/v2ray
sudo cp ~/Documents/config.json /usr/local/v2ray
#sudo cp ~/Documents/config.json /etc/v2ray

## 启动客户端
cd /usr/local/v2ray
nohup sudo ./v2ray &amp;
#sudo ./v2ray --config=/etc/v2ray/config.json
```

# 配置命令行代理

```bash
## 1.安装 proxychains
cd ~/Downloads
git clone https://github.com/rofl0r/proxychains-ng
cd proxychains-ng
sudo ./configure --prefix=/usr --sysconfdir=/etc
sudo make -j
sudo make install
sudo make install-config ## (安装proxychains.conf配置文件)


## 2. 配置 proxychains
sudo vim /etc/proxychains.conf
## 在 在proxychains.conf文件末尾修改你的socks5服务地址,可以把sock4删除
## 注意：可以通过查看 /etc/v2ray/config.json 查看端口，这里假定端口号是 1086
[ProxyList]
# add proxy here ...
# meanwile
# defaults set to &#34;tor&#34;
#socks4         127.0.0.1 9050
socks5  127.0.0.1 1086

## 使用命令
proxychains4 程序 参数

curl www.twitter.com
proxychains4 curl www.twitter.com

[proxychains] config file found: /etc/proxychains.conf
[proxychains] preloading /usr/lib/libproxychains4.so
[proxychains] DLL init: proxychains-ng 4.14-git-8-gb8fa2a7
[proxychains] Strict chain  ...  127.0.0.1:1086  ...  www.twitter.com:80  ...  OK
```

# 配置桌面客户端

1. 在目录`/home/william/.local/share/applications` 下建立桌面客户端 ``v2ray.desktop`

2. 内容填写

   ```bash
   [Desktop Entry]
   Categories=Network;Internet;
   Comment=A platform for building proxies to bypass network restrictions.
   Exec=/usr/local/v2ray/v2ray
   GenericName=V2Ray Client
   Icon=/home/william/.local/share/applications/v2ray.png
   Name=V2Ray
   Terminal=false
   Type=Application
   X-Deepin-Vendor=user-custom
   Name[en_US]=v2ray.desktop
   ```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-v2ray%E9%85%8D%E7%BD%AE%E6%95%99%E7%A8%8B/  

