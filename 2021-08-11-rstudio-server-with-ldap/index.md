# Rstudio server with ldap


To install Rstudio in CentOS system, we need to run following commands:

```bash
wget https://download2.rstudio.org/server/centos7/x86_64/rstudio-server-rhel-1.4.1717-x86_64.rpm
yum install rstudio-server-rhel-1.4.1717-x86_64.rpm
sudo rstudio-server restart

sudo cp /etc/pam.d/login /etc/pam.d/rstudio
```
&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/2021-08-11-rstudio-server-with-ldap/  

