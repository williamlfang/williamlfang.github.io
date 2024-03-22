# Linux: 新购硬盘扩容


最近公司给原来的服务器添加了一块 `8T` 的 `Dell`SAS  硬盘，原来存放数据。由于`Linux`采用了逻辑硬盘`LLVM`的方式来组织多块硬盘，我们需要通过以下步骤，实现把新购硬盘添加到系统的逻辑硬盘，并通过磁盘扩容，增加目录 `/data` 的存储空间。


&lt;!--more--&gt;

# 扩展 8T 硬盘

```bash
## 查看当前可用磁盘
fdisk -l

## 查看磁盘分区情况
lsblk

## 加入对于新硬盘 /dev/sdb 进行操作
sudo parted /dev/sdb

## 查看
(parted) print

# rm 用于删除
# (parted) rm 1

(parted) mklabel gpt

## 创建分区
## 只有一卷
(parted) mkpart primary xfs 1 -1

## 以 s 为单位
(parted) unit s

## 扩展 100%
(parted) mkpart primary ext4 2048s 100%
(parted) mkpart primary ext4 0% 100%

(parted) align-check optimal 1
## 退出
quit
````

接着，我们可以分区

```bash
## 开始分区
sudo mkfs.ext4 /dev/sdb1

pvcreate /dev/sdb1
pvdisplay
```

# 新磁盘添加到逻辑盘

&gt; 主要参考了网站的教程：[手把手教你给 CentOS 7 添加硬盘及扩容(LVM)](https://aurthurxlc.github.io/Aurthur-2017/Centos-7-extend-lvm-volume.html)

## 添加物理分区

```bash
## 使用 fdisk 查看新添加的硬盘信息：/dev/sdc: 8T
fdisk -l

## 对新盘进行分区处理
fdisk /dev/sdc

## 主要使用命令
1. n: 添加新的物理分区
2. p: 选择主分区类型(1-4, 如果已经使用了 1（对应 /dev/sdc1），就选择 2，以此类推)
3. 起始扇区: 默认
4. Last扇区: 默认
5. t: 修改分区, 选择 1-4， 对应 /dev/sdc1-4
6. L: 列出所有的分区ID, 8e 为 Linux LVM
7. 8e:
8. w: 将修改写入磁盘

## 使用 partprobe 命令重新读取分区表
partprobe

## 查看修改后的结果
fdisk -l
```

## 添加逻辑分区

```bash
# 创建新物理卷前查看 PV
pvdisplay

# 创建 PV, 对应 /dev/sdc1, /dev/sdc2,...
pvcreate /dev/sdc1

# 再次查看，可看到新的 PV
pvdisplay

# 查看卷组
vgdisplay
  --- Volume group ---
  VG Name               VolGroup    ## 对应的 vg 名称
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  20
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                10
  Open LV               9
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               7.27 TiB
  PE Size               4.00 MiB
  Total PE              1907074
  Alloc PE / Size       1906176 / 7.27 TiB
  Free  PE / Size       898 / 3.51 GiB
  VG UUID               WZIDPF-5X39-1qac-L9oP-jCQm-C9im-pQBfs4


# 将新的 PV 加入 VolGroup 组卷，使用 vgdisplay 获取得到的 `VG Name`
vgextend VolGroup /dev/sdc1

vgdisplay

## 查看当前逻辑磁盘的空间大小
lvdisplay
## 查看系统可用空间大小
vgdisplay
```

# 磁盘扩容

```bash
## 查看文件路径对应的逻辑分卷
df
Filesystem            Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-LogVol07
                      689G  149G  506G  23% /
tmpfs                  79G  842M   78G   2% /dev/shm
/dev/sda1             477M  184M  269M  41% /boot
/dev/mapper/VolGroup-LogVol08
                      5.1T  3.4T  1.5T  71% /data
/dev/mapper/VolGroup-LogVol06
                     1008G  610G  347G  64% /home
/dev/mapper/VolGroup-LogVol01
                       59G  335M   56G   1% /opt
/dev/mapper/VolGroup-LogVol02
                       59G   52M   56G   1% /private
/dev/mapper/VolGroup-LogVol03
                      118G  1.1G  111G   1% /tmp
/dev/mapper/VolGroup-LogVol04
                      355G   15G  322G   5% /usr
/dev/mapper/VolGroup-LogVol05
                      217G   87G  119G  43% /var


## 查看系统可用空间大小
vgdisplay

## 开始进行磁盘扩展，增加 500G 到 /dev/mapper/VolGroup-LogVol08（也就是 /data）
lvextend -L &#43;500G /dev/mapper/VolGroup-LogVol08

xfs_growfs /dev/mapper/VolGroup-LogVol08
## CentOS6 使用命令 resize2fs

df -h
```

# 参考链接

- [linux新增大于2T硬盘，分区并挂载](https://blog.csdn.net/u012150360/article/details/81333051)
- [Linux磁盘扩容后处理（parted）](https://support.huaweicloud.com/usermanual-dss/dss_01_2311.html)



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-06-16-linux--%E6%96%B0%E8%B4%AD%E7%A1%AC%E7%9B%98%E6%89%A9%E5%AE%B9/  

