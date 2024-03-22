# vim repl


在 `Vim` 环境中运行 `REPL` 程序。

- 使用触发键 `&lt;Leader&gt;t`

- 对于多个 `buffer` 的问题，需要改一下绑定键

    ```bash
    &#34; handling multi buffer switch:  https://github.com/sillybun/vim-repl/issues/19
    tnoremap &lt;Leader&gt;n &lt;C-w&gt;:bnext&lt;CR&gt;
    ```

&lt;!--more--&gt;

```bash
Plug &#39;sillybun/vim-repl&#39;, { &#39;for&#39;: [&#39;python&#39;, &#39;r&#39;], &#39;on&#39;:&#39;REPLToggle&#39; }

&#34; Vim-repl -------------------------------------------------------------------
let g:repl_program = {
            \   &#39;python&#39;: &#39;ipython&#39;,
            \   &#39;default&#39;: &#39;zsh&#39;,
            \   &#39;r&#39;: &#39;R&#39;,
            \   &#39;lua&#39;: &#39;lua&#39;,
            \   }
let g:repl_width = 120 &#34;REPL windows width&#34;
let g:repl_predefine_python = {
            \   &#39;numpy&#39;: &#39;import numpy as np&#39;,
            \   &#39;matplotlib&#39;: &#39;from matplotlib import pyplot as plt&#39;
            \   }
let g:repl_python_auto_import = 1
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = &#39;7&#39;
let g:repl_auto_sends = [&#39;class &#39;, &#39;def &#39;, &#39;for &#39;, &#39;if &#39;, &#39;while &#39;, &#39;with &#39;, &#39;async def&#39;, &#39;@&#39;, &#39;try&#39;]
let g:repl_python_auto_send_unfinish_line = 1
let g:repl_cursor_down = 1
let g:repl_python_auto_import = 1
nnoremap &lt;Leader&gt;t :REPLToggle&lt;Cr&gt;
&#34; handling multi buffer switch:  https://github.com/sillybun/vim-repl/issues/19
tnoremap &lt;Leader&gt;n &lt;C-w&gt;:bnext&lt;CR&gt;
tnoremap &lt;Leader&gt;h &lt;C-w&gt;&lt;C-h&gt;
tnoremap &lt;Leader&gt;l &lt;C-w&gt;&lt;C-l&gt;
&#34;let g:repl_width = None                           &#34;窗口宽度
&#34;let g:repl_height = None                          &#34;窗口高度
&#34; ref: http://stackoverflow.com/questions/598113/can-terminals-detect-shift-enter-or-control-enter
let g:sendtorepl_invoke_key = &#34;&lt;CR&gt;&#34;          &#34;传送代码快捷键，默认为&lt;leader&gt;w
nnoremap &lt;leader&gt;re :REPLSendSession&lt;Cr&gt;
let g:repl_position = 3                             &#34;0表示出现在下方，1表示出现在上方，2在左边，3在右边
let g:repl_stayatrepl_when_open = 0         &#34;打开REPL时是回到原文件（1）还是停留在REPL窗口中（0）&#34;
let g:repl_console_name = &#39;Vim-REPL&#39;
tnoremap &lt;C-h&gt; &lt;C-w&gt;&lt;C-h&gt;
tnoremap &lt;C-j&gt; &lt;C-w&gt;&lt;C-j&gt;
tnoremap &lt;C-k&gt; &lt;C-w&gt;&lt;C-k&gt;
tnoremap &lt;C-l&gt; &lt;C-w&gt;&lt;C-l&gt;

&#34; tnoremap &lt;C-n&gt; &lt;C-w&gt;N
tnoremap &lt;ScrollWheelUp&gt; &lt;C-w&gt;Nk
tnoremap &lt;ScrollWheelDown&gt; &lt;C-w&gt;Nj
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-09-16-vim-repl/  

