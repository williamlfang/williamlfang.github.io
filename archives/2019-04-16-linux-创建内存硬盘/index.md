# Linux 创建内存硬盘


我们知道，在操作系统层面，性能与存储空间（价格）之间存在着负相关性，即越靠近 `CPU` 的硬件具有更加快速的 `I/O` 性能，但相对空间较小，价格也比较贵；而那些远离 `CPU` 的设备则可以以相对低廉的价格获得足够大的存储空间，但是性能相对较弱。这就是著名的 `操作系统层次图`：

&lt;!--more--&gt;


![操作系统层次图](/images/2019-04-16-Linux-创建内存硬盘/1_4_StorageDeviceHierarchy.jpg)


```bash
## 建立 ramdisk
sudo mkdir /tmp/ramdisk
sudo chmod 777 /tmp/ramdisk

free -h
# 创建的RAM DISK大小为10G，文件格式tmpfs，挂载目录/tmp/ramdisk
sudo mount -t tmpfs -o size=1024M tmpfs /tmp/ramdisk
df
# 测速
dd if=/dev/zero of=/tmp/ramdisk/test bs=1024k count=512 conv=fdatasync
# 删除 test
rm -rf /tmp/ramdisk/test

# 卸载
sudo umount -l /tmp/ramdisk
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-04-16-linux-%E5%88%9B%E5%BB%BA%E5%86%85%E5%AD%98%E7%A1%AC%E7%9B%98/  

