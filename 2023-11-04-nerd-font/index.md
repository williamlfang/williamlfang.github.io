# nerd font


`nerd font` 是一款优秀的字体，提供了大量的图标，可以用于 `terminal`、`vim` 等终端显示。

&lt;!--more--&gt;

```bash
#/bin/bash
# install DroidSansMono Nerd Font --&gt; u can choose another at: https://www.nerdfonts.com/font-downloads
echo &#34;[-] Download fonts [-]&#34;
echo &#34;https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/DroidSansMono.zip&#34;
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/DroidSansMono.zip
unzip DroidSansMono.zip -d ~/.fonts
fc-cache -fv
echo &#34;done!&#34;
```


```bash
mkdir -p ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/SourceCodePro.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/NerdFontsSymbolsOnly.zip

unzip SourceCodePro.zip
cd SourceCodePro
cp ./* ~/.fonts

fc-cache -fv
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-11-04-nerd-font/  

