# dd 制作 bios 启动盘


```bash
#!/bin/bash

mkfs.ext3 /dev/sda
sudo dd bs=4M if=/home/william/Desktop/CentOS-7-x86_64-Minimal-2009.iso of=/dev/sda &amp;&amp; sync
```


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-07-29-dd-%E5%88%B6%E4%BD%9C-bios-%E5%90%AF%E5%8A%A8%E7%9B%98/  

