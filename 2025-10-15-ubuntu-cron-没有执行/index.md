# Ubuntu cron 没有执行



查看状态

```bash
sudo systemctl start cron
Failed to start cron.service: Unit cron.service is masked.
```

This error means that the cron service has been intentionally disabled (&#34;masked&#34;) on your system. When a service is masked, it cannot be started, even manually.
&lt;!--more--&gt;

需要重新启动

```bash
sudo systemctl unmask cron.service
sudo systemctl start cron.service
sudo systemctl enable cron.service
sudo systemctl status cron.service
```

把 `vim /etc/rsyslog.d/50-default.conf` 里面 `cron` 相关注释去掉。这样可以查看 `cron` 运行的日志文件 `/var/log/cron.log`

```bash
# 开启 cron 日志记录: /var/log/cron.log
vim /etc/rsyslog.d/50-default.conf

# 重启  rsyslog 服务
sudo service rsyslog restart
sudo service cron restart

ls -alh /var/spool/cron/crontabs/
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-10-15-ubuntu-cron-%E6%B2%A1%E6%9C%89%E6%89%A7%E8%A1%8C/  

