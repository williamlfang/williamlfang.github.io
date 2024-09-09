# powerlevel10k 配置


`powerlevel10k` 配置方案

```bash
p4 git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
```

```raw
## 只显示相对路径，因为tmux可以显示全部路径
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last

## 在左边显示 hostname
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon                 # os identifier
    context                 # user@hostname
)

## -----------------------------------------------------------------------------
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last
typeset -g POWERLEVEL9K_TIME_FORMAT=&#39;&#39;
# Don&#39;t show context unless running with privileges or in SSH.
# Tip: Remove the next line to always show context.
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
```

&lt;!--more--&gt;

## ~/.p10k.zsh


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-09-08-powerlevel10k-%E9%85%8D%E7%BD%AE/  

