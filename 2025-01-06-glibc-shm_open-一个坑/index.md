# glibc shm_open 一个坑




&lt;!--more--&gt;

# Tips

- glibc 2.17~2.28 是可以兼容的，在 `CentOS7` 上可以升级兼容，但是更高版本的 `glibc` 可能会导致系统不兼容，一定要谨慎操作

# ref

- gnu glibc.2.28: https://ftp.gnu.org/gnu/glibc/glibc-2.28.tar.gz
- glibc.2.20: https://elixir.bootlin.com/glibc/glibc-2.20.90/source/sysdeps/posix/shm_open.c
- glibc.2.21: https://elixir.bootlin.com/glibc/glibc-2.21.90/source/sysdeps/posix/shm_open.c
- [GLIBC_2.18 configure 不支持make 4.xx](https://zhuanlan.zhihu.com/p/397911151)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-06-glibc-shm_open-%E4%B8%80%E4%B8%AA%E5%9D%91/  

