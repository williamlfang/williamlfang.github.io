# docker 占用磁盘空间太大


一觉醒来发现天塌了：我的 `Linux Mint` 机器无法登录。联想到昨天启动了一个 `Docker` 用于测试更新 `gcc14`，因而有可能是编译导致的临时目标文件太大，占用磁盘空间，导致系统启动无法正常读写相关启动的配置文件。

&lt;!--more--&gt;

## 进入磁盘

首先需要解决的问题是：如何在无法登陆操作系统的情况下，清理磁盘空间？

这个时候我想起原先安装

## docker 清理

```bash
docker system prune -a -f
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-04-docker-%E5%8D%A0%E7%94%A8%E7%A3%81%E7%9B%98%E7%A9%BA%E9%97%B4%E5%A4%AA%E5%A4%A7/  

