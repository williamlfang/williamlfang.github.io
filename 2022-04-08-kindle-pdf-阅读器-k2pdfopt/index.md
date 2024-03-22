# Kindle PDF 阅读器：k2pdfopt


在 Kindle 上面最优的阅读体验，首选肯定是官方支持的 `azw3` 格式。但是当我们需要阅读一些论文或者电子书籍的时候，往往可以获取得到的只有 `PDF` 格式的电子版。`PDF` 一般是以 `A4` 样式存在，对于小屏幕的电子设置，往往阅读体验不是特(hen)别(zao)好(gao)。

直观的想法就是，我们可以通过某种方式，把 `A4` 大小的电子文档，通过一定的分割方式，转化成适合小屏幕阅读的格式。所谓的[某种格式]，其实就是利用了 `OCR` 的文字识别功能，通过算法整合，形成新的电子文档。

&lt;!--more--&gt;

这款开源神器，[`K2pdfopt`](https://www.willus.com/k2pdfopt/) ，应运而生。

## 安装

网站上提供了编译好的可执行文件，直接下载到本地，即可使用。

## 使用

```bash
./K2pdfopt your_file.pdf
```

## epub to mobi

```bash
alias kindle.mobi=&#39;for book in *.epub; do echo &#34;Converting $book&#34;; ebook-convert &#34;$book&#34; &#34;$(basename &#34;$book&#34; .epub).mobi&#34;; done&#39;

alias kindle.pdf=&#39;for book in *.pdf; do echo &#34;Converting $book&#34;; yes &#34;&#34; | /home/william/k2pdfopt ${book}; done&#39;
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-04-08-kindle-pdf-%E9%98%85%E8%AF%BB%E5%99%A8-k2pdfopt/  

