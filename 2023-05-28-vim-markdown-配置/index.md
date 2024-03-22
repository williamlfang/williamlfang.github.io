# vim markdown 配置


为了支持 `markdown` 的相关功能

1. 可以按照标题级别进行折叠
2. 支持高亮代码块
3. 文本自动补全功能
4. 实时预览功能

&lt;!--more--&gt;

## coc-markdownlint

### 添加插件，实现语法自动检查

```vim
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;&#34; Coc
&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;&#34;
&#34;&#34; extensions
let g:coc_global_extensions = [&#39;coc-tsserver&#39;, &#39;coc-json&#39;, &#39;coc-yaml&#39;,
    \ &#39;coc-clangd&#39;, &#39;coc-pyright&#39;, &#39;coc-jedi&#39;,
    \ &#39;coc-html&#39;, &#39;coc-css&#39;, &#39;coc-xml&#39;,
    \ &#39;coc-emmet&#39;, &#39;coc-snippets&#39;,
    \ &#39;coc-markdownlint&#39;, &#39;coc-highlight&#39;]
```

### 自定义部分功能

在 `vim` 执行命令 `:CocConfig` 跳出 `coc-settings.json`。具体的检查规则可以参考默认配置文件：[coc-markdownlint/schemas/markdownlint-config-schema.json](https://github.com/fannheyward/coc-markdownlint/blob/master/schemas/markdownlint-config-schema.json)，找到这个规则

```json
&#34;default&#34;: true,
&#34;properties&#34;: {
  &#34;line_length&#34;: {
    &#34;description&#34;: &#34;Number of characters&#34;,
    &#34;type&#34;: &#34;integer&#34;,
    &#34;minimum&#34;: 1,
    &#34;default&#34;: 80
  },
```

1. 去掉段落长度的检查。通常我们写 `markdown` 不可能把每一行限制在 **80** 个字符串的长度，因此需要将改检查功能关闭。

```json
  // coc.markdown
  &#34;markdownlint.config&#34;: {
      &#34;default&#34;: true,
      &#34;line_length&#34;: false,
      &#34;no-inline-html&#34;: { &#34;allowed_elements&#34;: [&#34;pre&#34;] },
      &#34;ul-indent&#34;: { &#34;indent&#34;: 4 }
  },
```


## 标题折叠

按照标题不同的级别进行折叠，有助于更加清晰的把握文章的框架。这里我比较推荐 `vim-minimd`，可以实现

- `Space`: Fold or unfold the current header.
- `n-Space`: Fold all headers of level n.
- `Tab` or `]h`	Jump to next header.
- `Shift-Tab` Jump to previous header.

具体的指令如下：

- nmap &lt;silent&gt;&lt;buffer&gt; &lt;Space&gt; :&lt;C-u&gt;MiniMDToggleFold&lt;CR&gt;
- nmap &lt;silent&gt;&lt;buffer&gt; &lt;Tab&gt; :&lt;C-u&gt;MiniMDNext&lt;CR&gt;
- nmap &lt;silent&gt;&lt;buffer&gt; &lt;S-Tab&gt; :&lt;C-u&gt;MiniMDPrev&lt;CR&gt;
- nmap &lt;silent&gt;&lt;buffer&gt; ]h :&lt;C-u&gt;MiniMDNext&lt;CR&gt;
- nmap &lt;silent&gt;&lt;buffer&gt; [h :&lt;C-u&gt;MiniMDPrev&lt;CR&gt;
- nnoremap &lt;silent&gt;&lt;buffer&gt; = :MiniMDPromote&lt;CR&gt;
- nnoremap &lt;silent&gt;&lt;buffer&gt; - :MiniMDDemote&lt;CR&gt;
- nmap &lt;silent&gt;&lt;buffer&gt; &lt;CR&gt; :MiniMDTaskToggle&lt;CR&gt;
- vmap &lt;silent&gt;&lt;buffer&gt; &lt;CR&gt; :MiniMDTaskToggle&lt;CR&gt;

同时，为了可以利用原来的 `markdown` 语法进行高亮，可以设置 `let g:default_markdown_syntax = 1`。这个需要配合插件 `tpope/vim-markdown`

```vim
&#34; markdown --------------------------------------------------------------------
Plug &#39;godlygeek/tabular&#39;
&#34; 这个显示有点问题
&#34; Plug &#39;preservim/vim-markdown&#39;
&#34; 用这个可以高亮语法
Plug &#39;tpope/vim-markdown&#39;
let g:vim_markdown_folding_disabled=1
&#34; 这里面有部分是不支持的
&#34; let g:markdown_fenced_languages = [&#39;bash=sh&#39;, &#39;css&#39;, &#39;django&#39;, &#39;handlebars&#39;,
&#34;     \ &#39;javascript&#39;, &#39;js=javascript&#39;, &#39;json=javascript&#39;, &#39;perl&#39;, &#39;php&#39;,
&#34;     \ &#39;python&#39;, &#39;ruby&#39;, &#39;sass&#39;, &#39;xml&#39;, &#39;html&#39;, &#39;c&#43;&#43;=cpp&#39;]
let g:markdown_fenced_languages = [&#39;bash=sh&#39;, &#39;python&#39;, &#39;ruby&#39;, &#39;c&#43;&#43;=cpp&#39;,
    \ &#39;xml&#39;, &#39;html&#39;, &#39;css&#39;, &#39;ruby&#39;, &#39;r&#39;, &#39;vim&#39;,
    \ &#39;javascript&#39;, &#39;js=javascript&#39;, &#39;json=javascript&#39;, &#39;perl&#39;, &#39;php&#39;]
let g:vim_markdown_math = 1
let g:vim_markdown_toc_autofit = 1
let g:markdown_syntax_conceal = 1

&#34; 支持按照原来的 markdown 语法进行高亮
let g:default_markdown_syntax = 1
Plug &#39;shushcat/vim-minimd&#39;
&#34; Space	    Fold or unfold the current header.
&#34; nSpace    Fold all headers of level n.
```

## 自动补全

通过识别 `tmux` 页面的文本，进行自动补全。

```vim
Plug &#39;prabirshrestha/async.vim&#39;
Plug &#39;prabirshrestha/asyncomplete.vim&#39;
Plug &#39;wellle/tmux-complete.vim&#39;
let g:tmuxcomplete#asyncomplete_source_options = {
            \ &#39;name&#39;:      &#39;tmuxcomplete&#39;,
            \ &#39;whitelist&#39;: [&#39;*&#39;],
            \ &#39;config&#39;: {
            \     &#39;splitmode&#39;:      &#39;words&#39;,
            \     &#39;filter_prefix&#39;:   1,
            \     &#39;show_incomplete&#39;: 1,
            \     &#39;sort_candidates&#39;: 0,
            \     &#39;scrollback&#39;:      0,
            \     &#39;truncate&#39;:        0
            \     }
            \ }
let g:tmuxcomplete#trigger = &#39;omnifunc&#39;
imap &lt;c-space&gt; &lt;Plug&gt;(asyncomplete_force_refresh)
inoremap &lt;expr&gt; &lt;CR&gt; pumvisible() ? asyncomplete#close_popup() . &#34;\&lt;CR&gt;&#34; : &#34;\&lt;CR&gt;&#34;
```

## 更加专注的写作

现在能真正静下心来、完整而严禁的写作时间，其实是非常珍贵的。一方面是由于外部的干扰因素太多，无法给以写作足够的空间和时间；另一方面，我们内心也变得浮躁，难以静心进行深度思考。

这时候，我们希望能在工具上，对这些干扰因素进行限制，期待能营造一个良好的写作氛围（希望如此）。

`goyo` 这个就是为了此目的而生的，可以让我们在写作时，只需要面对一个屏幕，不用在意周遭环境。

- 进入模式：`&lt;Leader&gt;gy`
- 退出模式：`&lt;Leader&gt;gy`

```vim
Plug &#39;junegunn/limelight.vim&#39;
Plug &#39;junegunn/goyo.vim&#39;

function! s:goyo_enter() if executable(&#39;tmux&#39;) &amp;&amp; strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F &#39;\#F&#39; | grep -q Z || tmux resize-pane -Z
  endif
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
  &#34; ...
endfunction

function! s:goyo_leave()
  if executable(&#39;tmux&#39;) &amp;&amp; strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F &#39;\#F&#39; | grep -q Z &amp;&amp; tmux resize-pane -Z
  endif
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
  &#34; ...
endfunction

&#34; 进入goyo模式后自动触发limelight，退出则关闭
autocmd! User GoyoEnter nested call &lt;SID&gt;goyo_enter()
&#34;进入goyo模式后自动触发limelight,退出后则关闭
autocmd! User GoyoLeave nested call &lt;SID&gt;goyo_leave()

&#34;Goyo
&#34; Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = &#39;Gray&#39;
let g:limelight_conceal_ctermfg = 240
&#34; Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = &#39;DarkGray&#39;
let g:limelight_conceal_guifg = &#39;#777777&#39;
&#34; 包含的前后段的数量
let g:limelight_paragraph_span = 2
&#34; Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1
&#34; Goyo配置
let g:goyo_width = 80
let g:goyo_height = 90
let g:goyo_linenr = 0
&#34; limelight键盘映射
nmap &lt;Leader&gt;gy :Goyo&lt;CR&gt;
```

## markdown-preview

`vim` 支持对 `markdown` 文档执行实时的渲染，并通过浏览器打开。同时，在页面浏览器模式中，页面会随着当前光标自动随行移动，非常便捷。

1. 安装插件

    ```vim
    Plug &#39;iamcco/markdown-preview.nvim&#39;
    ```

2. 在 `vim` 执行命令

    ```vim
    :PlugInstall
    :call mkdp#util#install()
    ```

3. 设置

    - 显示网页地址，可以在终端直接打开，这个有助于远程文本在本地打开： `let g:mkdp_echo_preview_url = 1`
    - 设置网页地址，默认是本地地址：`let g:mkdp_echo_preview_url = 1`
    - 设置访问端口，默认是随机，我们可以把端口固定下来，方便打开页面：`let g:mkdp_port = &#39;1111&#39;`
    - 设置页面主题颜色，一般是黑色模式：`let g:mkdp_theme = &#39;dark&#39;`
    - 默认打开网页：`let g:mkdp_browser = &#39;/usr/bin/firefox&#39;`

4. 使用

    - 开启Mardown预览 `:MarkdownPreview`
    - 关闭Mardown预览 `:MarkdownPreviewStop`

    ```vim
    &#34; example -------------------------
    nmap &lt;Leader&gt;mp &lt;Plug&gt;MarkdownPreview
    nmap &lt;Leader&gt;ms &lt;Plug&gt;MarkdownPreviewStop
    nmap &lt;Leader&gt;mt &lt;Plug&gt;MarkdownPreviewToggle
    ``

![maarkdown-preview](/post/2023-05-28-vim-markdown-配置/mkd-preview.png)

```vim
&#34; markdown-preview
Plug &#39;iamcco/markdown-preview.nvim&#39;, { &#39;do&#39;: &#39;cd app &amp;&amp; yarn install&#39;  }
&#34; set to 1, nvim will open the preview window after entering the markdown buffer
&#34; default: 0
let g:mkdp_auto_start = 0

&#34; set to 1, the nvim will auto close current preview window when change
&#34; from markdown buffer to another buffer
&#34; default: 1
let g:mkdp_auto_close = 1

&#34; set to 1, the vim will refresh markdown when save the buffer or
&#34; leave from insert mode, default 0 is auto refresh markdown as you edit or
&#34; move the cursor
&#34; default: 0
let g:mkdp_refresh_slow = 0

&#34; set to 1, the MarkdownPreview command can be use for all files,
&#34; by default it can be use in markdown file
&#34; default: 0
let g:mkdp_command_for_global = 0

&#34; set to 1, preview server available to others in your network
&#34; by default, the server listens on localhost (127.0.0.1)
&#34; default: 0
let g:mkdp_open_to_the_world = 1

&#34; use custom IP to open preview page
&#34; useful when you work in remote vim and preview on local browser
&#34; more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
&#34; default empty
let g:mkdp_open_ip = &#39;&#39;

&#34; specify browser to open preview page
&#34; for path with space
&#34; valid: `/path/with\ space/xxx`
&#34; invalid: `/path/with\\ space/xxx`
&#34; default: &#39;&#39;
let g:mkdp_browser = &#39;/usr/bin/firefox&#39;

&#34; set to 1, echo preview page url in command line when open preview page
&#34; default is 0
let g:mkdp_echo_preview_url = 1

&#34; a custom vim function name to open preview page
&#34; this function will receive url as param
&#34; default is empty
let g:mkdp_browserfunc = &#39;&#39;
function OpenMarkdownPreview (url)
    execute &#34;silent ! firefox --new-window &#34; . a:url
endfunction
let g:mkdp_browserfunc = &#39;OpenMarkdownPreview&#39;

&#34; options for markdown render
&#34; mkit: markdown-it options for render
&#34; katex: katex options for math
&#34; uml: markdown-it-plantuml options
&#34; maid: mermaid options
&#34; disable_sync_scroll: if disable sync scroll, default 0
&#34; sync_scroll_type: &#39;middle&#39;, &#39;top&#39; or &#39;relative&#39;, default value is &#39;middle&#39;
&#34;   middle: mean the cursor position alway show at the middle of the preview page
&#34;   top: mean the vim top viewport alway show at the top of the preview page
&#34;   relative: mean the cursor position alway show at the relative positon of the preview page
&#34; hide_yaml_meta: if hide yaml metadata, default is 1
&#34; sequence_diagrams: js-sequence-diagrams options
&#34; content_editable: if enable content editable for preview page, default: v:false
&#34; disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ &#39;mkit&#39;: {},
    \ &#39;katex&#39;: {},
    \ &#39;uml&#39;: {},
    \ &#39;maid&#39;: {},
    \ &#39;disable_sync_scroll&#39;: 0,
    \ &#39;sync_scroll_type&#39;: &#39;middle&#39;,
    \ &#39;hide_yaml_meta&#39;: 1,
    \ &#39;sequence_diagrams&#39;: {},
    \ &#39;flowchart_diagrams&#39;: {},
    \ &#39;content_editable&#39;: v:false,
    \ &#39;disable_filename&#39;: 0,
    \ &#39;toc&#39;: {}
    \ }

