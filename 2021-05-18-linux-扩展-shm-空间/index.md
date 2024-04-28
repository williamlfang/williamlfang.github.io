# Linux 扩展 shm 空间



扩大 Linux 系统的 `shm` 大小。

&lt;!--more--&gt;

```bash
## 查看 shm 大小
df -h /dev/shm

## 修改大小
## 记得一定要使用 tab 来分割
sudo vim /etc/fstab

## 使用 MB
tmpfs	/dev/shm	tmpfs	defaults,size=4096M	0	0

## 使用 GB
tmpfs	/dev/shm	tmpfs	defaults,size=4G	0	0

## 重新挂载，需要确保没有被占用
sudo umount -l /dev/shm
sudo mount /dev/shm
sudo mount -o remount /dev/shm

## 重新查看大小
df -h /dev/shm
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2021-05-18-linux-%E6%89%A9%E5%B1%95-shm-%E7%A9%BA%E9%97%B4/  

