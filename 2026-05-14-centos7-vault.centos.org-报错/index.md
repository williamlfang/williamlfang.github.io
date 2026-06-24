# CentOS7 vault.centos.org 报错


```bash
[root@localhost ~]# yum update
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
http://vault.centos.org/centos/7/os/x86_64/repodata/repomd.xml: [Errno 14] curl#6 - &#34;C
Trying other mirror.


 One of the configured repositories failed (CentOS-7 - Base),
 and yum doesn&#39;t have enough cached data to continue. At this point the only
 safe thing yum can do is fail. There are a few ways to work &#34;fix&#34; this:

     1. Contact the upstream for the repository and get them to fix the problem.

     2. Reconfigure the baseurl/etc. for the repository, to point to a working
        upstream. This is most often useful if you are using a newer
        distribution release than is supported by the repository (and the
        packages for the previous distribution release still work).

     3. Run the command with the repository temporarily disabled
            yum --disablerepo=base ...

     4. Disable the repository permanently, so yum won&#39;t use it by default. Yum
        will then just ignore the repository until you permanently enable it
        again or use --enablerepo for temporary usage:

            yum-config-manager --disable base
        or
            subscription-manager repos --disable=base

     5. Configure the failing repository to be skipped, if it is unavailable.
        Note that yum will try to contact the repo. when it runs most commands,
        so will have to try and fail each time (and thus. yum will be be much
        slower). If it is a very temporary problem though, this is often a nice
        compromise:

            yum-config-manager --save --setopt=base.skip_if_unavailable=true

failure: repodata/repomd.xml from base: [Errno 256] No more mirrors to try.
```


&lt;!--more--&gt;
你遇到的 Could not resolve host: vault.centos.org 错误，主要是因为 CentOS 7 在 2024 年 6 月 30 日正式结束了生命周期（EOL，End-of-Life）。官方仓库已不再提供服务，原有的镜像源地址（mirrorlist.centos.org）已不可用，导致 yum 无法找到软件包。

这个问题的核心原因有两个：

- [ ] 官方支持已终止：官方不再为 CentOS 7 提供安全更新和软件包。
- [ ] 仓库地址变更：所有旧版本软件包都被迁移到了存档仓库 vault.centos.org，但系统配置并未自动更新。

## 更换为国内镜像源

如果所在网络访问 vault.centos.org 速度很慢或失败，更换为国内的阿里云、清华等镜像源能很好地解决访问速度和连通性问题

```bash
# 以阿里云镜像源为例
# 1. 备份现有配置
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# 2. 下载阿里云 CentOS 7 的仓库配置文件
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# 3. 清理并重建缓存
yum clean all
yum makecache
```

## 排查网络与DNS问题

更换源后仍然失败，很可能是最基本的网络或 DNS 配置有问题。你可以按照下面的步骤快速排查：

- [ ] 检查互联网连接：ping -c 4 114.114.114.114。
- [ ] 测试 DNS 解析：nslookup vault.centos.org。
- [ ] 更新 DNS 设置：编辑 /etc/resolv.conf，添加 nameserver 114.114.114.114 和 nameserver 8.8.8.8。
- [ ] 检查时间日期：日期错误也会导致 SSL 连接问题。使用 date 检查，如果错误，可以用 sudo ntpdate pool.ntp.org 同步（需先安装 ntpdate）。

## 核心修复方案

```bash
# 1. 备份现有的仓库配置
cp -r /etc/yum.repos.d/ /etc/yum.repos.d.bak

# 2. 批量替换仓库URL：将失效的 mirrorlist 地址替换为 vault.centos.org 存档地址
sudo sed -i &#39;s/mirrorlist/#mirrorlist/g&#39; /etc/yum.repos.d/CentOS-*
sudo sed -i &#39;s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g&#39; /etc/yum.repos.d/CentOS-*

# 3. 清理并重建 yum 缓存
sudo yum clean all
sudo yum makecache

# 4. 验证仓库是否恢复
yum repolist
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-05-14-centos7-vault.centos.org-%E6%8A%A5%E9%94%99/  

