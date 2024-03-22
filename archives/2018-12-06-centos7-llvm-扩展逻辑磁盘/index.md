# CentOS7 LLVM 扩展逻辑磁盘


`CentOS` 已经创建 `LLVM` 逻辑磁盘^[以后会重新写一篇文章讨论这个]。现在需要对 `/data` 下面的磁盘进行扩容。

首先，需要获取当前磁盘的物理路径：

```bash
[root@localhost ~]# df
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root  100G   12G   89G  12% /
devtmpfs                  32G     0   32G   0% /dev
tmpfs                     32G     0   32G   0% /dev/shm
tmpfs                     32G   35M   32G   1% /run
tmpfs                     32G     0   32G   0% /sys/fs/cgroup
/dev/sda2                 10G  317M  9.7G   4% /boot
/dev/sda1                5.0G   12M  5.0G   1% /boot/efi
/dev/mapper/centos-var    90G  1.8G   89G   2% /var
/dev/mapper/centos-data  5.5T  5.0T  565G  90% /data
/dev/mapper/centos-home  1.5T  758G  743G  51% /home
tmpfs                    6.3G   12K  6.3G   1% /run/user/42
tmpfs                    6.3G     0  6.3G   0% /run/user/1002
tmpfs                    6.3G     0  6.3G   0% /run/user/0
tmpfs                    6.3G     0  6.3G   0% /run/user/1005
```

查看当前逻辑磁盘的空间大小：

```bash
[root@localhost ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/centos/swap
  LV Name                swap
  VG Name                centos
  LV UUID                ZnzTJq-S1Wx-1ekF-6Fed-R7Je-3USD-P1vO07
  LV Write Access        read/write
  LV Creation host, time localhost, 2017-01-23 11:22:16 &#43;0800
  LV Status              available
  # open                 2
  LV Size                128.00 GiB
  Current LE             32768
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/centos/var
  LV Name                var
  VG Name                centos
  LV UUID                FnQrvF-vWs6-Szls-yQ0q-4yt3-MJ2r-ZB1Of9
  LV Write Access        read/write
  LV Creation host, time localhost, 2017-01-23 11:22:20 &#43;0800
  LV Status              available
  # open                 1
  LV Size                90.00 GiB
  Current LE             23040
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/centos/home
  LV Name                home
  VG Name                centos
  LV UUID                joPrpf-idEH-C8ow-A0ep-5cfS-sYsX-7qldlE
  LV Write Access        read/write
  LV Creation host, time localhost, 2017-01-23 11:22:41 &#43;0800
  LV Status              available
  # open                 1
  LV Size                1.46 TiB
  Current LE             384000
  Segments               4
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:3

  --- Logical volume ---
  LV Path                /dev/centos/root
  LV Name                root
  VG Name                centos
  LV UUID                N9gO4N-tBbz-TJUW-sSeJ-NKER-ix2d-O3r3Rt
  LV Write Access        read/write
  LV Creation host, time localhost, 2017-01-23 11:23:08 &#43;0800
  LV Status              available
  # open                 1
  LV Size                100.00 GiB
  Current LE             25600
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/centos/data
  LV Name                data
  VG Name                centos
  LV UUID                5TEGzT-w8qs-h66v-r1ob-5Ld1-wbrq-ONWmja
  LV Write Access        read/write
  LV Creation host, time localhost, 2017-01-23 11:23:45 &#43;0800
  LV Status              available
  # open                 1
  LV Size                &lt;5.47 TiB
  Current LE             1433600
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:4
```

查看系统可用空间大小：

```bash
[root@localhost ~]# vgdisplay
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  18
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                5
  Open LV               5
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               7.26 TiB
  PE Size               4.00 MiB
  Total PE              1903358
  Alloc PE / Size       1899008 / 7.24 TiB
  Free  PE / Size       4350 / 16.99 GiB
  VG UUID               e7VekS-Jrrx-CMvZ-dqoC-jI6z-2Gs9-gIkstg以三
```

以上这个信息是已经分配过的磁盘空间，当前仅剩余 `4350 / 16.99 GiB`。

开始进行磁盘扩展，增加 `500G` 到 `/dev/mapper/centos-data`（也就是 `/data`）：

```bash
[root@localhost ~]# lvextend -L &#43;500G /dev/mapper/centos-data
  Size of logical volume centos/data changed from 4.98 TiB (1305600 extents) to &lt;5.47 TiB (1433600 extents).
  Logical volume centos/data successfully resized.
```

最后，需要调整文件系统大小：

```bash
[root@localhost ~]# xfs_growfs /dev/mapper/centos-data
## CentOS6 使用命令 resize2fs

meta-data=/dev/mapper/centos-data isize=256    agcount=7, agsize=196608000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=1336934400, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal               bsize=4096   blocks=384000, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 1336934400 to 1468006400
```

重新查看磁盘空间，已经显示增加了 `500G`，当前 `/data/` 大小为 `5.5TB`:

```bash
[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root  100G   12G   89G  12% /
devtmpfs                  32G     0   32G   0% /dev
tmpfs                     32G     0   32G   0% /dev/shm
tmpfs                     32G   35M   32G   1% /run
tmpfs                     32G     0   32G   0% /sys/fs/cgroup
/dev/sda2                 10G  317M  9.7G   4% /boot
/dev/sda1                5.0G   12M  5.0G   1% /boot/efi
/dev/mapper/centos-var    90G  1.8G   89G   2% /var
/dev/mapper/centos-data  5.5T  5.0T  565G  90% /data
/dev/mapper/centos-home  1.5T  758G  742G  51% /home
tmpfs                    6.3G   12K  6.3G   1% /run/user/42
tmpfs                    6.3G     0  6.3G   0% /run/user/1002
tmpfs                    6.3G     0  6.3G   0% /run/user/0
tmpfs                    6.3G     0  6.3G   0% /run/user/1005
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-12-06-centos7-llvm-%E6%89%A9%E5%B1%95%E9%80%BB%E8%BE%91%E7%A3%81%E7%9B%98/  

