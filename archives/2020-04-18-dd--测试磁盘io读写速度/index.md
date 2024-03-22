# dd: 测试磁盘IO读写速度


```bash
## 测试写速度
time dd if=/dev/zero of=/tmp/test bs=8k count=1000000

## 测试读速度
time dd if=/tmp/test of=/dev/null bs=8k

## 测试读写速度
time dd if=/tmp/test of=/var/test bs=64k
```
&lt;!--more--&gt;

参数说明：

- time有计时作用，dd用于复制，从if读出，写到of；

- if=/dev/zero不产生IO，因此可以用来测试纯写速度；

- 同理of=/dev/null不产生IO，可以用来测试纯读速度；

- 将/tmp/test拷贝到/var则同时测试了读写速度；

- bs是每次读或写的大小，即一个块的大小，count是读写块的数量。



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-18-dd--%E6%B5%8B%E8%AF%95%E7%A3%81%E7%9B%98io%E8%AF%BB%E5%86%99%E9%80%9F%E5%BA%A6/  

