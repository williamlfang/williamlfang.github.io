# vim fzf 打开文件


通过 `Ctrl-f` 查找并以 `vim` 打开目标文件

&lt;!--more--&gt;

```bash
## 在 ~/.zshrc

## fzf : Ctr-f -------------------------------------------------
# .zshrc example
function __fsel_files() {
  setopt localoptions pipefail no_aliases 2&gt; /dev/null
  eval find ./ -type f -print | fzf -m &#34;$@&#34; | while read item; do
    echo -n &#34;${(q)item} &#34;
  done
  local ret=$?
  echo
  return $ret
}

function fzf-vim {
    selected=$(__fsel_files)
    if [[ -z &#34;$selected&#34; ]]; then
        zle redisplay
        return 0
    fi
    zle push-line # Clear buffer
    BUFFER=&#34;vim $selected&#34;;
    zle accept-line
}
zle -N fzf-vim
bindkey &#34;^f&#34; fzf-vim
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-27-vim-fzf-%E6%89%93%E5%BC%80%E6%96%87%E4%BB%B6/  

