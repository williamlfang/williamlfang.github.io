# nvim 打开当前光标下文件


有时我们需要临时配置或者修改文件，一般的做法是进入 `visual` 模式然后使用命令 `gf` 打开当前文件。这样的做法其实有点冗余，特别是当我们在线上排查问题时，希望能快速打开光标下的文件。

为此，我们可以定义一个函数，然后绑定快捷键即可迅速打开文件了

- 定义一个函数 `JumpOrCreateFile`

    - 可以自动识别文件路径
    - 如果文件不存在，则提醒我们是否需要创建

- 绑定快捷键 `gf` 方便操作


```lua
vim.cmd([[
nnoremap &lt;silent&gt; gf :call JumpOrCreateFile()&lt;CR&gt;
function! JumpOrCreateFile()
    &#34; Get the filename under the cursor
    let filename = expand(&#34;&lt;cfile&gt;&#34;)

    &#34;--------------------------------------------------------------------------
    &#34; split to get filename path
    if filename =~# &#39;:&#39;
        let expanded_filename = expand(split(filename, &#34;:&#34;)[1])
    elseif filename =~# &#39;,&#39;
        let expanded_filename = expand(split(filename, &#34;,&#34;)[1])
    else
        let expanded_filename = expand(filename)
    endif
    &#34;--------------------------------------------------------------------------

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
        &#34; execute &#39;normal! gf&#39;
        execute &#39;edit &#39; . expanded_filename
    endif
endfunction
]])
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-26-nvim-%E6%89%93%E5%BC%80%E5%BD%93%E5%89%8D%E5%85%89%E6%A0%87%E4%B8%8B%E6%96%87%E4%BB%B6/  

