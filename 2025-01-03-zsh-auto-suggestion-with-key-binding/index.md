# zsh auto suggestion with key binding


We could bind key to `zsh-autosuggestions`. This is especially helpful when we use HHKB, whereas there is no such thing as left-arrow or right-arrow.

```zsh
# 自动建议
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


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-03-zsh-auto-suggestion-with-key-binding/  

