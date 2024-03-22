# nerdtree 自动切换到当前目录


```bash
set autochdir
let NERDTreeChDirMode=2
nnoremap &lt;leader&gt;n :NERDTree .&lt;CR&gt;
```

so that NERDTree always opens in the current folder.

- With the 1st line, the working directory is always the one where the active buffer is located.
- With the 2nd line, I make sure the working directory is set correctly.
- With the 3rd line, I hit `&lt;leader&gt;n` to open NERDTree.

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-nerdtree-%E8%87%AA%E5%8A%A8%E5%88%87%E6%8D%A2%E5%88%B0%E5%BD%93%E5%89%8D%E7%9B%AE%E5%BD%95/  

