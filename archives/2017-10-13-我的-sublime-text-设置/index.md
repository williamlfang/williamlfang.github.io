# 我的 Sublime Text 设置




![](/images/mySublime.jpg)

# 一款神奇的`IDE`

`Sublime Text 3` 原本是一款编辑器，可以用来编辑绝大多数的文件格式。后来，随着相关插件的增加与增强，它也逐渐演变成为一种轻便式的 `IDE`，能够用于处理 `REPL`（read-evaluate-print-loop）制式的编程语言，如 `R`、`Python`等，亦可结合操作系统的终端，实现对 `C/C&#43;&#43;` 程序的编译。

目前我主要使用的脚本语言，`R`、`Python`，网页开发语言 `html`、`JavaScript` 、`css`，以及系统开发语言 `C&#43;&#43;`，均可一站式地在 `Sublime Text` 中进行编辑、编译、执行操作等。因此，我对 `Sublime`的使用粘度较高。与此同时，`Sublime` 让我最为满意的一点，是允许用户通过偏好设置来实现个人定制化的快捷键操作。通过适当的配置个人偏好，可以极大的提升我的编程效率。

这里，我通过分享个人常用的一些插件、系统偏好设置、快捷键设置，与诸位看客一同来见证 `Sublime` 的神奇。


# 常用软件包

以下是我常用的一些增强软件包：

- R-Box
- R-snippets
- R_comments
- sendCode：通过 `Sublime` 向系统的终端发送命令
- Sublime REPL：执行操作，实现 `REPL`。

    - 如果需要再 REPL 屏幕显示命令， 可以这样设置: preference -&gt; Package Settings -&gt; SublimeREPL -&gt; Setting User -&gt; 添加

          {
              &#34;show_transferred_text&#34;: true
          }

