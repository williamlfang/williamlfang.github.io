# tmux fzf 快速搜索


使用 `tmux-fzf` 快速搜索窗口。

&lt;!--more--&gt;

## 修改 tmux-fzf

### main.sh

`vim ~/.tmux/plugins/tmux-fzf/main.sh`：相当于关闭了其他的选项。

```bash
#!/usr/bin/env bash

CURRENT_DIR=&#34;$(cd &#34;$(dirname &#34;${BASH_SOURCE[0]}&#34;)&#34; &amp;&amp; pwd)&#34;
[[ -z &#34;$TMUX_FZF_ORDER&#34; ]] &amp;&amp; TMUX_FZF_ORDER=&#34;session|window|pane|command|keybinding|clipboard|process&#34;
source &#34;$CURRENT_DIR/scripts/.envs&#34;

## ==============================================
## only pane
item=&#34;pane&#34;
#items_origin=&#34;$(echo $TMUX_FZF_ORDER | tr &#39;|&#39; &#39;\n&#39;)&#34;
#if [[ -z &#34;$TMUX_FZF_MENU&#34; ]]; then
#    item=$(printf &#34;%s\n[cancel]&#34; &#34;$items_origin&#34; | eval &#34;$TMUX_FZF_BIN $TMUX_FZF_OPTIONS&#34;)
#else
#    item=$(printf &#34;menu\n%s\n[cancel]&#34; &#34;$items_origin&#34; | eval &#34;$TMUX_FZF_BIN $TMUX_FZF_OPTIONS&#34;)
#fi
#[[ &#34;$item&#34; == &#34;[cancel]&#34; || -z &#34;$item&#34; ]] &amp;&amp; exit
## ==============================================
item=$(echo &#34;$CURRENT_DIR/scripts/$item&#34; | sed -E &#39;s/$/.sh/&#39;)
tmux run-shell -b &#34;$item&#34;
```

### pane.sh

`vim ~/.tmux/plugins/tmux-fzf/scripts/pane.sh`：相当于只针对 `switch` 执行命令

```bash
#!/usr/bin/env bash

CURRENT_DIR=&#34;$(cd &#34;$(dirname &#34;${BASH_SOURCE[0]}&#34;)&#34; &amp;&amp; pwd)&#34;
source &#34;$CURRENT_DIR/.envs&#34;

current_pane_origin=$(tmux display-message -p &#39;#S:#{window_index}.#{pane_index}: #{window_name}&#39;)
current_pane=$(tmux display-message -p &#39;#S:#{window_index}.#{pane_index}&#39;)

if [[ -z &#34;$TMUX_FZF_PANE_FORMAT&#34; ]]; then
    panes=$(tmux list-panes -a -F &#34;#S:#{window_index}.#{pane_index}: [#{window_name}:#{pane_title}] #{pane_current_command}  [#{pane_width}x#{pane_height}] [history #{history_size}/#{history_limit}, #{history_bytes} bytes] #{?pane_active,[active],[inactive]}&#34;)
else
    panes=$(tmux list-panes -a -F &#34;#S:#{window_index}.#{pane_index}: $TMUX_FZF_PANE_FORMAT&#34;)
fi

## ==============================================
## only switch
action=&#34;switch&#34;
#FZF_DEFAULT_OPTS=&#34;$FZF_DEFAULT_OPTS --header=&#39;Select an action.&#39;&#34;
#if [[ -z &#34;$1&#34; ]]; then
#    action=$(printf &#34;switch\nbreak\njoin\nswap\nlayout\nkill\nresize\nrename\n[cancel]&#34; | eval &#34;$TMUX_FZF_BIN $TMUX_FZF_OPTIONS&#34;)
#else
#    action=&#34;$1&#34;
#fi
## ==============================================

##------------- 其他的复制原来的代码 --------------- ##
[[ &#34;$action&#34; == &#34;[cancel]&#34; || -z &#34;$action&#34; ]] &amp;&amp; exit
```

## tmux.conf 设置

使用 `prefix-f`

```bash
## fzf
set -g @plugin &#39;sainnhe/tmux-fzf&#39;
## enable:1, disable:0
TMUX_FZF_PREVIEW=1
# prefix-f
TMUX_FZF_LAUNCH_KEY=&#34;f&#34;
#TMUX_FZF_ORDER=&#34;session|window|pane|command|keybinding|clipboard|process&#34;
TMUX_FZF_ORDER=&#34;pane|window|session&#34;
##Default value in tmux &gt;= 3.2
TMUX_FZF_OPTIONS=&#34;-p -w 90% -h 80% -m&#34;
## menu
#TMUX_FZF_MENU=\
#&#34;foo\necho &#39;Hello!&#39;\n&#34;\
#&#34;bar\nls ~\n&#34;\
#&#34;sh\nsh ~/test.sh\n&#34;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-09-13-tmux-fzf-%E5%BF%AB%E9%80%9F%E6%90%9C%E7%B4%A2/  

