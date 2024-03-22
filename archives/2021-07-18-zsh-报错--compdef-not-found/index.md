# zsh 报错: compdef not found


主要在 `~/.zshrc` **最上面**添加

```bash
## 记得在最上面添加

autoload -Uz compinit
compinit
```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-07-18-zsh-%E6%8A%A5%E9%94%99--compdef-not-found/  

