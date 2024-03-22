# fzf 配置指南




&lt;!--more--&gt;

## 配置

### 快捷键

- `ctr-n` 向下移动
- `ctr-p` 向上移动

#### tmux

#### zsh

- `ctr-t`
- `ctr-r`
- `alt-c`

#### vim

- `vim ** &lt;tab&gt;`: 进入模糊匹配
- `;ff`

```vim
&#34;fzf
&#34; This is the default option:
&#34;   - Preview window on the right with 50% width
&#34;   - CTRL-/ will toggle preview window.
&#34; - Note that this array is passed as arguments to fzf#vim#with_preview function.
&#34; - To learn more about preview window options, see `--preview-window` section of `man fzf`.
let g:fzf_preview_window = [&#39;right:50%&#39;, &#39;ctrl-/&#39;]
&#34; Preview window on the upper side of the window with 40% height,
&#34; hidden by default, ctrl-/ to toggle
let g:fzf_preview_window = [&#39;up:40%:hidden&#39;, &#39;ctrl-/&#39;]
&#34; Empty value to disable preview window altogether
let g:fzf_preview_window = []
&#34; [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
&#34; [[B]Commits] Customize the options used by &#39;git log&#39;:
let g:fzf_commits_log_options = &#39;--graph --color=always --format=&#34;%C(auto)%h%d %s %C(black)%C(bold)%cr&#34;&#39;
&#34; [Tags] Command to generate tags file
let g:fzf_tags_command = &#39;ctags -R&#39;
&#34; [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = &#39;alt-enter,ctrl-x&#39;
&#34; Mapping selecting mappings
nmap &lt;leader&gt;&lt;tab&gt; &lt;plug&gt;(fzf-maps-n)
xmap &lt;leader&gt;&lt;tab&gt; &lt;plug&gt;(fzf-maps-x)
omap &lt;leader&gt;&lt;tab&gt; &lt;plug&gt;(fzf-maps-o)
nmap &lt;C-p&gt; :Files&lt;CR&gt;
nmap &lt;C-e&gt; :Buffers&lt;CR&gt;
nmap &lt;leader&gt;ff :Files&lt;CR&gt;
let g:fzf_action = { &#39;ctrl-e&#39;: &#39;edit&#39;  }

&#34; Insert mode completion
imap &lt;c-x&gt;&lt;c-k&gt; &lt;plug&gt;(fzf-complete-word)
imap &lt;c-x&gt;&lt;c-f&gt; &lt;plug&gt;(fzf-complete-path)
imap &lt;c-x&gt;&lt;c-l&gt; &lt;plug&gt;(fzf-complete-line)
&#34; call fzf
```


### 预览窗口

```bash
## install highlight
sudo apt-get install highlight

antigen bundle unixorn/fzf-zsh-plugin@main
export FZF_DEFAULT_COMMAND=&#34;--exclude={.git,.idea,.vscode,.sass-cache,node_modules,build}&#34;
export FZF_DEFAULT_OPTS=&#34;--height 40% --layout=reverse --preview &#39;(highlight -O ansi {} || cat {}) 2&gt; /dev/null | head -500&#39;&#34;
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-16-fzf-%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97/  

