# fzf 显示预览窗口


可以让 `fzf` 显示预览窗口功能，使用快捷键 `ctrl-f`

&lt;!--more--&gt;

```bash
export FZF_DEFAULT_OPTS=&#34;--height 40% --layout=reverse --preview &#39;(highlight -O ansi {} || cat {}) 2&gt; /dev/null | head -500&#39;&#34;

## fzf : Ctr-f -------------------------------------------------
# .zshrc example
function __fsel_files() {
  setopt localoptions pipefail no_aliases 2&gt; /dev/null
  eval find ./ -type f -print | fzf --reverse -m &#34;$@&#34; | while read item; do
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
    BUFFER=&#34;nvim $selected&#34;;
    zle accept-line
}
zle -N fzf-vim
bindkey &#34;^f&#34; fzf-vim
setopt no_nomatch ## 处理：zsh: no matches found
setopt GLOB_DOTS  ## copy .dotfile: https://unix.stackexchange.com/questions/89749/cp-hidden-files-with-glob-patterns
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-15-fzf-%E6%98%BE%E7%A4%BA%E9%A2%84%E8%A7%88%E7%AA%97%E5%8F%A3/  

