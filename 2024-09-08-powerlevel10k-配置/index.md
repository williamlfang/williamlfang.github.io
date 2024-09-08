# powerlevel10k 配置


`powerlevel10k` 配置方案

```zsh
## 只显示相对路径，因为tmux可以显示全部路径
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last

## 在左边显示 hostname
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # os identifier
    context                 # user@hostname
)

## 显示日期
typeset -g POWERLEVEL9K_TIME_FORMAT=&#39;%D{%b%d %H:%M:%S}&#39;
```

&lt;!--more--&gt;

## ~/.p10k.zsh



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-09-08-powerlevel10k-%E9%85%8D%E7%BD%AE/  

