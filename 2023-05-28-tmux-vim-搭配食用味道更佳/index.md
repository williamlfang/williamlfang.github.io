# tmux vim 搭配食用味道更佳


通过配置 `tmux` 与 `vim` 的组合键，可以使用一套统一的快捷键来操作二者。

- `ctrl-j`
- `ctrl-k`
- `ctrl-h`
- `ctrl-l`
- `prefix`: `ctrl-space`
- `&lt;prefix&gt; ctrl-l`

&lt;!--more--&gt;

## tmux 设置

```bash
## vim ~/.tmux.conf

## 安装 vim-tmux-navigator: &lt;prefix&gt;-I
set -g @plugin &#39;christoomey/vim-tmux-navigator&#39;

## 设置 &lt;prefix&gt;
#-- bindkeys --#
# prefix key (Ctrl&#43;Space)
set -g prefix ^Space
unbind ^b
bind Space send-prefix

## 设置快捷键
## vim-tmux ------------------------------------------------------------------
is_vim=&#34;ps -o state= -o comm= -t &#39;#{pane_tty}&#39; \
| grep -iqE &#39;^[^TXZ ]&#43; &#43;(\\S&#43;\\/)?g?(view|n?vim?x?)(diff)?$&#39;&#34;

is_fzf=&#34;ps -o state= -o comm= -t &#39;#{pane_tty}&#39; \
  | grep -iqE &#39;^[^TXZ ]&#43; &#43;(\\S&#43;\\/)?fzf$&#39;&#34;

bind -n C-h run &#34;($is_vim &amp;&amp; tmux send-keys C-h) || \
                          tmux select-pane -L&#34;
bind -n C-j run &#34;($is_vim &amp;&amp; tmux send-keys C-j)  || \
                         ($is_fzf &amp;&amp; tmux send-keys C-j) || \
                         tmux select-pane -D&#34;
bind -n C-k run &#34;($is_vim &amp;&amp; tmux send-keys C-k) || \
                          ($is_fzf &amp;&amp; tmux send-keys C-k)  || \
                          tmux select-pane -U&#34;
bind -n C-l run  &#34;($is_vim &amp;&amp; tmux send-keys C-l) || \
                          tmux select-pane -R&#34;
## clear terminal Ctr-x
bind-key -n C-x if-shell &#34;$is_vim&#34; &#34;send-keys C-l&#34;  &#34;send-keys C-l&#34;
## clear terminal &lt;prefix&gt; Ctrl-l
bind C-l send-keys &#39;C-l&#39;

bind-key -T copy-mode-vi &#39;C-h&#39; select-pane -L
bind-key -T copy-mode-vi &#39;C-j&#39; select-pane -D
bind-key -T copy-mode-vi &#39;C-k&#39; select-pane -U
bind-key -T copy-mode-vi &#39;C-l&#39; select-pane -R
bind-key -T copy-mode-vi &#39;C-\&#39; select-pane -l
```

## vim 设置

```vim
&#34; vim-tmux -------------------------------------------------------------------
Plug &#39;christoomey/vim-tmux-navigator&#39;
let g:tmux_navigator_no_mappings = 1

noremap &lt;silent&gt; &lt;c-h&gt; :&lt;C-U&gt;TmuxNavigateLeft&lt;cr&gt;
noremap &lt;silent&gt; &lt;c-j&gt; :&lt;C-U&gt;TmuxNavigateDown&lt;cr&gt;
noremap &lt;silent&gt; &lt;c-k&gt; :&lt;C-U&gt;TmuxNavigateUp&lt;cr&gt;
noremap &lt;silent&gt; &lt;c-l&gt; :&lt;C-U&gt;TmuxNavigateRight&lt;cr&gt;
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-28-tmux-vim-%E6%90%AD%E9%85%8D%E9%A3%9F%E7%94%A8%E5%91%B3%E9%81%93%E6%9B%B4%E4%BD%B3/  

