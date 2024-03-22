# nvim 直接打开当前光标下的文件


`nvim` 可以利用跳转功能，直接在当前光标下打开文件。如果该文件不存在，则新建一个。

我配置的快捷键是 `gf`(go file)。

&lt;!--more--&gt;

```lua
vim.cmd([[
nnoremap &lt;silent&gt; gf :call JumpOrCreateFile()&lt;CR&gt;
function! JumpOrCreateFile()
    &#34; Get the filename under the cursor
    let filename = expand(&#34;&lt;cfile&gt;&#34;)

    &#34; Expand the tilde in the file path
    let expanded_filename = expand(filename)

    &#34; Check if the file path starts with &#34;./&#34;
    if expanded_filename =~# &#39;^\.\/&#39;
        &#34; Get the current directory of the editing file
        let current_directory = expand(&#39;%:p:h&#39;)

        &#34; Create the full path by appending the relative file path
        let expanded_filename = current_directory . &#39;/&#39; . expanded_filename
    endif

    &#34; Check if the file exists
    if !filereadable(expanded_filename)
        &#34; Prompt the user for file creation with the full path
        let choice = confirm(&#39;File does not exist. Create &#34;&#39; . expanded_filename . &#39;&#34;?&#39;, &#34;&amp;Yes\n&amp;No&#34;, 1)
        &#34; Handle the user&#39;s choice
        if choice == 1
            &#34; Create the file and open it
            echohl WarningMsg | echo &#39;Created New File: &#39; . expanded_filename | echohl None
            execute &#39;edit &#39; . expanded_filename
        endif
    else
        &#34; File exists, perform normal gf behavior
        echohl ModeMsg | echo &#39;Open File: &#39; . expanded_filename | echohl None
        execute &#39;normal! gf&#39;
    endif
endfunction
]])
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-18-nvim-%E7%9B%B4%E6%8E%A5%E6%89%93%E5%BC%80%E5%BD%93%E5%89%8D%E5%85%89%E6%A0%87%E4%B8%8B%E7%9A%84%E6%96%87%E4%BB%B6/  

