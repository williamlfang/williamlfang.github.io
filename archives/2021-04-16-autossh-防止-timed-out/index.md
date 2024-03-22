# autossh 防止 timed out


参考链接：[终端 timed out waiting for input: auto-logout解决！](https://blog.csdn.net/wangshuminjava/article/details/80534032)



```bash
## 先打印开一下有没有设置自动超时，
## 0或者空表示不会超时，其他表示超时多少秒会自动断线
echo $TMOUT

## 在 ~/.bash_profile 设置 0 表示不超时
## 或者在 /etc/profile
# ----------------------------
export TMOUT=0
# ----------------------------
```





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-04-16-autossh-%E9%98%B2%E6%AD%A2-timed-out/  

