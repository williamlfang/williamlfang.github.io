# vim terminal 功能


`vim8` 以上版本支持在当前编辑界面直接打开终端，以方便执行命令行操作。

&lt;!--more--&gt;

## 在 vim 中打开 terminal

```vim
## 默认位于上端
:term
:below term

## 默认由于左端
:vertical term
:vertical below term
```

## 更多设置

- `tb`：terminal below
- `tr`：terminal right
- `Ctrl-D`：close terminal

```vim
&#34; terminal -------------------------------------------------------------------
function! PutTermPanel(buf, side, size) abort
  &#34; new term if no buffer
  if a:buf == 0
    term
  else
    execute &#34;sp&#34; bufname(a:buf)
  endif
  &#34; default side if wrong argument
  if stridx(&#34;hjklHJKL&#34;, a:side) == -1
    execute &#34;wincmd&#34; &#34;J&#34;
  else
    execute &#34;wincmd&#34; a:side
  endif
  &#34; horizontal split resize
  if stridx(&#34;jkJK&#34;, a:side) &gt;= 0
    if ! a:size &gt; 0
      resize 6
    else
      execute &#34;resize&#34; a:size
    endif
    return
  endif
  &#34; vertical split resize
  if stridx(&#34;hlHL&#34;, a:side) &gt;= 0
    if ! a:size &gt; 0
      vertical resize 6
    else
      execute &#34;vertical resize&#34; a:size
    endif
  endif
endfunction

function! s:ToggleTerminal(side, size) abort
  let tpbl=[]
  let closed = 0
  let tpbl = tabpagebuflist()
  &#34; hide visible terminals
  for buf in filter(range(1, bufnr(&#39;$&#39;)), &#39;bufexists(bufname(v:val)) &amp;&amp; index(tpbl, v:val)&gt;=0&#39;)
    if getbufvar(buf, &#39;&amp;buftype&#39;) ==? &#39;terminal&#39;
      silent execute bufwinnr(buf) . &#34;hide&#34;
      let closed &#43;= 1
    endif
  endfor
  if closed &gt; 0
    return
  endif
  &#34; open first hidden terminal
  for buf in filter(range(1, bufnr(&#39;$&#39;)), &#39;bufexists(v:val) &amp;&amp; index(tpbl, v:val)&lt;0&#39;)
    if getbufvar(buf, &#39;&amp;buftype&#39;) ==? &#39;terminal&#39;
      call PutTermPanel(buf, a:side, a:size)
      return
    endif
  endfor
  &#34; open new terminal
  call PutTermPanel(0, a:side, a:size)
endfunction

&#34; Toggle terminal - bottom
nnoremap &lt;silent&gt; tb :call &lt;SID&gt;ToggleTerminal(&#39;J&#39;, 10)&lt;CR&gt;
&#34; Toggle terminal - right
nnoremap &lt;silent&gt; tr :call &lt;SID&gt;ToggleTerminal(&#39;L&#39;, 120)&lt;CR&gt;
&#34; close terminal: Ctrl-D
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-28-vim-terminal-%E5%8A%9F%E8%83%BD/  

