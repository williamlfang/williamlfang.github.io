# nvim tmux 颜色显示不对


在 `~/.tmux.conf` 添加

```bash
# set -ga terminal-overrides &#34;,xterm-256color:Tc&#34;
# set -g default-terminal &#34;tmux-256color&#34;

set -g default-terminal &#34;screen-256color&#34;
set-option -sa terminal-overrides &#39;,screen-256color:Tc&#39;
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-13-nvim-tmux-%E9%A2%9C%E8%89%B2%E6%98%BE%E7%A4%BA%E4%B8%8D%E5%AF%B9/  

