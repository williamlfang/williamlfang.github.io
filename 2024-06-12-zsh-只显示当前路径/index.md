# zsh 只显示当前路径


```zsh
prompt_dir() {
    ##prompt_segment blue $CURRENT_FG &#39;%~&#39;
    prompt_segment blue $CURRENT_FG &#39;%c&#39;
}

prompt_context() {
    # if [[ &#34;$USER&#34; != &#34;$DEFAULT_USER&#34; || -n &#34;$SSH_CLIENT&#34; ]]; then
    # prompt_segment black default &#34;%(!.%{%F{yellow}%}.)$USER@%sh&#34;
    # prompt_segment black default &#34;%{$fg[blue]%}ops%{$fg[red]%}CMA%{$fg[yellow]%}@Colo104&#34;
    # prompt_segment black default &#34;%(!.%{%F{yellow}%}.)%{$fg[red]%}$USER#VKY%{$reset_color%}%{$fg[yellow]%}@Colo113&#34;
    prompt_segment black default &#34;dell&#34;
    # fi
}
```


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-12-zsh-%E5%8F%AA%E6%98%BE%E7%A4%BA%E5%BD%93%E5%89%8D%E8%B7%AF%E5%BE%84/  

