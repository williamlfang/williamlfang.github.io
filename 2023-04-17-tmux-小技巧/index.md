# tmux 小技巧



总结一下 tmux 的使用技巧与相关配置。

&lt;!--more--&gt;

## 配置

### tmux3 特别注意

注意，千万一定要把 `set -g @split-statusbar-mode &#39;off&#39;`

```bash
set -g @plugin &#39;charlietag/tmux-split-statusbar&#39;
run-shell /home/william/.tmux/plugins/tmux-split-statusbar/tmux-split-statusbar.tmux
set -g @plugin &#39;charlietag/tmux-split-statusbar&#39;
set -g @split-statusbar-mode &#39;off&#39;                 # [ on | off]

set -g @split-statusbar-bindkey &#39;-n F11&#39;          # [ M-s | -n F11 | ... ]
                                                  # bindkey for toggle statusbar-mode
                                                  # define yourself just like bind-key, default: M-s

set -g @split-status-hide-bindkey &#39;-n F12&#39;        # [ M-d | -n F12 | ... ]
                                                  # bindkey for status-left / status-right hiding
                                                  # define yourself just like bind-key, default: M-d
## =============================================================================

set -g pane-border-status bottom
## 只显示简单的正在运行命令
# set -g pane-border-format &#34;#P #T #{pane_current_command} &#34;
## 显示正在运行的命令所有参数
# set -g pane-border-format &#39;#(ps --no-headers -t #{pane_tty} -o args -O-c)&#39;
set -g pane-border-format &#39;#P #T #(ps --no-headers -t #{pane_tty} -o args -O-c) &gt;&#39;
```

## 快捷键设置

- `prefix-s`: 快速切换 sessions

    ```bash
    ## switch between sessoin
    bind-key s choose-session
    ```

- `prefix-o`: 快速重命名 panel

    ```bash
    ## rename-window
    bind-key o command-prompt -I &#34;#W&#34; &#34;rename-window &#39;%%&#39;&#34;
    ```

- `prefix-f`: 调用 `fzf` 快速查找 panel, 需要关闭原来的 `tmux-fzf`, 参考：[tmux and fzf: fuzzy tmux session/window/pane switcher](https://eioki.eu/2021/01/12/tmux-and-fzf-fuzzy-tmux-session-window-pane-switcher)

    1. 建立一个可执行文件

        ```bash
        #!/bin/bash

        # customizable
        LIST_DATA=&#34;#{window_name} #{pane_title} #{pane_current_path} #{pane_current_command}&#34;
        FZF_COMMAND=&#34;fzf-tmux -p --delimiter=: --with-nth 4 --color=hl:2&#34;

        # do not change
        TARGET_SPEC=&#34;#{session_name}:#{window_id}:#{pane_id}:&#34;

        # select pane
        LINE=$(tmux list-panes -a -F &#34;$TARGET_SPEC $LIST_DATA&#34; | $FZF_COMMAND) || exit 0
        # split the result
        args=(${LINE//:/ })
        # activate session/window/pane
        tmux select-pane -t ${args[2]} &amp;&amp; tmux select-window -t ${args[1]} &amp;&amp; tmux switch-client -t ${args[0]}
        ```

    2. 在 `.tmux.conf` 配置

        ```bash
        ## fzf
        # set -g @plugin &#39;sainnhe/tmux-fzf&#39;
        ## prefix-f
        # TMUX_FZF_LAUNCH_KEY=&#34;f&#34;
        # TMUX_FZF_ORDER=&#34;session|window|pane|command|keybinding|clipboard|process&#34;
        ## menu
        # TMUX_FZF_MENU=\
        # &#34;foo\necho &#39;Hello!&#39;\n&#34;\
        # &#34;bar\nls ~\n&#34;\
        # &#34;sh\nsh ~/test.sh\n&#34;
        bind-key f run-shell -b /home/william/.tmux/tmux-switch-pane.sh
        ```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-17-tmux-%E5%B0%8F%E6%8A%80%E5%B7%A7/  

