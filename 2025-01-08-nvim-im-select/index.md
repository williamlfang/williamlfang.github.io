# nvim im select



使用 `vim` 进行中文输入，遇到的最大困难是要频繁的切换中英文，这个操作是比较繁琐的，往往会打断创作思路。我们的想法是，在 `insert` 模式下，使用中文输入；但是在 `normal` 模式下，则自动切换到英文输入，如此可以方便各种键位的操作。

在网上找了一会，发现有一个 `im-select` 的插件可以实现这个目的，使用起来非常的丝滑。


&lt;!--more--&gt;

# im-select

```bash
## 需要确认以下输入法其中的任何一个有安装即可
apt-get install fcitx
sudo apt install fcitx5
sudo apt install ibus

## install sogou and then reboot
apt --fix-broken install

## https://www.thisfaner.com/p/ubuntu-ime-install/
```

```lua
return {
    &#34;keaising/im-select.nvim&#34;,
    config = function()
        require(&#34;im_select&#34;).setup({
            -- IM will be set to `default_im_select` in `normal` mode
            -- For Windows/WSL, default: &#34;1033&#34;, aka: English US Keyboard
            -- For macOS, default: &#34;com.apple.keylayout.ABC&#34;, aka: US
            -- For Linux, default:
            --               &#34;keyboard-us&#34; for Fcitx5
            --               &#34;1&#34; for Fcitx
            --               &#34;xkb:us::eng&#34; for ibus
            -- You can use `im-select` or `fcitx5-remote -n` to get the IM&#39;s name
            -- default_im_select  = &#34;com.apple.keylayout.ABC&#34;,
            default_im_select  = &#34;1&#34;,

            -- Can be binary&#39;s name, binary&#39;s full path, or a table, e.g. &#39;im-select&#39;,
            -- &#39;/usr/local/bin/im-select&#39; for binary without extra arguments,
            -- or { &#34;AIMSwitcher.exe&#34;, &#34;--imm&#34; } for binary need extra arguments to work.
            -- For Windows/WSL, default: &#34;im-select.exe&#34;
            -- For macOS, default: &#34;macism&#34;
            -- For Linux, default: &#34;fcitx5-remote&#34; or &#34;fcitx-remote&#34; or &#34;ibus&#34;
            default_command = &#34;fcitx-remote&#34;,

            -- Restore the default input method state when the following events are triggered
            set_default_events = { &#34;VimEnter&#34;, &#34;FocusGained&#34;, &#34;InsertLeave&#34;, &#34;CmdlineLeave&#34; },

            -- Restore the previous used input method state when the following events
            -- are triggered, if you don&#39;t want to restore previous used im in Insert mode,
            -- e.g. deprecated `disable_auto_restore = 1`, just let it empty
            -- as `set_previous_events = {}`
            keep_quiet_on_no_binary = false,

            -- Async run `default_command` to switch IM or not
            async_switch_im = true
        })
    end,
}
```

# 标点符号的问题

1. 配置文件在目录`~/.config/fcitx/data`
2. 配置文件是 `punc-ng.mb-zh_CN` 和 `punc.mb.zh_CN`
3. 填写，然后重启输入法即可

```
. 。
, ，
? ？
&#34; “ ”
: ：
; ；
&#39; ‘ ’
&lt; 《
&gt; 》
\ 、
! ！
$ ￥
^ ……
* *
_ ——
( （
) ）
[ 「
]  」
~ ～
```

# ref

- [我的 fcitx 配置]：https://github.com/alswl/fcitx-config


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-08-nvim-im-select/  

