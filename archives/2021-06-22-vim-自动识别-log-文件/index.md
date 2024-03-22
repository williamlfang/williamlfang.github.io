# Vim 自动识别 log 文件




# 自动识别 log 文件

```bash
# 在 ~/.vimrc 添加
au BufNewFile,BufRead *.log set filetype=log
```

&lt;!--more--&gt;

# 添加语法高亮

## systax

```bash
&#34; Vim syntax file
&#34; Language:         Generic log files
&#34; Maintainer:       Alex Dzyoba &lt;avd@reduct.ru&gt;
&#34; Latest Revision:  2013-03-08
&#34; Changes:          2013-03-08 Initial version

&#34; Based on messages.vim - syntax file for highlighting kernel messages

au BufRead,BufNewFile *.log set filetype=log

if exists(&#34;b:current_syntax&#34;)
  finish
endif

syn match log_fatal     &#39;\c.*\&lt;\(FATAL\|FTL\|FAIL\|FAILED\|FAILURE\).*&#39;
syn match log_error     &#39;\c.*\&lt;\(ERR\|ERROR\|ERRORS\).*&#39;
syn match log_warning   &#39;\c.*\&lt;\(WARNING\|DELETE\|DELETING\|DELETED\|RETRY\|RETRYING\).*&#39;
syn region log_string   start=/&#39;/ end=/&#39;/ end=/$/ skip=/\\./
syn region log_string   start=/&#34;/ end=/&#34;/ skip=/\\./
syn match log_number    &#39;0x[0-9a-fA-F]*\|\[&lt;[0-9a-f]\&#43;&gt;\]\|\&lt;\d[0-9a-fA-F]*&#39;

syn match   log_date &#39;\(Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\) [ 0-9]\d *&#39;
syn match   log_date &#39;\d\{4}-\d\d-\d\d&#39;
syn match   log_date &#39;^202\d\{1}\d\d\d\d&#39;

syn match   log_time &#39;\d\d:\d\d:\d\d\s*&#39;
syn match   log_time &#39;\c\d\d:\d\d:\d\d\(\.\d\&#43;\)\=\([&#43;-]\d\d:\d\d\|Z\)&#39;

hi def link log_string          Comment &#34;&#34;String
hi def link log_number          Comment &#34;&#34;Number
hi def link log_date            Constant
hi def link log_time            Type
hi def link log_fatal           ErrotMsg
hi def link log_error           Error
hi def link log_warning         WarningMsg

let b:current_syntax = &#34;log&#34;
```

## ftdetect

```bash
## 在 ~/.vimrc/ftdetect/log.vim
au BufNewFile,BufRead *.log set filetype=log
```





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-06-22-vim-%E8%87%AA%E5%8A%A8%E8%AF%86%E5%88%AB-log-%E6%96%87%E4%BB%B6/  

