# nvim 报错: lua language server


今天升级 `lazy.nvim` 遇到一个错误：

```
Spawning language server with cmd: `lua-language-server` failed. The language server is either not installed, missing from PATH, or not executable.
```

&lt;!--more--&gt;

解决方法是重新安装

```vim
:MasonInstall --force --target=linux_x64_gnu lua-language-server
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-17-nvim-%E6%8A%A5%E9%94%99--lua-language-server/  

