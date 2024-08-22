# zsh 添加显示命令执行时间


在 zsh 右边添加命令执行的时间

&lt;!--more--&gt;

## 添加 PROMPT

`vim ~/.zshrc`

```bash
prompt_context() {
  # if [[ &#34;$USER&#34; != &#34;$DEFAULT_USER&#34; || -n &#34;$SSH_CLIENT&#34; ]]; then
    # prompt_segment black default &#34;%(!.%{%F{yellow}%}.)$USER@%sh&#34;
    #prompt_segment black default &#34;%(!.%{%F{yellow}%}.)%{$fg[red]%}ops%{$reset_color%}%{$fg[yellow]%}@Colo103&#34;
    prompt_segment black default &#34;xps&#34;
    #prompt_segment black default &#34;%{$fg[blue]%}ops%{$fg[red]%}CMA%{$fg[yellow]%}@Colo104&#34;
    #prompt_segment black default &#34;%(!.%{%F{yellow}%}.)%{$fg[red]%}$USER#VKY%{$reset_color%}%{$fg[yellow]%}@Colo113&#34;
  # fi
}
# RPROMPT=&#39;%F{blue}[%D{%f/%m/%y} | %D{%H:%M:%S}]&#39;
# RPROMPT=&#39;%F{241}[%D{%f/%m/%y} | %D{%H:%M:%S}]&#39;
ZLE_RPROMPT_INDENT=0
# RPROMPT=&#39;%F{244}[%D{%b%d} %D{%H:%M:%S}]&#39;
RPROMPT=&#39;%F{244}%D{%b%d} %D{%H:%M:%S}&#39;
schedprompt() {
    ZLE_RPROMPT_INDENT=0
    emulate -L zsh
    zmodload -i zsh/sched

    # Remove existing event, so that multiple calls to
    # &#34;schedprompt&#34; work OK.  (You could put one in precmd to push
    # the timer 30 seconds into the future, for example.)
    integer i=${&#34;${(@)zsh_scheduled_events#*:*:}&#34;[(I)schedprompt]}
    (( i )) &amp;&amp; sched -$i

    # Test that zle is running before calling the widget (recommended
    # to avoid error messages).
    # Otherwise it updates on entry to zle, so there&#39;s no loss.
    zle &amp;&amp; zle reset-prompt

    # This ensures we&#39;re not too far off the start of the minute
    sched &#43;1 schedprompt
}
schedprompt

```

## 去掉 pree

`vim ~/.oh-my-zsh/themes/agnoster.zsh-theme`

```bash
# ## 显示命令执行时间
# strlen () {
#     FOO=$1
#     local zero=&#39;%([BSUbfksu]|([FB]|){*})&#39;
#     LEN=${#${(S%%)FOO//$~zero/}}
#     echo $LEN
# }
# # show right prompt with date ONLY when command is executed
# preexec () {
#     DATE=$( date &#43;&#34;[%b%d %H:%M:%S]&#34; )
#     local len_right=$( strlen &#34;$DATE&#34; )
#     len_right=$(( $len_right&#43;1 ))
#     local right_start=$(($COLUMNS - $len_right))
#
#     local len_cmd=$( strlen &#34;$@&#34; )
#     local len_prompt=$(strlen &#34;$PROMPT&#34; )
#     local len_left=$(($len_cmd&#43;$len_prompt))
#
#     RDATE=&#34;\033[${right_start}C ${DATE}&#34;
#
#       # command does not overwrite right prompt
#       # ok to move up one line
#       #echo -e &#34;\033[1A${RDATE}&#34;
#
#       # Black=&#39;\033[30m&#39;        # Black
#       # Red=&#39;\033[31m&#39;          # Red
#       # Green=&#39;\033[32m&#39;        # Green
#       # Yellow=&#39;\033[33m&#39;       # Yellow
#       # Blue=&#39;\033[34m&#39;         # Blue
#       # Purple=&#39;\033[35m&#39;       # Purple
#       # Cyan=&#39;\033[36m&#39;         # Cyan
#       # White=&#39;\033[37m&#39;        # White
#       # MYCOLOR=&#39;\033[237m&#39;
#
#       # \e[0; normal
#       # \e[1; bold
#       # \e[2; dim
#
#       COLOR_NC=&#39;\e[0m&#39; # No Color
#       # COLOR_BLACK=&#39;\e[0;30m&#39;
#       # COLOR_GRAY=&#39;\e[1;30m&#39;
#       # COLOR_RED=&#39;\e[0;31m&#39;
#       # COLOR_LIGHT_RED=&#39;\e[1;31m&#39;
#       # COLOR_GREEN=&#39;\e[0;32m&#39;
#       # COLOR_LIGHT_GREEN=&#39;\e[1;32m&#39;
#       # COLOR_BROWN=&#39;\e[0;33m&#39;
#       # COLOR_YELLOW=&#39;\e[1;33m&#39;
#       # COLOR_BLUE=&#39;\e[0;34m&#39;
#       # COLOR_LIGHT_BLUE=&#39;\e[1;34m&#39;
#       # COLOR_PURPLE=&#39;\e[0;35m&#39;
#       # COLOR_LIGHT_PURPLE=&#39;\e[1;35m&#39;
#       # COLOR_CYAN=&#39;\e[0;36m&#39;
#       # COLOR_LIGHT_CYAN=&#39;\e[1;36m&#39;
#       COLOR_LIGHT_GRAY=&#39;\e[0;37m&#39;
#       # COLOR_DARK_GRAY=&#39;\e[0;90m&#39;
#       # COLOR_DARK_GRAY=&#39;\e[0;90m&#39;
#       # COLOR_WHITE=&#39;\e[1;37m&#39;
#
#     if [ $len_left -lt $right_start ]; then
#         # echo -e &#34;\033[1A\033[36m${RDATE}\033[36m&#34;
#         # echo -e &#34;\033[1A\033[33m${RDATE}\033[0m&#34;
#         # echo -e &#34;${COLOR_LIGHT_PURPLE}${RDATE}${COLOR_NC}&#34;
#         # echo -e &#34;${COLOR_LIGHT_GRAY}${RDATE}${COLOR_NC}&#34;
#         # echo -e &#34;${COLOR_DARK_GRAY}${RDATE}${COLOR_NC}&#34;
#         echo -e &#34;${COLOR_LIGHT_GRAY}${RDATE}${COLOR_NC}&#34;
#
#     else
#         # echo -e &#34;${RDATE}&#34;
#         echo -e &#34;${COLOR_LIGHT_GRAY}${RDATE}${COLOR_NC}&#34;
#     fi
#
# }
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-08-04-zsh-%E6%B7%BB%E5%8A%A0%E6%98%BE%E7%A4%BA%E5%91%BD%E4%BB%A4%E6%89%A7%E8%A1%8C%E6%97%B6%E9%97%B4/  

