# 入坑 HHKB 无刻键盘


决定在新的一年折腾一下自己，学习一些新的技能，比如

- 使用 `c&#43;&#43;` 开发一个高性能、低延迟的通信系统
- 更加了解 `Linux` 操作系统底层涉及
- 熟练使用 `nvim` 以及学习 `lua` 语言开发插件
- ......

再比如，本篇博客的主题：入坑 `HHKB` 无刻键盘，强迫自己在盲打情况下的写代码能力。

&lt;!--more--&gt;

其实，之前在办公室看意味年轻的小伙子使用无刻度键盘，就已经产生了极大的好奇心，纳闷为啥可以在如此紧凑的键盘布局中，组合如此之多的快捷键，可以让使用者更加专注敲代码这个事情。当然，后来也是不了了之，因为真正在办公室需要的，其实是解决问题的能力，而不是各种花里胡峭。至于说为什么现在又心血来潮，开始入坑呢？当然，主要还是两个字：折腾。也是希望自己能走出舒适区，通过学习新的知识，不断突破个人技能。

## 购买

这款键盘 `HHKB HYBRID Type-S 无刻静音键盘`，其实是我之前在京东 `6.18` 活动的时候就已经下手了，只不过后来由于事情太多，没有更多的精力花在折腾上。翻看购买记录，发现当时正处于促销活动期，价格只要 `999`，相比于现在的 `2499`，实在是太香了。

![当时的购买价格只要999](./jd-buy.jpg &#34;当时的购买价格只要999&#34;)

## 开发配置与使用

我的键位设置为：

- 开启 `2`、`3`、`4`：
- `Fn` 键位在左边，`Win` 键位在右边（比较少使用）
- `Fn-&lt;/Enter&gt;` 通过在 `Linux` 配置输入法切换
- `Ctrl-&lt;/Space&gt;` 对应 `zsh` 的命令行自动补全
- 在 `nvim` 设置 `jk` 为 `Esc`，减少手指移动

### xremap

我之前使用 `xremap`，把 `CapLock` 大写键位修改成 `Ctr`，方便小拇指触达。而在 `HHKB` 键盘，`Ctrl` 天然位于左手小拇指旁边。可以说是十分贴心了。

我这边记录一下 `xremap` 的配置，方便其他有需求的朋友参考

```yaml
modmap:
  - name: Cap as Esc # Optional
    application: # Optional
      not: [Google-chrome]
      # or
      # only: [Alacritty.Alacritty]
    remap: # Required
      CapsLock: Esc
#keymap
```

### zsh 命令行历史自动补全

我原先使用方向键来实现 `auto-suggestion` 的命令行自动补全。而在 `HHKB` 键盘，方向键的使用是比较复杂的，需要同时按住 `Fn` 和 `;`，这个操作有点不太顺手，要求双手离开主键位。

于是我想到看看能不能在 `zsh` 中以快捷键的形式，配置更加顺手的键位来实现自动补全。正好 `auto-suggestion` 提供了这个配置。

```zsh
# 自动建议
# zinit ice lucid wait=&#34;0&#34; atload=&#39;_zsh_autosuggest_start&#39;
# zinit light zsh-users/zsh-autosuggestions
# zinit wait lucid light-mode for \
#     atload&#34;_zsh_autosuggest_start; \
#         ZSH_AUTOSUGGEST_STRATEGY=(history completion) \
#         ZSH_AUTOSUGGEST_MANUAL_REBIND=0 \
#         ZSH_AUTOSUGGEST_HISTORY_IGNORE=&#39; *&#39; \
#         bindkey &#39;^p&#39; history-search-backward; \
#         bindkey &#39;^o&#39; history-search-forward; \
#         bindkey &#39;^n&#39; autosuggest-accept; \
#         bindkey &#39;^e&#39; autosuggest-execute; \
#         bindkey &#39;^a&#39; autosuggest-toggle; \
#         bindkey &#39;^ &#39; autosuggest-accept&#34; \
#     zsh-users/zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions/issues/642
# For example, this would bind ctrl &#43; space to accept the current suggestion.
zinit wait lucid light-mode for \
    atload&#34;_zsh_autosuggest_start; \
        ZSH_AUTOSUGGEST_STRATEGY=(history completion) \
        ZSH_AUTOSUGGEST_MANUAL_REBIND=0 \
        ZSH_AUTOSUGGEST_HISTORY_IGNORE=&#39; *&#39; \
        bindkey &#39;^ &#39; autosuggest-accept;&#34; \
    zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=&#39;fg=yellow&#39;
```

### tmux




---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-03-%E5%85%A5%E5%9D%91-hhkb-%E6%97%A0%E5%88%BB%E9%94%AE%E7%9B%98/  

