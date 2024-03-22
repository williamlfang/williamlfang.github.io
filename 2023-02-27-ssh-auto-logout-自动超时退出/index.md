# ssh auto logout 自动超时退出


观察到 ssh 会在一定时间的超时后，自动退出。

```bash
timed out waiting for input: auto-logout
```

&lt;!--more--&gt;

我已经把相关的 ssh 设置对核对过，是没有问题的。

参考这个博客：[**终端 timed out waiting for input: auto-logout 解决**](https://blog.csdn.net/wangshuminjava/article/details/80534032)

原来是有一个 `TIMEOUT` 的参数

```bash
echo $TIMEOUT

120
```

怪不得会自动退出。既然如此，则改之。

```bash
vim ~/.bashrc
vim /etc/profile

## 设置成 0 就是不要超时退出
export TIMEOUT=0
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-02-27-ssh-auto-logout-%E8%87%AA%E5%8A%A8%E8%B6%85%E6%97%B6%E9%80%80%E5%87%BA/  

