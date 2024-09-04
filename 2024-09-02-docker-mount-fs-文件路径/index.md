# docker mount fs 文件路径


`Docker`

&lt;!--more--&gt;

Requires the following steps:

uncomment user_allow_other in /etc/fuse.conf

unmount the FUSE filesystem

remount the FUSE filesystem with sshfs -o allow_other user@.... (making sure to include the -o allow_other option)

try starting the container again



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-09-02-docker-mount-fs-%E6%96%87%E4%BB%B6%E8%B7%AF%E5%BE%84/  

