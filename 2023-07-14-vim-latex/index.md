# vim latex


使用 `vim-latex` 编辑并生成 **pdf** 文件。

&lt;!--more--&gt;

# Install

## xelatex

```bash
sudo apt-get install texlive-xetex latex-cjk-all

## okular 用于预览 pdf 文件
sudo apt-get install okular
```

## vim-latex-preview

```vim
&#34; 使用 F6 自动调用命令
noremap &lt;silent&gt; &lt;F6&gt; :LLPStartPreview&lt;CR&gt;

&#34; LaTex
&#34; A Vim Plugin for Lively Previewing LaTeX PDF Output
Plug &#39;xuhdev/vim-latex-live-preview&#39;, { &#39;for&#39;: &#39;tex&#39; }

&#34;&#34; 配置
&#34;&#34; xelatex
&#34;&#34; okular
&#34;&#34; LaTex, Using: LLPStartPreview
autocmd Filetype tex setl updatetime=1
let g:livepreview_previewer = &#39;/usr/bin/okular&#39;
let g:livepreview_engine = &#39;/usr/bin/xelatex&#39;
```


# Make

```tex
\documentclass{article}
\usepackage{xeCJK}
\begin{document}
\title{APM源码笔记{}}
\author{菜刀}
\maketitle
%\today

\end{document}
``

```bash
xelatex test.tet
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-07-14-vim-latex/  

