# Python3.11 避坑指南


在升级 `Python3.11` 过程中遇到一些问题，这里顺手记录一下。

&lt;!--more--&gt;

1. 需要安装 `bzip2-devel`

   ```bash
   yum install -y bzip2*
   ```

2. 找到 `_bz2`

   ```bash
   sudo find / -name &#39;*_bz2*&#39;

   /mnt/.local/share/Trash/files/anaconda3.9/lib/python3.9/lib-dynload/_bz2.cpython-39-x86_64-linux-gnu.so

   ## 找到对应的需要处理的 python 版本路径
   cd /usr/local/python3/lib/python3.11/lib-dynload
   ## 安装版本修改
   cp _bz2.cpython-39-x86_64-linux-gnu.so _bz2.cpython-311-x86_64-linux-gnu.so
   ```

3. 找到 `libbz2.so.1.0`

   ```bash
   sudo find / -name &#39;libbz2.so.1.0&#39;


   ```

4. python11 目前还不能支持 `numba`


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-11-24-python3.11-%E9%81%BF%E5%9D%91%E6%8C%87%E5%8D%97/  

