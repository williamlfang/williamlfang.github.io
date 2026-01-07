# maple font


&lt;!--more--&gt;
最近发现一款不错的字体.

```bash
## https://github.com/subframe7536/maple-font/releases/tag/v7.9
wget https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMono-NF-CN-unhinted.zip

unzip MapleMono-NF-CN-unhinted.zip -d maple-font
cd maple-font

cp *ttf /usr/share/fonts/truetype/
fc-cache -fv
```

```toml
## -----------------------------------------------------------------------------font
[font]
size = 14.0
[font.normal]
# family = &#34;SauceCodePro Nerd Font&#34;
# family = &#34;JetBrainsMono Nerd Font&#34;
family = &#34;Maple Mono NF CN&#34;
style = &#34;Regular&#34;
[font.italic]
# family = &#34;SauceCodePro Nerd Font&#34;
# family = &#34;JetBrainsMono Nerd Font&#34;
family = &#34;Maple Mono NF CN&#34;
style = &#34;Italic&#34;
[font.bold]
# family = &#34;SauceCodePro Nerd Font&#34;
# family = &#34;JetBrainsMono Nerd Font&#34;
family = &#34;Maple Mono NF CN&#34;
style = &#34;Bold&#34;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-01-06-maple-font/  

