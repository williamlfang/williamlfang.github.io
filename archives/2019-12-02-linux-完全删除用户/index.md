# Linux 完全删除用户


```bash
userdel git
## 提示错误
## userdel: group git not removed because it is not the primary group of user git.
usermod -g git git
groupdel git
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-02-linux-%E5%AE%8C%E5%85%A8%E5%88%A0%E9%99%A4%E7%94%A8%E6%88%B7/  

