# nvim keep fold on save



```lua
vim.cmd([[
augroup remember_folds
    autocmd!
    au BufWinLeave ?* mkview 1
    au BufWinEnter ?* silent! loadview 1
augroup END
]])
```
&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-01-nvim-keep-fold-on-save/  

