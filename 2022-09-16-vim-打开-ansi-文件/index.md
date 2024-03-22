# vim 打开 Ansi 文件


使用 VIm 打开 Ansi 颜色的文件。

&lt;!--more--&gt;

## 使用 vim.plug

````
Plug &#39;powerman/vim-plugin-AnsiEsc&#39;

&#34;autocmd BufRead * AnsiEsc
:AnsiEsc
````

## 直接安装

```bash
git clone https://github.com/powerman/vim-plugin-AnsiEsc.git
cp -r vim-plugin-AnsiEsc ~/.vim

vim -R &#43;AnsiEsc
# 或者
:AnsiEsc

```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-16-vim-%E6%89%93%E5%BC%80-ansi-%E6%96%87%E4%BB%B6/  

