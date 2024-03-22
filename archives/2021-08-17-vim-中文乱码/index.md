# vim 中文乱码


在 `~/.vimrc` 添加

```bash
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

另外，有可能出现 `^M` 这样的表示符号，其实是 `return` 的显示，替换掉

```bash
:%s/\r//g
```





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-08-17-vim-%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/  