- SFTP：连接远程服务器，实现在本地 `IDE` 编辑服务器上面的文件
- Material Theme：一款漂亮的主题
- Material Theme AppBar
- SideBarEnhancements：增强版的边栏，实现显示项目文件、文件类型图标、文件基本操作等
- MarkdownLivePreview: alt&#43;m
- Markdown Extended
- 解决中文乱码：GBK Support, ConvertToUTF8, Codecs33
- AutoPEP8：python 规范化
- SublimeCodeIntel：实现语法自动高亮
- Python BreakPoint
- Markdown 预览： markmon
- Git &#43; Github：Git, GithubTools， 实现在 `Sublime` 显示修改痕迹、直接上传修改等功能
- Jedi python autocomplete：非常好用的自动补全代码
- StatusBarTime: 在状态栏显示系统时间
- GitGutter
- Auto-save: 通过设置 keybinds:{ &#34;keys&#34;: [&#34;ctrl&#43;shift&#43;s&#34;], &#34;command&#34;: &#34;auto_save&#34; }
- C&#43;&#43; Completes
- DocBlockr_Python：Python 格式的注释
- DocBlockr_with_update_capability
- PlainTasks：搭建任务列表，异常的温馨好用
- Plain Notes
- Alignment: ctrl&#43;altt&#43;a 实现对齐: 在 setting-user 里面添加
- Terminal: 在文件路径 ctrl &#43; shift &#43; T 打开终端
- 输入法：https://github.com/lyfeyaj/sublime-text-imfix



# 偏好设置

修改路径为 `Preferences/setting`

    {
    &#34;always_show_minimap_viewport&#34;: true,
    &#34;auto_complete_commit_on_tab&#34;: true,
    &#34;auto_find_in_selection&#34;: true,
    &#34;bold_folder_labels&#34;: true,
    &#34;color_scheme&#34;: &#34;Packages/Material Theme/schemes/Material-Theme.tmTheme&#34;,
    &#34;default_encoding&#34;: &#34;UTF-8&#34;,
    &#34;draw_minimap_border&#34;: false,
    &#34;ensure_newline_at_eof_on_save&#34;: true,
    &#34;fade_fold_buttons&#34;: false,
    &#34;fold_buttons&#34;: true,
    &#34;font_options&#34;:
    [
    &#34;gray_antialias&#34;,
    &#34;subpixel_antialias&#34;
    ],
    &#34;font_size&#34;: 9,
    &#34;format_on_save&#34;: true,
    &#34;highlight_line&#34;: true,
    &#34;highlight_modified_tabs&#34;: true,
    &#34;ignored_packages&#34;:
    [
    &#34;Auto Fold&#34;,
    &#34;Vintage&#34;
    ],
    &#34;indent_guide_options&#34;:
    [
    &#34;draw_normal&#34;,
    &#34;draw_active&#34;
    ],
    &#34;line_numbers&#34;: true,
    &#34;line_padding_bottom&#34;: 3,
    &#34;line_padding_top&#34;: 3,
    &#34;match_selection&#34;: true,
    &#34;mdpopups.sublime_user_lang_map&#34;: null,
    &#34;mdpopups.use_sublime_highlighter&#34;: null,
    &#34;overlay_scroll_bars&#34;: &#34;enabled&#34;,
    &#34;reveal_in_side_bar&#34;: true,
    &#34;rulers&#34;:
    [
    80,
    100
    ],
    &#34;save_on_focus_lost&#34;: true,
    &#34;show_encoding&#34;: true,
    &#34;show_sidebar_on_activated&#34;: true,
    &#34;spell_check&#34;: false,
    &#34;tab_size&#34;: 4,
    &#34;theme&#34;: &#34;Material-Theme.sublime-theme&#34;,
    &#34;translate_tabs_to_spaces&#34;: true,
    &#34;trim_trailing_white_space_on_save&#34;: false,
    &#34;update_check&#34;: false,
    &#34;word_separators&#34;: &#34;./\\()\&#34;&#39;:,.;&lt;&gt;~!@#$%^&amp;*|&#43;=[]{}`~?&#34;,
    &#34;word_wrap&#34;: true
    }

-----

# 快捷键设置

    [
      { &#34;keys&#34;: [&#34;enter&#34;], &#34;command&#34;: &#34;move&#34;, &#34;args&#34;: {&#34;by&#34;: &#34;characters&#34;, &#34;forward&#34;: true}, &#34;context&#34;:
      [
    // { &#34;key&#34;: &#34;following_text&#34;, &#34;operator&#34;: &#34;regex_contains&#34;, &#34;operand&#34;: &#34;^[)\\]\\&gt;\\&#39;\\\&#34;]&#34;, &#34;match_all&#34;: true },
      // { &#34;key&#34;: &#34;following_text&#34;, &#34;operator&#34;: &#34;regex_contains&#34;, &#34;operand&#34;: &#34;^[)\\&gt;\\&#39;\\\&#34;]&#34;, &#34;match_all&#34;: true },
      { &#34;key&#34;: &#34;following_text&#34;, &#34;operator&#34;: &#34;regex_contains&#34;, &#34;operand&#34;: &#34;^[\\&gt;\\&#39;]&#34;, &#34;match_all&#34;: true },
      ]
      },

      { &#34;keys&#34;: [&#34;control&#43;m&#34;], &#34;command&#34;: &#34;insert_snippet&#34;, &#34;args&#34;: {&#34;contents&#34;: &#34; %&gt;% \n&#34;}
      },

    // { &#34;keys&#34;: [&#34;alt&#43;m&#34;], &#34;command&#34;: &#34;insert_snippet&#34;, &#34;args&#34;: {&#34;contents&#34;: &#34; %&gt;% &#34;}
    // },

      { &#34;keys&#34;: [&#34;control&#43;,&#34;], &#34;command&#34;: &#34;insert_snippet&#34;, &#34;args&#34;: {&#34;contents&#34;: &#34; := &#34;}
      },

      { &#34;keys&#34;: [&#34;alt&#43;-&#34;], &#34;command&#34;: &#34;insert_snippet&#34;, &#34;args&#34;: {&#34;contents&#34;: &#34; &lt;- &#34;}
      },

      { &#34;keys&#34;: [&#34;control&#43;.&#34;], &#34;command&#34;: &#34;insert_snippet&#34;, &#34;args&#34;: {&#34;contents&#34;: &#34; &lt;- &#34;}
      },

      {&#34;keys&#34;:[&#34;alt&#43;b&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Python - PDB current file&#34;,
      &#34;command&#34;: &#34;run_existing_window_command&#34;, &#34;args&#34;:
      {
      &#34;id&#34;: &#34;repl_python_pdb&#34;,
      &#34;file&#34;: &#34;config/Python/Main.sublime-menu&#34;
      }},

      {&#34;keys&#34;:[&#34;alt&#43;p&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Python - RUN current file&#34;,
      &#34;command&#34;: &#34;run_existing_window_command&#34;, &#34;args&#34;:
      {
      &#34;id&#34;: &#34;repl_python_run&#34;,
      &#34;file&#34;: &#34;config/Python/Main.sublime-menu&#34;
      }},

      { &#34;keys&#34;: [&#34;ctrl&#43;shift&#43;r&#34;], &#34;command&#34;: &#34;reveal_in_side_bar&#34;},

    // 设置 Sublime REPL 用 F4 打开 R
      { &#34;keys&#34;: [&#34;f4&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: R&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;external_id&#34;: &#34;r&#34;,
      &#34;additional_scopes&#34;: [&#34;tex.latex.knitr&#34;],
      &#34;encoding&#34;: {
      &#34;windows&#34;: &#34;$win_cmd_encoding&#34;,
      &#34;linux&#34;: &#34;utf8&#34;,
      &#34;osx&#34;: &#34;utf8&#34;
      },
      &#34;soft_quit&#34;: &#34;\nquit(save=\&#34;no\&#34;)\n&#34;,
      &#34;cmd&#34;: {&#34;linux&#34;: [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
      &#34;osx&#34;: [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
      &#34;windows&#34;: [&#34;Rterm.exe&#34;, &#34;--ess&#34;, &#34;--encoding=$win_cmd_encoding&#34;]},
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;extend_env&#34;: {&#34;osx&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
      &#34;linux&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
      &#34;windows&#34;: {}},
      &#34;cmd_postfix&#34;: &#34;\n&#34;,
      &#34;suppress_echo&#34;: {&#34;osx&#34;: true,
      &#34;linux&#34;: true,
      &#34;windows&#34;: false},
      &#34;syntax&#34;: &#34;Packages/R/R Console.tmLanguage&#34;
      }
      },

    // 设置 Sublime REPL 用 F5 打开 Rssh
      { &#34;keys&#34;: [&#34;f5&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Rssh&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;external_id&#34;: &#34;r&#34;,
      &#34;additional_scopes&#34;: [&#34;tex.latex.knitr&#34;],
      &#34;encoding&#34;: {
      &#34;windows&#34;: &#34;$win_cmd_encoding&#34;,
      &#34;linux&#34;: &#34;utf8&#34;,
      &#34;osx&#34;: &#34;utf8&#34;
      },
      &#34;soft_quit&#34;: &#34;\nquit(save=\&#34;no\&#34;)\n&#34;,
      &#34;cmd&#34;: {&#34;linux&#34;: [&#34;ssh&#34;,&#34;fl@192.168.1.135&#34;,&#34;-p22&#34;,&#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;],
      &#34;osx&#34;: [&#34;ssh&#34;,&#34;fl@gczhang.imwork.net&#34;, &#34;-p58873&#34;,&#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;]},
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;extend_env&#34;: {&#34;osx&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
      &#34;linux&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
      &#34;windows&#34;: {}},
      &#34;cmd_postfix&#34;: &#34;\n&#34;,
      &#34;suppress_echo&#34;: {&#34;osx&#34;: true,
      &#34;linux&#34;: true,
      &#34;windows&#34;: false},
      &#34;syntax&#34;: &#34;Packages/R/R Console.tmLanguage&#34;
      }
      },

    // 设置 Sublime REPL 用 F6 打开 Rssh
      { &#34;keys&#34;: [&#34;f6&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Rssh&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;external_id&#34;: &#34;r&#34;,
      &#34;additional_scopes&#34;: [&#34;tex.latex.knitr&#34;],
      &#34;encoding&#34;: {
      &#34;windows&#34;: &#34;$win_cmd_encoding&#34;,
      &#34;linux&#34;: &#34;utf8&#34;,
      &#34;osx&#34;: &#34;utf8&#34;
      },
      &#34;soft_quit&#34;: &#34;\nquit(save=\&#34;no\&#34;)\n&#34;,
      &#34;cmd&#34;: {&#34;linux&#34;: [&#34;ssh&#34;,&#34;fl@192.168.1.166&#34;,&#34;-p22&#34;,&#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;],
      &#34;osx&#34;: [&#34;ssh&#34;,&#34;fl@gczhang.imwork.net&#34;, &#34;-p58873&#34;,&#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;]},
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;extend_env&#34;: {&#34;osx&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
      &#34;linux&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
      &#34;windows&#34;: {}},
      &#34;cmd_postfix&#34;: &#34;\n&#34;,
      &#34;suppress_echo&#34;: {&#34;osx&#34;: true,
      &#34;linux&#34;: true,
      &#34;windows&#34;: false},
      &#34;syntax&#34;: &#34;Packages/R/R Console.tmLanguage&#34;
      }
      },

    // 设置 Sublime REPL 用 F1 打开 python
      { &#34;keys&#34;: [&#34;f1&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Python&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;encoding&#34;: &#34;utf8&#34;,
      //&#34;cmd&#34;: [&#34;python&#34;, &#34;-i&#34;, &#34;-u&#34;],
      &#34;cmd&#34;: [&#34;/home/william/anaconda2/bin/python&#34;, &#34;-i&#34;, &#34;-u&#34;],
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;syntax&#34;: &#34;Packages/Python/Python.tmLanguage&#34;,
      &#34;external_id&#34;: &#34;python&#34;,
      &#34;extend_env&#34;: {&#34;PYTHONIOENCODING&#34;: &#34;utf-8&#34;}
      }
      },
    // 设置 Sublime REPL 用 F2 运行 python
      // { &#34;keys&#34;: [&#34;f2&#34;],
      // &#34;caption&#34;: &#34;SublimeREPL: Python - RUN current file&#34;,
      // &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      // {
      // &#34;type&#34;: &#34;subprocess&#34;,
      // &#34;encoding&#34;: &#34;utf8&#34;,
      // &#34;cmd&#34;: [&#34;/home/william/anaconda2/bin/python&#34;, &#34;-u&#34;, &#34;$file_basename&#34;],
      // &#34;cwd&#34;: &#34;$file_path&#34;,
      // &#34;syntax&#34;: &#34;Packages/Python/Python.tmLanguage&#34;,
      // &#34;external_id&#34;: &#34;python&#34;,
      // &#34;extend_env&#34;: {&#34;PYTHONIOENCODING&#34;: &#34;utf-8&#34;}
      // }
      // },

    // 设置 Sublime REPL 用 F2 运行 python_ssh
      { &#34;keys&#34;: [&#34;f2&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: PySSH&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;encoding&#34;: &#34;utf8&#34;,
      &#34;cmd&#34;: {&#34;linux&#34;: [&#34;ssh&#34;,&#34;fl@192.168.1.135&#34;,&#34;-p22&#34;,&#34;python&#34;, &#34;-i&#34;, &#34;-u&#34;]},
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;syntax&#34;: &#34;Packages/Python/Python.tmLanguage&#34;,
      &#34;suppress_echo&#34;: false,
      &#34;external_id&#34;: &#34;python&#34;,
      &#34;extend_env&#34;: {&#34;PYTHONIOENCODING&#34;: &#34;utf-8&#34;},
      &#34;cmd_postfix&#34;: &#34;\n&#34;,
      &#34;suppress_echo&#34;: {&#34;osx&#34;: true,
      &#34;linux&#34;: true,
      &#34;windows&#34;: false}
      }
      },

    // 设置 Sublime REPL 用 F3 运行 python_ssh
      { &#34;keys&#34;: [&#34;f3&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: PySSH&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;encoding&#34;: &#34;utf8&#34;,
      &#34;cmd&#34;: {&#34;linux&#34;: [&#34;ssh&#34;,&#34;fl@192.168.1.166&#34;,&#34;-p22&#34;,&#34;python&#34;, &#34;-i&#34;, &#34;-u&#34;]},
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;syntax&#34;: &#34;Packages/Python/Python.tmLanguage&#34;,
      &#34;suppress_echo&#34;: false,
      &#34;external_id&#34;: &#34;python&#34;,
      &#34;extend_env&#34;: {&#34;PYTHONIOENCODING&#34;: &#34;utf-8&#34;},
      &#34;cmd_postfix&#34;: &#34;\n&#34;,
      &#34;suppress_echo&#34;: {&#34;osx&#34;: true,
      &#34;linux&#34;: true,
      &#34;windows&#34;: false}
      }
      },

      { &#34;keys&#34;: [&#34;ctrl&#43;shift&#43;s&#34;], &#34;command&#34;: &#34;auto_save&#34; },
      {&#34;keys&#34;: [&#34;ctrl&#43;o&#34;], &#34;command&#34;: &#34;toggle_side_bar&#34;},

      // { &#34;keys&#34;: [&#34;ctrl&#43;b&#34;], &#34;command&#34;: &#34;sftp_browse_server&#34; },
      { &#34;keys&#34;: [&#34;ctrl&#43;b&#34;], &#34;command&#34;: &#34;sftp_last_server&#34; },

      { &#34;keys&#34;: [&#34;ctrl&#43;d&#34;], &#34;command&#34;: &#34;find_under_expand&#34; },
    ]


# 注册码

## 网站

由于 `Sublime Text 3` 并非是一款**免费**的编辑器，目前的收费标准是 **$80**。与此同时，也并非强制用户必须购买才能使用，而是**以试用的形式**，经过一段时间后，会时不时的弹出提醒购买的消息框。对此，这里提供了一个**注册码网站**，可以使用其提供的注册码来获取使用权限。具体网址为

&gt; [Sublime Text 3 3143 注册码](https://fatesinger.com/100121)

## 源码

有部分童鞋反馈说上面的网站无法打开，似乎需要爬楼梯才能出去。这里我就勉为其难地做一回纯粹的代码搬运工，把源码放在这里了。各位请自取。

    —– BEGIN LICENSE —–
    TwitterInc
    200 User License
    EA7E-890007
    1D77F72E 390CDD93 4DCBA022 FAF60790
    61AA12C0 A37081C5 D0316412 4584D136
    94D7F7D4 95BC8C1C 527DA828 560BB037
    D1EDDD8C AE7B379F 50C9D69D B35179EF
    2FE898C4 8E4277A8 555CE714 E1FB0E43
    D5D52613 C3D12E98 BC49967F 7652EED2
    9D2D2E61 67610860 6D338B72 5CF95C69
    E36B85CC 84991F19 7575D828 470A92AB
    —— END LICENSE ——







---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-10-13-%E6%88%91%E7%9A%84-sublime-text-%E8%AE%BE%E7%BD%AE/  

