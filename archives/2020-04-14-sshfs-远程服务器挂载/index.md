# sshfs 远程服务器挂载


在服务器上面挂载另外一台服务器磁盘，像读取本地文件一样使用远程服务器磁盘。
&lt;!--more--&gt;


```bash
## https://unix.stackexchange.com/questions/37168/unable-to-use-o-allow-other-with-sshfs-option-enabled-in-fuse-conf

vim /etc/fuse.conf
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the &#39;allow_other&#39; or &#39;allow_root&#39;
# mount options.
#
user_allow_other
chmod a&#43;r /etc/fuse.conf

## ubuntu
sudo apt install sshfs
sudo apt install fuse

## CentOS
sudo yum install sshfs
sudo yum install fuse

##
cd /mnt
mkdir From135
chmod -R 777 /mnt/From135

##
sshfs trader@192.168.1.135:/ /mnt/From135 -o port=22,compression=yes,reconnect,idmap=user,allow_other -o ro

alias mount.135=&#39;sshfs trader@192.168.1.135:/data /mnt/From135 -o reconnect,idmap=user,allow_other -o ro&#39;
alias unmount.135=&#39;fusermount -u /mnt/From135 &amp;&amp; umount -l /mnt/From135&#39;
```







---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-14-sshfs-%E8%BF%9C%E7%A8%8B%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%8C%82%E8%BD%BD/  

