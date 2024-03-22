# tmux 移动 window


移动 `tmux-window`

&lt;!--more--&gt;

```bash
## 使用 Shift-&gt; 或者 Shift&lt;- 移动
## tmux2
bind-key -n S-Left swap-window -t -1
bind-key -n S-Right swap-window -t &#43;1

## tmux3
bind-key -n S-Left swap-window -t -1\; select-window -t -1
bind-key -n S-Right swap-window -t &#43;1\; select-window -t &#43;1
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-24-tmux-%E7%A7%BB%E5%8A%A8-window/  

