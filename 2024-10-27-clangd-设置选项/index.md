# clangd 设置选项


由于系统升级 `g&#43;&#43;`， 导致 `nvim clangd` 补全有些问题，需要指定 `clangd` 的配置

```bash
mkdir ~/.config/clangd

vim ~/.config/clangd/config.yaml
```

```yaml
CompileFlags:
  Add: [
        &#34;-Wall&#34;,
        &#34;-I/usr/include/c&#43;&#43;/11&#34;,
        &#34;-I/usr/include/x86_64-linux-gnu/c&#43;&#43;/11&#34;,
  ]
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-10-27-clangd-%E8%AE%BE%E7%BD%AE%E9%80%89%E9%A1%B9/  

