# 阿里云磁盘扩容与扩展分区


# 在线扩容
去阿里云控制台下单采购：[在线扩容](https://help.aliyun.com/document_detail/113316.html)

采购完成后，大概经过 1 分钟左右，即可在对应的服务器看到增加的磁盘空间了

```bash
fdisk -l
```

但是，这时候直接使用 `df -h` 是无法看到实际的分区已经增加空间了。这是因为目前购买的这块硬盘，可以理解成&#34;裸硬盘&#34;，是需要经过设置才能增加到服务器的文件系统中。

# 扩展分区

阿里提供了详细的操作指南：[扩展分区和文件系统_Linux系统盘](https://help.aliyun.com/document_detail/111738.html?spm=a2c4g.11186623.2.30.7801216cEJrwpF#concept-ocb-htw-dhb)

```bash
## 安装工具
yum install cloud-utils-growpart
yum install xfsprogs

## 查看磁盘大小，包含扩容的空间
fdisk -l

Disk /dev/vda: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x0008d73a

   Device Boot      Start         End      Blocks   Id  System
   /dev/vda1   *        2048   104857566    52427759&#43;  83  Linux


## 查看文件系统，这时还没有增加，需要我们自己操作
df -h

Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        40G   33G  5.2G  87% /
devtmpfs        1.9G     0  1.9G   0% /dev
tmpfs           1.9G     0  1.9G   0% /dev/shm
tmpfs           1.9G  360K  1.9G   1% /run
tmpfs           1.9G     0  1.9G   0% /sys/fs/cgroup
tmpfs           380M     0  380M   0% /run/user/1000

## 从上面的 fdisk 看到磁盘在 /dev/vda
## 我们想要分配到 /dev/vda1
growpart /dev/vda 1

## 调用resize2fs扩容文件系统
resize2fs /dev/vda1

## 现在看已经成功扩展文件系统了
## 总体是 50G
df -h

Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        50G   32G   15G  69% /
devtmpfs        1.9G     0  1.9G   0% /dev
tmpfs           1.9G     0  1.9G   0% /dev/shm
tmpfs           1.9G  360K  1.9G   1% /run
tmpfs           1.9G     0  1.9G   0% /sys/fs/cgroup
tmpfs           380M     0  380M   0% /run/user/1000

```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-17-%E9%98%BF%E9%87%8C%E4%BA%91%E7%A3%81%E7%9B%98%E6%89%A9%E5%AE%B9%E4%B8%8E%E6%89%A9%E5%B1%95%E5%88%86%E5%8C%BA/  

