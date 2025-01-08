# crontab FAILED to authorize user with PAM


这几天发现有一个 `crontab` 没有启动，一开始以为是脚本有问题，所以添加了日志重定向。可是还是没有任何输出，所以怀疑是 `crontab` 没有执行，然后查看系统日志 `/var/log/cron` 发现有报错

```bash
crond[81985]: (infra) FAILED to authorize user with PAM (Module is unknown)
```

在网上搜索发现是 `PAM` 密钥过期了，需要重新设置

```bash
chage -M 99999 root
chage -M 99999 infra
chage -M 99999 spd
chage -M 99999 ops
```

重新查看就可以了

```bash
chage -l infra
Last password change                                    : Jul 12, 2024
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-08-crontab-failed-to-authorize-user-with-pam/  

