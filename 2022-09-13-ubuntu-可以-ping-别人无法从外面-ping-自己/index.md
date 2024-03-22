# ubuntu 可以 ping 别人,无法从外面 ping 自己


Ubuntu 可以 ping 别人，无法从外面 ping 自己。需要修改网络设置。

&lt;!--more--&gt;

```bash
cd /etc/netplan

vim 1-network-manager-all.yaml

# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s31f6:
     dhcp4: no
     addresses: [192.168.1.88/24]
     gateway4: 192.168.1.1
     nameservers:
       addresses: [114.114.114.114]

sudo netplan apply
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-ubuntu-%E5%8F%AF%E4%BB%A5-ping-%E5%88%AB%E4%BA%BA%E6%97%A0%E6%B3%95%E4%BB%8E%E5%A4%96%E9%9D%A2-ping-%E8%87%AA%E5%B7%B1/  

