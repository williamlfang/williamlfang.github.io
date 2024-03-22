# Docker 搭建 openwrt



`openwrt` 可以实现旁路由功能。
&lt;!--more--&gt;

## 安装

```bash
ip addr
sudo ip link set eno1 promisc on

sudo docker network create -d macvlan --subnet=192.168.3.0/24 --gateway=192.168.3.1 -o parent=eno1 macnet
docker network inspect  macnet

docker pull registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64

sudo docker run -d --restart always --name openwrt  --network macnet --privileged registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 /sbin/init

sudo docker exec -it openwrt /bin/bash

vi /etc/config/network

config interface &#39;loopback&#39;
        option ifname &#39;lo&#39;
        option proto &#39;static&#39;
        option ipaddr &#39;127.0.0.1&#39;
        option netmask &#39;255.0.0.0&#39;

config globals &#39;globals&#39;
        option ula_prefix &#39;fd7d:334c:6108::/48&#39;
        option packet_steering &#39;1&#39;

config interface &#39;lan&#39;
        option type &#39;bridge&#39;
        option ifname &#39;eth0&#39;  ## 必须是这个
        option proto &#39;static&#39;
        option netmask &#39;255.255.255.0&#39;
        option ip6assign &#39;60&#39;
        option ipaddr &#39;192.168.3.101&#39;
        option gateway &#39;192.168.3.1&#39;
        option dns &#39;192.168.3.1&#39;
        option broadcast &#39;192.168.3.255&#39;

config interface &#39;vpn0&#39;
        option ifname &#39;tun0&#39;
        option proto &#39;none&#39;

sudo docker restart openwrt

密码：password
```





## 宿主机与 Docker(openwrt) 无法通信

&gt; 参考：[在docker中运行openwrt #4](https://github.com/lisaac/blog/issues/4)

```bash
sudo ip link add link eno1 hMACvLAN type macvlan mode bridge
sudo ip addr add 192.168.3.100/24 brd &#43; dev hMACvLAN ## 增加一个网卡
sudo ip link set hMACvLAN up

## 以下可能有错误 =======================
# #sudo ip route del default #删除默认路由
# sudo ip route add default via 192.168.3.105 dev hMACvLAN # 设置静态路由
# sudo echo &#34;nameserver 192.168.3.1&#34; &gt; /etc/resolv.conf # 设置静态 dns 服务器
# ping  192.168.3.105

# # 或者使用 nmcli
# nmcli connection add type macvlan dev eno1 mode bridge ifname hMACvLAN autoconnect yes save yes
```


docker import https://downloads.openwrt.org/releases/19.07.0/targets/x86/64/openwrt-19.07.0-x86-64-generic-rootfs.tar.gz openwrt:19.07.0
sudo docker run -d \
   --restart unless-stopped \
   --network macvLan \
   --privileged registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 \
   --name openwrt \
   /sbin/init

sudo docker run --restart always --name openwrt  --network macvLan --privileged registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 /sbin/init




无法访问国内网址：

0. dns 选择：pdnsd：208.67.222.222(Open DNS)
1. https://github.com/coolsnowwolf/lede/issues/5520
   关闭 &#34;系统&#34; -&gt; &#34;启动项&#34; -&gt; &#34;19&#34;(firewall 需要禁止)
2. &#34;网络&#34; -&gt; &#34;接口&#34; -&gt; &#34;防火墙&#34; -&gt; &#34;区域&#34;(需要全部选择接受)
3. 然后在&#34;自定义规则里面&#34;，填写 iptables -t nat -I POSTROUTING -j MASQUERADE
4. 在 &#34;服务&#34; -&gt; &#34;PassWall&#34; -&gt; &#34;模式&#34;
   TCP*默认模式： GFW 列表
   UDP*默认模式：GFW 列表
   路由器TCP：GFW（这个GFW模式就可以）
   路由器UDP：GFW（这个GFW模式就可以）

5.手机连接
    a. IP 手动：
        IP地址：192.168.3.29（自己手机的固定IP）
        子网掩码：255.255.255.0
        路由器：192.168.3.101（需要和openwrt路由器一样）
    b. 配置DNS，需要先删除掉原来的
        手动：192.168.3.101（需要和openwrt路由器一样）





# William-Ubuntu 安装

```bash
ip add

## 如果原来有网卡，需要删除掉
sudo ifconfig hMACvLAN down
sudo ip link delete hMACvLAN

sudo ip link set enp0s31f6 promisc on

## 如果有，需要删掉
docker network ls
docker network rm macnet

docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=enp0s31f6 macnet
docker network inspect macnet

docker run -d \
	--restart always \
	--name openwrt  \
	--network macnet \
	--privileged \
	registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 \
	/sbin/init

docker exec -it openwrt /bin/bash

vi /etc/config/network

config interface &#39;loopback&#39;
        option ifname &#39;lo&#39;
        option proto &#39;static&#39;
        option ipaddr &#39;127.0.0.1&#39;
        option netmask &#39;255.0.0.0&#39;

config globals &#39;globals&#39;
        option ula_prefix &#39;fd7d:334c:6108::/48&#39;
        option packet_steering &#39;1&#39;

config interface &#39;lan&#39;
        option type &#39;bridge&#39;
        option ifname &#39;eth0&#39;
        option proto &#39;static&#39;
        option netmask &#39;255.255.255.0&#39;
        option ip6assign &#39;60&#39;
        option ipaddr &#39;192.168.1.101&#39;  ## docker ip，可以打开监控界面
        option gateway &#39;192.168.1.1&#39;
        option dns &#39;192.168.1.1&#39;

config interface &#39;vpn0&#39;
        option ifname &#39;tun0&#39;
        option proto &#39;none&#39;

docker restart openwrt

## 管理界面密码
密码：password

sudo ip link add link enp0s31f6 hMACvLAN type macvlan mode bridge
sudo ip addr add 192.168.1.100/24 brd &#43; dev hMACvLAN ## 增加一个网卡
sudo ip link set hMACvLAN up
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-03-19-docker-%E6%90%AD%E5%BB%BA-openwrt/  