&#34; use a custom markdown style must be absolute path
&#34; like &#39;/Users/username/markdown.css&#39; or expand(&#39;~/markdown.css&#39;)
let g:mkdp_markdown_css = &#39;&#39;

&#34; use a custom highlight style must absolute path
&#34; like &#39;/Users/username/highlight.css&#39; or expand(&#39;~/highlight.css&#39;)
let g:mkdp_highlight_css = &#39;&#39;

&#34; use a custom port to start server or empty for random
let g:mkdp_port = &#39;1111&#39;

&#34; preview page title
&#34; ${name} will be replace with the file name
let g:mkdp_page_title = &#39;「${name}」&#39;

&#34; recognized filetypes
&#34; these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = [&#39;markdown&#39;]

&#34; set default theme (dark or light)
&#34; By default the theme is define according to the preferences of the system
let g:mkdp_theme = &#39;dark&#39;

&#34; example -------------------------
nmap &lt;Leader&gt;mp &lt;Plug&gt;MarkdownPreview
nmap &lt;Leader&gt;ms &lt;Plug&gt;MarkdownPreviewStop
nmap &lt;Leader&gt;mt &lt;Plug&gt;MarkdownPreviewToggle
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-28-vim-markdown-%E9%85%8D%E7%BD%AE/  

