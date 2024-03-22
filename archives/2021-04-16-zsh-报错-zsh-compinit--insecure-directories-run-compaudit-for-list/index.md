# zsh 报错:zsh compinit: insecure directories, run compaudit for list


解决方案

```bash
compaudit | xargs chmod g-w
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-04-16-zsh-%E6%8A%A5%E9%94%99-zsh-compinit--insecure-directories-run-compaudit-for-list/  

