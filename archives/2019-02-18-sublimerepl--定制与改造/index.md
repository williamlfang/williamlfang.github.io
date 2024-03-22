# SublimeREPL: 定制与改造


`Sublime` 是一款提供了可自定义的强大**编辑器**。我们可以根据个人的使用习惯，通过修改相应的参数配置，就可以搭建一个得心应手的编程环境。

&lt;!--more--&gt;

对于现代（c以后）的解释型编程语言，基本上都是支持 `REPL` 的，即 `read-evalue-print-loop`^[[wiki:read-evalue-print-loop](https://www.wikiwand.com/en/Read–eval–print_loop)，这些语言包括：APL、BASIC、Clojure、F#、Haskell、J、Julia、Perl、PHP、Prolog、Python、R、Ruby、Scala、Smalltalk、Standard ML、Swift、Tcl、Javascript、Java这样的编程语言所拥有的类似的编程环境。]，简单来说，就是可以在源文件与解释器之间进行实时的交互。这一点尤其是对于数据分析工作意义重大。一般而言，我们使用 `R` 或则 `python` 対数据进行探索性分析时，往往需要在程序与结果之间进行多次的交互分析，通过程序来查看结果，同时又通过结果来修改程序。很难想象如果没有 `REPL` 的支持，仅凭借编译语言，每次修改程序后都需要重新编译、执行，工作量是多么的巨大。

而做为一款现代的、优秀的编辑器，`Sublime Text` 当然夜提供了支持 `REPL` 的功能了。通过安装相关的插件，并设置一定的参数，我们便可以把 `sublime` 改造成为一个称心如意的数据分析套件了。

# 安装插件

可以通过调用 `shift&#43;ctrl&#43;p` 来安装需要的插件：

-   `SublimeREPl`：支持 `REPL` 交互
-   `SendCode`：发送代码到 `SublimeREPL`

安装完成后，我们可以在 `sublime` 的菜单中，打开 `Preferences -&gt; Browse Packages` 查看已安装的插件，这也是后面改造插件的配置文件所在。

# 改造

下面，我们一步步地完成対 `SublimeREPL` 进行改造。

## 执行终端显示代码

可以在执行的终端显示已发送的代码。打开 `Preference -&gt; Package Setting`，然后找到 `SublimeREPL`，打开 `Settigns-User`：

```bash
{
	&#34;show_transferred_text&#34;: true,
}
```

这样，我们便可以在终端看到已经执行了哪些代码。

## 修改快捷键

可以配置快捷键，用于打开特定的编程环境，如 `R`、`python`。同时，我们还可以通过 `ssh` 直接连接到远程服务器，实现在本地编辑器修改源文件、在远程服务器执行代码。

打开 `Preference -&gt; Key Bindings`

### R 编程

-   local machine

    ```bash
    // 使用 F5 打开 本地R
      { &#34;keys&#34;: [&#34;f5&#34;],
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
      &#34;cmd&#34;: {
            &#34;linux&#34;: [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
            &#34;osx&#34;:   [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
            &#34;windows&#34;: [&#34;Rterm.exe&#34;, &#34;--ess&#34;, &#34;--encoding=$win_cmd_encoding&#34;]
            },
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
    ```



-   remote server

    ```bash
    // 使用 F6 打开 远程R
      { &#34;keys&#34;: [&#34;f6&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Rssh135&#34;,
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
      &#34;cmd&#34;: {
        &#34;linux&#34;: [&#34;ssh&#34;,&#34;fl@192.168.1.135&#34;,&#34;-p22&#34;,&#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;],
        &#34;osx&#34;:   [&#34;ssh&#34;,&#34;fl@gczhang.imwork.net&#34;, &#34;-p58873&#34;,&#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;]
            },
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
    ```



### python 编程

-   `python2`

    ```bash
    // 使用 F2 打开 本地python2
      { &#34;keys&#34;: [&#34;f2&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Python2&#34;,
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
    ```



-   `python3`

    ```bash
    // 使用 F3 打开 本地python3
      { &#34;keys&#34;: [&#34;f3&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Python3&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;encoding&#34;: &#34;utf8&#34;,
      //&#34;cmd&#34;: [&#34;python&#34;, &#34;-i&#34;, &#34;-u&#34;],
      &#34;cmd&#34;: [&#34;/home/william/anaconda3/bin/python&#34;, &#34;-i&#34;, &#34;-u&#34;],
      &#34;cwd&#34;: &#34;$file_path&#34;,
      &#34;syntax&#34;: &#34;Packages/Python/Python.tmLanguage&#34;,
      &#34;external_id&#34;: &#34;python&#34;,
      &#34;extend_env&#34;: {&#34;PYTHONIOENCODING&#34;: &#34;utf-8&#34;}
      }
      },
    ```

- 远程 `python`

    ```bash
    // 使用 F4 打开 远程python2
      { &#34;keys&#34;: [&#34;f4&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: PySSH166&#34;,
      &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
      {
      &#34;type&#34;: &#34;subprocess&#34;,
      &#34;encoding&#34;: &#34;utf8&#34;,
      &#34;cmd&#34;: {&#34;linux&#34;: [&#34;ssh&#34;,&#34;fl@192.168.1.166&#34;,&#34;-p22&#34;,&#34;python2&#34;, &#34;-i&#34;, &#34;-u&#34;]},
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
    ```

### repl-restart

对于一个完整的分析项目，我们有时候想重启终端，以便查看修改后的程序是否依然能完整的运行。这个可以通过调用 `shift-ctrl-p` 来实现

![](/images/2019-02-18-SublimeREPL--定制与改造/repl-restart.gif)

当然，这个略显笨拙，尤其是对于一个需要多次重启的过程，十分的耗费时间与精力。做为一个「懒惰」的程序员，当然需要一键搞定全过程了。

-   我们可以找到 `~/.config/sublime-text-3/Packages/SublimeREPL`，查看 `repl:restart` 是由 `Context.sublime-menu` 控制

    ```bash
    vim ~/.config/sublime-text-3/Packages/SublimeREPL/Context.sublime-menu

    [
    	{&#34;caption&#34;: &#34;-&#34;},
        {&#34;command&#34;: &#34;repl_kill&#34;, &#34;caption&#34;: &#34;Kill&#34;},
    	{&#34;command&#34;: &#34;repl_restart&#34;, &#34;caption&#34;: &#34;Restart&#34;},
    	{&#34;command&#34;: &#34;subprocess_repl_send_signal&#34;, &#34;caption&#34;: &#34;Send other SIGNAL&#34;}
    ]
    ```

- 既然这样，我们就可以设置一个快捷键来映射这个命令

    ```bash
    // 使用 F12 实现 repl:restart 功能
      { &#34;keys&#34;: [&#34;f12&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Restart&#34;,
      &#34;command&#34;: &#34;repl_restart&#34;, &#34;caption&#34;: &#34;Restart&#34;
      },
    ```

- 同时，我们还观察到每次重启终端后，都会有窗口询问是否确定需要关闭。这个其实也是冗余的操作，同样可以去掉。找到 `~/.config/sublime-text-3/Packages/SublimeREPL/sublimerepl.py`，这是控制整个插件的核心功能模块。找到

    ```bash
    def restart(self, view, edit):
        repl_restart_args = view.settings().get(&#34;repl_restart_args&#34;)
        if not repl_restart_args:
            sublime.message_dialog(&#34;No restart parameters found&#34;)
            return False
        ## ---------------------------------------------------------------------
        rv = self.repl_view(view)
        if rv:
            if rv.repl and rv.repl.is_alive() and not sublime.ok_cancel_dialog(&#34;Still running. Really restart?&#34;):
                return False
            rv.on_close()  # yes on_close, delete rv from
        ## ---------------------------------------------------------------------

        view.insert(edit, view.size(), RESTART_MSG)
        repl_restart_args[&#34;view_id&#34;] = view.id()
        self.open(view.window(), **repl_restart_args)
        return True
    ```

    可以看到，其实询问的窗口是一个 `rv = self.repl_view(view)` 的对象。我们直接把这个注释掉，以后每次重启终端就不会再有提示了。

    ```bash
    def restart(self, view, edit):
        repl_restart_args = view.settings().get(&#34;repl_restart_args&#34;)
        if not repl_restart_args:
            sublime.message_dialog(&#34;No restart parameters found&#34;)
            return False
        ## ---------------------------------------------------------------------
        # rv = self.repl_view(view)
        # if rv:
        #     if rv.repl and rv.repl.is_alive() and not sublime.ok_cancel_dialog(&#34;Still running. Really restart?&#34;):
        #         return False
        #     rv.on_close()  # yes on_close, delete rv from
        ## ---------------------------------------------------------------------

        view.insert(edit, view.size(), RESTART_MSG)
        repl_restart_args[&#34;view_id&#34;] = view.id()
        self.open(view.window(), **repl_restart_args)
        return True
    ```

    再次运行 `F12`，确实是没有提示了，直接重启终端。

    ![](/images/2019-02-18-SublimeREPL--定制与改造/repl-f12.gif)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-02-18-sublimerepl--%E5%AE%9A%E5%88%B6%E4%B8%8E%E6%94%B9%E9%80%A0/  

