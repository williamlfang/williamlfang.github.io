# Linux 新加4T硬盘挂载（非逻辑盘）


新加一块 4T 硬盘挂载（非逻辑盘，没有 vgdisplay 的概念，就是简单的挂载到某个路径）

&lt;!--more--&gt;

```bash
fdisk -l
lsblk

## 假设以 /dev/sdb 为例

## 如果此硬盘以前有过分区，则先对磁盘格式化：
mkfs -t ext4 /dev/sdb

## 对于新硬盘进行分区操作
## 由于 fdisk 只能处理 2T 以内的硬盘分区
## 对于超过 2T 的硬盘，需要使用 parted 进行 GPT 格式分区
parted /dev/sdb

## 进入操作命令
parted

(parted) print
## 如果有分区，先删掉，注意数据的备份处理
(parted) #rm 1

## 创建格式
(parted) mklabel gpt
## 只创建一个分区
(parted) mkpart primary xfs 1 -1
## 以 s 为单元
(parted) unit s
(parted) mkpart primary ext4 0% 100%
(parted) q

## 开始挂载的 /data 目录
sudo mkdir -p /data
mount /dev/sdb1 /data

## 添加到 /etc/fstab
vim /etc/fstab

/dev/sdb1   /data   ext4    defaults    0   0
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-07-31-linux-%E6%96%B0%E5%8A%A04t%E7%A1%AC%E7%9B%98%E6%8C%82%E8%BD%BD%E9%9D%9E%E9%80%BB%E8%BE%91%E7%9B%98/  

