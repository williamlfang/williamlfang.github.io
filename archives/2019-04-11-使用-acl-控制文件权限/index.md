# 使用 acl 控制文件权限


ACL(Access Control List) 权限控制主要目的是提供传统的 owner、group、other 的 read、wirte、execute 权限之外的具体权限设置，可以针对单一用户或组来设置特定的权限。

我们可以通过命令来设置单个用户対文件（或文件夹）的读取权限。

&lt;!--more--&gt;

# 安装 acl

使用命令

```bash
## Ubuntu
sudo apt install acl

## CentOS
sudo yum install acl
```

# 主要功能

## getfacl: 查看权限

```bash
getfacl -h
getfacl 2.2.52 -- get file access control lists
Usage: getfacl [-aceEsRLPtpndvh] file ...
  -a,  --access           display the file access control list only
  -d, --default           display the default access control list only
  -c, --omit-header       do not display the comment header
  -e, --all-effective     print all effective rights
  -E, --no-effective      print no effective rights
  -s, --skip-base         skip files that only have the base entries
  -R, --recursive         recurse into subdirectories
  -L, --logical           logical walk, follow symbolic links
  -P, --physical          physical walk, do not follow symbolic links
  -t, --tabular           use tabular output format
  -n, --numeric           print numeric user/group identifiers
  -p, --absolute-names    don&#39;t strip leading &#39;/&#39; in pathnames
  -v, --version           print version and exit
  -h, --help              this help tex

cd ~/Documents
getfacl Documents
# file: Documents
# owner: william
# group: william
user::rwx
group::r-x
other::r-x
```

## setfacl: 设置权限

```bash
setfacl -h
setfacl 2.2.52 -- set file access control lists
Usage: setfacl [-bkndRLP] { -m|-M|-x|-X ... } file ...
  -m, --modify=acl        modify the current ACL(s) of file(s)
  -M, --modify-file=file  read ACL entries to modify from file
  -x, --remove=acl        remove entries from the ACL(s) of file(s)
  -X, --remove-file=file  read ACL entries to remove from file
  -b, --remove-all        remove all extended ACL entries
  -k, --remove-default    remove the default ACL
      --set=acl           set the ACL of file(s), replacing the current ACL
      --set-file=file     read ACL entries to set from file
      --mask              do recalculate the effective rights mask
  -n, --no-mask           don&#39;t recalculate the effective rights mask
  -d, --default           operations apply to the default ACL
  -R, --recursive         recurse into subdirectories
  -L, --logical           logical walk, follow symbolic links
  -P, --physical          physical walk, do not follow symbolic links
      --restore=file      restore ACLs (inverse of `getfacl -R&#39;)
      --test              test mode (ACLs are not modified)
  -v, --version           print version and exit
  -h, --help              this help text
```

对于某个特定的用户，我们想要分配文件读取权限，可以执行

```bash
setfacl -R -m u:trader:rwx /data/ChinaStocks
```

-   `-R`：対目录下所有文件递归执行修改
-   `-m`：执行修改权限的命令(modify)
-   `u:trader:rwx`：针对用户(`u:trader`)执行权限设置(`:rwx`)


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-04-11-%E4%BD%BF%E7%94%A8-acl-%E6%8E%A7%E5%88%B6%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90/  

