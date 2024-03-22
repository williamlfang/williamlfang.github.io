# glibc 2.17 与 clangd


由于公司有一台机器`R7`的系统版本较低，只有`glibc-2.17`，而且无法升级（为了兼容的问题）。为了可以让 `coc.vim` 可以使用 `clangd` 进行代码补全，需要找对与这个版本 `glibc-2.17` 相对应的 `clangd`。

`CentOS7` 与 `Ubuntu16.04` 使用这个版本 `clang&#43;&#43;llvm-13.0.0-x86_64-linux-gnu-ubuntu-16.04`

&lt;!--more--&gt;

```bash
## https://github.com/llvm/llvm-project/releases/tag/llvmorg-13.0.0
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/clang&#43;llvm-13.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-27-glibc-2.17-%E4%B8%8E-clangd/  

