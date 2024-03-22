# terminal 右边显示时间


在 `~/.oh-my-zsh/themes/agnoster.themes` 增加

&lt;!--more--&gt;

```bash

strlen () {
    FOO=$1
    local zero=&#39;%([BSUbfksu]|([FB]|){*})&#39;
    LEN=${#${(S%%)FOO//$~zero/}}
    echo $LEN
}

# show right prompt with date ONLY when command is executed
preexec () {
    DATE=$( date &#43;&#34;[%H:%M:%S]&#34; )
    local len_right=$( strlen &#34;$DATE&#34; )
    len_right=$(( $len_right&#43;1 ))
    local right_start=$(($COLUMNS - $len_right))

    local len_cmd=$( strlen &#34;$@&#34; )
    local len_prompt=$(strlen &#34;$PROMPT&#34; )
    local len_left=$(($len_cmd&#43;$len_prompt))

    RDATE=&#34;\033[${right_start}C ${DATE}&#34;

    if [ $len_left -lt $right_start ]; then
        # command does not overwrite right prompt
        # ok to move up one line
        #echo -e &#34;\033[1A${RDATE}&#34;

        # Black=&#39;\033[30m&#39;        # Black
        # Red=&#39;\033[31m&#39;          # Red
        # Green=&#39;\033[32m&#39;        # Green
        # Yellow=&#39;\033[33m&#39;       # Yellow
        # Blue=&#39;\033[34m&#39;         # Blue
        # Purple=&#39;\033[35m&#39;       # Purple
        # Cyan=&#39;\033[36m&#39;         # Cyan
        # White=&#39;\033[37m&#39;        # White

        echo -e &#34;\033[1A\033[36m${RDATE}\033[36m&#34;

    else
        echo -e &#34;${RDATE}&#34;
    fi

}
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-05-13-terminal-%E5%8F%B3%E8%BE%B9%E6%98%BE%E7%A4%BA%E6%97%B6%E9%97%B4/  

