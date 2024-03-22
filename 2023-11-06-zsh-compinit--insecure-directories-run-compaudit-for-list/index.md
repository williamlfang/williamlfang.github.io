# zsh compinit: insecure directories, run compaudit for list



zsh 出现错误提示

```bash
zsh compinit: insecure directories, run compaudit for list
````

先进入 zsh 环境(选择 n)，然后执行

```bash
compaudit  |xargs chmod g-w
```
&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-11-06-zsh-compinit--insecure-directories-run-compaudit-for-list/  

