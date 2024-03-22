# LaTeX 合并独立子文件



我们在处理 LaTeX 多文档的时候，常常会遇到这样的情况

&gt; 有一个主文件，包含需要的 preamble 内容，同时还有其他子文件，各自都有自己的 preamble。现在的问题是，我们想要在主文件里，把其他的子文件都包含进去。这样的意思是，一方面，每个单独的子文件是可以独立 compile 的，同时，又可以把这些子文件统一合并到主文件当中。

&lt;!--more--&gt;

LaTeX 有 *input* 和 *include* 来包含子文件，但这两个命令都要求不包含 *preamble*。因此，对于原先存在有 *preamble* 的独立子文件，我们需要这样的命令

&gt; 能够自动识别并判断 *preamble*，然后自动跳过，只是抽取文档的正文进行编译。

解决这个问题有多种方式，不过我尝试后，方向使用 [docmute](http://mirrors.tuna.tsinghua.edu.cn/CTAN/macros/latex/contrib/docmute/docmute.pdf) 包是最好用的。其用法为

- 1. 在主文件的 preamble 插入 \usepackage{docmute} 
- 2. 对于需要引入的子文件，直接使用 \input{subfile.tex}，它会自动识别，并只把正文部分插入进来

---

> 作者:   
> URL: https://williamlfang.github.io/archives/2016-02-19-latex-%E5%90%88%E5%B9%B6%E7%8B%AC%E7%AB%8B%E5%AD%90%E6%96%87%E4%BB%B6/  

