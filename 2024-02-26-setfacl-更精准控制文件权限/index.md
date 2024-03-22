# setfacl 更精准控制文件权限


```bash
setfacl -R -m o::---  /home/ops/shared/
setfacl -m u:spd:x /home/ops
setfacl -m u:spd:x /home/ops/shared
setfacl -m u:spd:x /home/ops/shared/trading
setfacl -R -m u:spd:rx /home/ops/shared/trading/{PublicInfo,lib,Snail,Spider}
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-02-26-setfacl-%E6%9B%B4%E7%B2%BE%E5%87%86%E6%8E%A7%E5%88%B6%E6%96%87%E4%BB%B6%E6%9D%83%E9%99%90/  

