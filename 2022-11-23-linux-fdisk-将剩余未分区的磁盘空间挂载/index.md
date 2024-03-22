# Linux fdisk 将剩余未分区的磁盘空间挂载


对于在 `fdisk` 显示，但是没有添加到已经挂载目录的磁盘空间，我们需要进行对剩余磁盘空间的挂载操作。

&lt;!--more--&gt;

## fdisk -l 查看当前磁盘空间

 ```bash
fdisk -l
 ```

![](/home/william/git/blog/content/post/2022-11-23-Linux-fdisk-将剩余未分区的磁盘空间挂载/screenshot_52.png)

可以看到，这时候 `/dev/sda` 一共有 `200G` 空间，但实际占用的磁盘只有`19G`(19,921,920)。

## vgdisplay 显示当前可用逻辑卷空间

![](/home/william/git/blog/content/post/2022-11-23-Linux-fdisk-将剩余未分区的磁盘空间挂载/screenshot.png)

发现可以空间（`Free PE / Size`) 为空。

## lvdisplay 查看分卷的名称

```bash
 --- Logical volume ---
  LV Path                /dev/centos/root
  LV Name                root
  VG Name                centos
  LV UUID                RJXQ4v-eiWR-Mddv-afWi-JFcm-I2pk-dk78jm
  LV Write Access        read/write
  LV Creation host, time localhost, 2022-10-11 18:10:29 &#43;0800
  LV Status              available
  # open                 1
  LV Size                &lt;117.00 GiB
  Current LE             29951
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/centos/swap
  LV Name                swap
  VG Name                centos
  LV UUID                o6bndH-Tev1-1nLj-l3ZW-HKE5-UncQ-69aBLQ
  LV Write Access        read/write
  LV Creation host, time localhost, 2022-10-11 18:10:29 &#43;0800
  LV Status              available
  # open                 2
  LV Size                2.00 GiB
  Current LE             512
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
```

可以看到，根目录`/` 对应的路径是 `/dev/centos/root`，我们就是需要扩展这个分卷空间。

## fdisk 初始化未未挂磁盘

```bash
fdisk /dev/sda
```

![](/home/william/git/blog/content/post/2022-11-23-Linux-fdisk-将剩余未分区的磁盘空间挂载/fdisk.png)

初始化完成后，会看到多了一个 `/dev/sda3`.

## pvcreate 添加到逻辑卷

```bash
pvcreate /dev/sda3
```

![](/home/william/git/blog/content/post/2022-11-23-Linux-fdisk-将剩余未分区的磁盘空间挂载/pvcreate.png)

## vgextend

```bash
vgextend /dev/sda3
```

![](/home/william/git/blog/content/post/2022-11-23-Linux-fdisk-将剩余未分区的磁盘空间挂载/vgextend.png)

## lvextend

```lvextend
lvextend -L &#43;100G /dev/mapper/centos-root
```

![](/home/william/git/blog/content/post/2022-11-23-Linux-fdisk-将剩余未分区的磁盘空间挂载/lvextend.png)

## 新磁盘

```bash
pvcreate /dev/sda
pvdisplay

# 将新的 PV 加入 VolGroup 组卷，使用 vgdisplay 获取得到的 `VG Name`
vgextend centos /dev/sda

## 查看当前逻辑磁盘的空间大小
lvdisplay
## 查看系统可用空间大小
vgdisplay

## 增加一个 vg
lvs
lvcreate -L1024G -n data centos
lvs

mkfs.xfs /dev/mapper/centos-data
mkdir -p /data
mount /dev/mapper/centos-data /data

## 设置自动挂载
vim /etc/fstab
/dev/mapper/centos-data /data    xfs    defaults    0 0

## 逻辑卷扩容
## 查看系统可用空间大小
vgdisplay
## 开始进行磁盘扩展，增加 500G 到 /dev/mapper/centos-data（也就是 /data）
lvextend -L &#43;500G /dev/mapper/centos-data
xfs_growfs /dev/mapper/centos-data
## CentOS6 使用命令 resize2fs
df -h
```



## 如果不是逻辑卷 lvm，则直接挂载

```bash
## 查看
fdisk -l

## 新建分区
fdisk /dev/sda

n -&gt; 1 -&gt; 8e -&gt; w

## 格式化
mkfs.ext4 /dev/sda1

## 直接挂载到　/data
mkdir -p /data
mount /dev/sda1 /data

vi /etc/fstab
/dev/sda1       /data   ext4    defaults        0       0
```





#  Ref


[**Linux 将剩余未分区的磁盘空间挂载**](https://juejin.cn/post/6998762369346174990)


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-23-linux-fdisk-%E5%B0%86%E5%89%A9%E4%BD%99%E6%9C%AA%E5%88%86%E5%8C%BA%E7%9A%84%E7%A3%81%E7%9B%98%E7%A9%BA%E9%97%B4%E6%8C%82%E8%BD%BD/  

