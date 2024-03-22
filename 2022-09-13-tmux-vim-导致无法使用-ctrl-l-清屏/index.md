# tmux vim 导致无法使用 ctrl l 清屏


[conflicts with clear screen #9](https://github.com/christoomey/vim-tmux-navigator/issues/9)

Since I misunderstood README and lost a bit of time figuring this out, I want to clarify what can be done to restore behavior.

1. If you use tpm, put restoring bind **after** calling package manager:

```
run &#39;~/.tmux/plugins/tpm/tpm&#39;
bind-key -n C-l if-shell &#34;$is_vim&#34; &#34;send-keys C-l&#34;  &#34;send-keys C-l&#34;
```

(if you don’t use tpm - just do not put “bind-key -n C-l” line in config)

1. Do this part of README in vimrc (also wo C-l line)

```
let g:tmux_navigator_no_mappings = 1

nnoremap &lt;silent&gt; &lt;C-h&gt; :TmuxNavigateLeft&lt;cr&gt;
nnoremap &lt;silent&gt; &lt;C-j&gt; :TmuxNavigateDown&lt;cr&gt;
nnoremap &lt;silent&gt; &lt;C-k&gt; :TmuxNavigateUp&lt;cr&gt;
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-tmux-vim-%E5%AF%BC%E8%87%B4%E6%97%A0%E6%B3%95%E4%BD%BF%E7%94%A8-ctrl-l-%E6%B8%85%E5%B1%8F/  

