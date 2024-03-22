# nethogs


`nethogs` 可以针对 `Linux` 操作系统下单独的进程监控网络带宽，可以十分方便地排查当前占用流量过多的进程。

&lt;!--more--&gt;

```bash
wget https://github.com/raboof/nethogs/archive/refs/tags/v0.8.7.tar.gz
tar -xvf v0.8.7.tar.gz
cd nethogs-0.8.7
## 修改安装路径 Makefile
make
make install

#export TERM=linux
ln -sfn /usr/local/sbin/nethogs /usr/bin/nethogs

## 非 root 也能使用
## running nethogs without root
## https://github.com/raboof/nethogs/issues/86
setcap &#34;cap_net_admin,cap_net_raw=ep&#34; /usr/sbin/nethogs

## https://github.com/raboof/nethogs/issues/142
setcap cap_net_admin,cap_net_raw,cap_dac_read_search,cap_sys_ptrace&#43;ep /usr/local/sbin/nethogs
export TERM=linux
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-11-17-nethogs/  

