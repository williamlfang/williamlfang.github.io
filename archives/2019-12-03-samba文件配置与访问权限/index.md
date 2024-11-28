# samba文件配置与访问权限


注意，`samba` 在不同的操作系统下的服务名称是不一样的：

- `Ubuntu`: `smbd`
- `CentOS`: `smb`

# 安装

## 安装软件

```bash
## Ubuntu
sudo apt update
sudo apt-get install samba

## CentOS
yum install samba
```

## 查看状态

### Ubuntu

```bash
apt show samba
Package: samba
Version: 2:4.7.6&#43;dfsg~ubuntu-0ubuntu2.14
Priority: optional
Section: net
Origin: Ubuntu
Maintainer: Ubuntu Developers &lt;ubuntu-devel-discuss@lists.ubuntu.com&gt;
Original-Maintainer: Debian Samba Maintainers &lt;pkg-samba-maint@lists.alioth.debian.org&gt;
Bugs: https://bugs.launchpad.net/ubuntu/&#43;filebug
Installed-Size: 11.3 MB
Pre-Depends: dpkg (&gt;= 1.15.6~)
Depends: adduser, libpam-modules, libpam-runtime (&gt;= 1.0.1-11), lsb-base (&gt;= 4.1&#43;Debian), procps, python (&lt;&lt; 2.8), python-dnspython, python-samba, samba-common (= 2:4.7.6&#43;dfsg~ubuntu-0ubuntu2.14), samba-common-bin (= 2:4.7.6&#43;dfsg~ubuntu-0ubuntu2.14), tdb-tools, python (&gt;= 2.7~), python2.7:any, python:any (&lt;&lt; 2.8), python:any (&gt;= 2.7~), libattr1 (&gt;= 1:2.4.46-8), libbsd0 (&gt;= 0.0), libc6 (&gt;= 2.14), libldb1 (&gt;= 0.9.21), libpopt0 (&gt;= 1.14), libpython2.7 (&gt;= 2.7), libtalloc2 (&gt;= 2.0.4~git20101213), libtdb1 (&gt;= 1.2.7&#43;git20101214), libtevent0 (&gt;= 0.9.16), samba-libs (= 2:4.7.6&#43;dfsg~ubuntu-0ubuntu2.14)
Recommends: attr, logrotate, samba-dsdb-modules, samba-vfs-modules
Suggests: bind9 (&gt;= 1:9.5.1), bind9utils, ctdb, ldb-tools, ntp | chrony (&gt;= 3.0-1), smbldap-tools, ufw, winbind
Enhances: bind9, ntp
Homepage: http://www.samba.org
Task: samba-server, ubuntu-budgie-desktop
Supported: 5y
Download-Size: 854 kB
APT-Manual-Installed: yes
APT-Sources: http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 Packages
Description: SMB/CIFS file, print, and login server for Unix
 Samba is an implementation of the SMB/CIFS protocol for Unix systems,
 providing support for cross-platform file and printer sharing with
 Microsoft Windows, OS X, and other Unix systems.  Samba can also function
 as an NT4-style domain controller, and can integrate with both NT4 domains
 and Active Directory realms as a member server.
 .
 This package provides the components necessary to use Samba as a stand-alone
 file and print server or as an NT4 or Active Directory domain controller.
 For use in an NT4 domain or Active Directory realm, you will also need the
 winbind package.
 .
 This package is not required for connecting to existing SMB/CIFS servers
 (see smbclient) or for mounting remote filesystems (see cifs-utils).

N: There is 1 additional record. Please use the &#39;-a&#39; switch to see it
```

### Centos

```bash
rpm -qa |grep samba
samba-client-libs-4.8.3-4.el7.x86_64
samba-4.8.3-4.el7.x86_64
samba-common-libs-4.8.3-4.el7.x86_64
samba-common-tools-4.8.3-4.el7.x86_64
samba-common-4.8.3-4.el7.noarch
samba-libs-4.8.3-4.el7.x86_64
```

## 启动服务

### Ubuntu

```bash
sudo systemctl start smbd
sudo systemctl status smbd

## 允许防火墙通过
sudo ufw allow &#39;Samba&#39;
```

### CentOS

```bash
## start/ stop/ restart
systemctl start smb
```


## 查看服务进程

### Ubuntu

```bash
sudo systemctl status smbd
● smbd.service - Samba SMB Daemon
   Loaded: loaded (/lib/systemd/system/smbd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2019-12-14 15:19:43 CST; 6min ago
     Docs: man:smbd(8)
           man:samba(7)
           man:smb.conf(5)
 Main PID: 4232 (smbd)
   Status: &#34;smbd: ready to serve connections...&#34;
    Tasks: 4 (limit: 4915)
   CGroup: /system.slice/smbd.service
           ├─4232 /usr/sbin/smbd --foreground --no-process-group
           ├─4236 /usr/sbin/smbd --foreground --no-process-group
           ├─4237 /usr/sbin/smbd --foreground --no-process-group
           └─4238 /usr/sbin/smbd --foreground --no-process-group

Dec 14 15:19:43 william-pc systemd[1]: Starting Samba SMB Daemon...
Dec 14 15:19:43 william-pc systemd[1]: Started Samba SMB Daemon.
```


