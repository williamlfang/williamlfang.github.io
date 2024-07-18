# Time to say goodbye: CentOS7


# 《银翼杀手》Tears in the rain

# farewell

# Time to say goodbye

## CentOS7

![CentOS7](./centos7.png &#34;Time to say goodbye: CentOS7&#34;)

```bash
RUN sed -i &#39;s/mirrorlist/#mirrorlist/g&#39; /etc/yum.repos.d/CentOS-*
RUN sed -i &#39;s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g&#39; /etc/yum.repos.d/CentOS-*
```

或者使用国内阿里云源（使用命令查看系统版本 `cat /etc/redhat-release`）

```bash
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-7.6.1810 - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-7.6.1810 - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-7.6.1810 - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-7.6.1810 - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7

#contrib - packages by Centos Users
[contrib]
name=CentOS-7.6.1810 - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/7.6.1810/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-7
```

如果遇到

```
Could not resolve host: mirrors.aliyun.com; Unknown error
```

先试着修改 `DNS`

```bash
echo &#34;nameserver 8.8.8.8&#34; &gt;&gt; /etc/resolv.conf
```

部分 `rpm` 软件可以在这里找到：https://mirrors.aliyun.com/centos-vault/7.9.2009/extras/x86_64/Packages/

## Everything

# 漫长的准备，瞬间的告别

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-15-time-to-say-goodbye--centos7/  