### CentOS

```bash
service smb status
Redirecting to /bin/systemctl status smb.service
● smb.service - Samba SMB Daemon
   Loaded: loaded (/usr/lib/systemd/system/smb.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2019-12-03 10:34:47 CST; 17min ago
     Docs: man:smbd(8)
           man:samba(7)
           man:smb.conf(5)
 Main PID: 36896 (smbd)
   Status: &#34;smbd: ready to serve connections...&#34;
    Tasks: 5
   CGroup: /system.slice/smb.service
           ├─36896 /usr/sbin/smbd --foreground --no-process-group
           ├─36901 /usr/sbin/smbd --foreground --no-process-group
           ├─36902 /usr/sbin/smbd --foreground --no-process-group
           ├─36903 /usr/sbin/smbd --foreground --no-process-group
           └─37042 /usr/sbin/smbd --foreground --no-process-group

Dec 03 10:34:47 hicloud systemd[1]: Starting Samba SMB Daemon...
Dec 03 10:34:47 hicloud smbd[36896]: [2019/12/03 10:34:47.207282,  0] ../lib/util/become_daemon.c:1...ady)
Dec 03 10:34:47 hicloud smbd[36896]:   daemon_ready: STATUS=daemon &#39;smbd&#39; finished starting up and ...ions
Dec 03 10:34:47 hicloud systemd[1]: Started Samba SMB Daemon.
Hint: Some lines were ellipsized, use -l to show in full.
```


## 设置开机启动

```bash
systemctl enable smb
```

## 临时关闭 SeLinux

需要关闭 `SeLinux` 才可以让 Windows 用户访问 `samba`

```bash
setenforce 0
```

查看 `SeLinux` 状态

```bash
sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
```

## 永久关闭 SeLinux

修改配置文件/etc/selinux/config，将SELINU置为disabled

```bash
cat /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
## SELINUX=enforcing
SELINUX=disabled
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

重启后可以查看`SeLinux`状态

```bash
sestatus
SELinux status:                 disabled
```

# 用户设置

## 添加用户

```bash
useradd fl
```

## 设置密码

```bash
smbpasswd -a fl
```

然后重启 `samba`

```bash
systemctl restart samba
```



# 设置访问

有关访问权限配置参数在

```bash
vim /etc/samba/smb.conf

# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run &#39;testparm&#39; to verify the config is correct after
# you modified it.

[global]
	workgroup = SAMBA
	security = user

	passdb backend = tdbsam

	printing = cups
	printcap name = cups
	load printers = yes
	cups options = raw

[homes]
	comment = Home Directories
	valid users = %S, %D%w%S
	browseable = No
	read only = No
	inherit acls = Yes

[printers]
	comment = All Printers
	path = /var/tmp
	printable = Yes
	create mask = 0600
	browseable = No

[fl]
	comment= fl files
	path = /home/fl/
	browseable = yes
	writable = yes
	available = yes
	valid users = fl,root

[pc]
    comment= pc files
    path = /home/pc/
    browseable = yes
    writable = yes
    available = yes
    valid users = pc,root

[shared]
    comment = share files
    path = /shared/
    browseable = yes
    writable = yes
    available = yes
    valid users = root,fl,pc
```

一般而言，我们对某个用户进行设置

```bash
[fl]
	comment= fl files
	path = /home/fl/
	browseable = yes
	writable = yes
	available = yes
	valid users = fl,root
```

# Windows 连接

[X] 1. `网络连接`
1. （window：程序-&gt;程序和功能-&gt;启动或者关闭Windows功能-&gt;Samba，打勾）直接在文件栏填写：`\\192.168.1.199\fl`
2. 填写 `\\192.168.1.199\fl` （对应于以上的用户，直接访问 `/home/fl`），注意 Windows 使用 `\\`
3. 然后使用账户、密码即可登录

# Windows 没有权限访问的解决方法

有可能是 `Centos` 打开了 `selinux`， 需要关闭即可

```bash
setenforce 0
```

## 目录自动更新

执行下列步骤： 
1. 在注册表中找到并单击以下注册表项： 
    HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Policies/Explorer（如果没有，直接新增即可）
2. 在“编辑”菜单上，指向“新建”，然后单击“DWORD 值”。 
3. 键入 NoSimpleNetIDList，然后按 Enter。 
4. 在“编辑”菜单上，单击“修改”。 
5. 键入 1，然后单击“确定”。


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-03-samba%E6%96%87%E4%BB%B6%E9%85%8D%E7%BD%AE%E4%B8%8E%E8%AE%BF%E9%97%AE%E6%9D%83%E9%99%90/  

