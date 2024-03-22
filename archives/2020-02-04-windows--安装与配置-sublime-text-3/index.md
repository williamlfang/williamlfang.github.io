# Windows: 安装与配置 Sublime Text 3


# Sublime REPL: 配置

打开 `Preferences/Packages Settings/SublimeREPL/Settings - User`，增加

```bash
{
    // 对于 Windows，需要添加路径
    // 1. R: C:\\Program Files\\R\\R-3.6.2\\bin\\x64
    // 2. cywgin: C:\\cygwin64\\bin
    &#34;default_extend_env&#34;:
        {
            &#34;PATH&#34;: &#34;{PATH};C:\\Program Files\\R\\R-3.6.2\\bin\\x64;C:\\cygwin64\\bin&#34;
        },

    &#34;show_transferred_text&#34;: true
}
```
&lt;!--more--&gt;

&gt; 这里有一个小的提示，在 Windows 操作系统中，如果需要清屏幕，需要使用 `Shift&#43;Ctrl&#43;c` 进行操作。原来在 `Linux` 系统使用 `Ctrl&#43;l`。这个在 `SublimeREPL` 的文档里面有[快捷键说明](https://sublimerepl.readthedocs.io/en/latest/)。以及 StackOverFlow 的提问：[how to clear SublimeREPL window in Sublime 2](https://stackoverflow.com/questions/23831038/how-to-clear-sublimerepl-window-in-sublime-2)

# sftp: 远程编辑文件

`sftp` 提供了内置的连接远程服务器方式，并且可以直接在服务器上面进行编辑。

## 安装 `sftp`

## 添加服务器：

- 进入 `C:\Users\Administrator\AppData\Roaming\Sublime Text 3\Packages\User\sftp_servers`
- 添加文件 `fl@166.sublime-settings`
- 设置服务器连接信息

```bash
{
    // The tab key will cycle through the settings when first created
    // Visit http://wbond.net/sublime_packages/sftp/settings for help

    // sftp, ftp or ftps
    &#34;type&#34;: &#34;sftp&#34;,

    &#34;sync_down_on_open&#34;: true,
    &#34;sync_same_age&#34;: true,

    &#34;host&#34;: &#34;114.67.109.5&#34;,
    &#34;user&#34;: &#34;fl&#34;,
    &#34;password&#34;: &#34;***************&#34;,
    &#34;port&#34;: &#34;6166&#34;,

    &#34;remote_path&#34;: &#34;/home/fl&#34;,
    //&#34;file_permissions&#34;: &#34;664&#34;,
    //&#34;dir_permissions&#34;: &#34;775&#34;,

    //&#34;extra_list_connections&#34;: 0,

    &#34;connect_timeout&#34;: 30,
    //&#34;keepalive&#34;: 120,
    //&#34;ftp_passive_mode&#34;: true,
    //&#34;ftp_obey_passive_host&#34;: false,
    //&#34;ssh_key_file&#34;: &#34;~/.ssh/id_rsa&#34;,
    //&#34;sftp_flags&#34;: [&#34;-F&#34;, &#34;/path/to/ssh_config&#34;],

    //&#34;preserve_modification_times&#34;: false,
    //&#34;remote_time_offset_in_hours&#34;: 0,
    //&#34;remote_encoding&#34;: &#34;utf-8&#34;,
    //&#34;remote_locale&#34;: &#34;C&#34;,
    //&#34;allow_config_upload&#34;: false,
}
```

## 连接服务器

使用 `sftp: browse server` 即可查看服务器上面的文件

![编辑远程文件，并在远程服务器运行 R 脚本程序](/images/2020-02-04-Windows--安装与配置-Sublime-Text-3/sftp.png)

# R: 配置

## 快捷键F5: 本地服务器

打开 `Preferences/ Key Bidings`，增加快捷键用于打开 `R`

```bash
// 使用 快捷键 F5 打开 R,
// 在 windows 的路径需要去查找
    {
        &#34;keys&#34;: [&#34;f5&#34;],
        &#34;caption&#34;: &#34;SublimeREPL: R&#34;,
        &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
            {
                &#34;type&#34;: &#34;subprocess&#34;,
                &#34;external_id&#34;: &#34;r&#34;,
                &#34;additional_scopes&#34;: [&#34;tex.latex.knitr&#34;],
                &#34;encoding&#34;:
                    {
                        &#34;windows&#34;: &#34;$win_cmd_encoding&#34;,
                        &#34;linux&#34;: &#34;utf8&#34;,
                        &#34;osx&#34;: &#34;utf8&#34;
                    },
                &#34;soft_quit&#34;: &#34;\nquit(save=\&#34;no\&#34;)\n&#34;,
                &#34;cmd&#34;:
                    {
                        &#34;linux&#34;: [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
                        &#34;osx&#34;: [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
                        &#34;windows&#34;: [&#34;Rterm.exe&#34;, &#34;--ess&#34;, &#34;--encoding=$win_cmd_encoding&#34;]
                    },
                &#34;cwd&#34;: &#34;$file_path&#34;,
                &#34;extend_env&#34;:
                    {
                        &#34;osx&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
                        &#34;linux&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
                        // 添加 Windows 操作系统下 的 R 路径，记得需要指定 /bin/x64/
                        &#34;windows&#34;: {&#34;PATH&#34;: &#34;{PATH};C:\\Program Files\\R\\R-3.6.2\\bin\\x64\\\\R.exe&#34;}
                    },
                &#34;cmd_postfix&#34;: &#34;\n&#34;,
                &#34;suppress_echo&#34;:
                    {
                        &#34;osx&#34;: true,
                        &#34;linux&#34;: true,
                        &#34;windows&#34;: false
                    },
                &#34;syntax&#34;: &#34;Packages/R/R Console.tmLanguage&#34;
            }
    },
```

## 设置英文界面

参考：[设置R界面语言-- set console / menu language of R](https://d.cosx.org/d/101979-101979)

1. 找到 `Rconsole`，可以到 `C:\Program Files\R\R-3.6.2\etc` 查找
2. 打开 `Rconsole`，然后修改语言选项

    &gt; ## Language for messages
    &gt; language = en

3. 重新启动 `R` 就会发现现在的系统语言变成了英文

## 快捷键F6: 远程连接服务器

我们也可以设置快捷键 `F6` 进行远程连接服务器。

- 需要安装 cywgin，使用 `ssh` 进行登录
- 生成 `ssh-keygen`，文件位置在 `/home/Administrator/.ssh`
- 拷贝 `id_rsa.pub` 到远程服务器的 `~/.ssh/authorized_keys`

接着，我们便可以设置快捷键了

```bash
// 使用 F6 连接远程服务器
    {
        &#34;keys&#34;: [&#34;f6&#34;],
        &#34;caption&#34;: &#34;SublimeREPL: R&#34;,
        &#34;command&#34;:&#34;repl_open&#34;,&#34;args&#34;:
            {
                &#34;type&#34;: &#34;subprocess&#34;,
                &#34;external_id&#34;: &#34;r&#34;,
                &#34;additional_scopes&#34;: [&#34;tex.latex.knitr&#34;],
                &#34;encoding&#34;:
                    {
                        &#34;windows&#34;: &#34;$win_cmd_encoding&#34;,
                        &#34;linux&#34;: &#34;utf8&#34;,
                        &#34;osx&#34;: &#34;utf8&#34;
                    },
                &#34;soft_quit&#34;: &#34;\nquit(save=\&#34;no\&#34;)\n&#34;,
                &#34;cmd&#34;:
                    {
                        &#34;linux&#34;:
                            [
                                &#34;ssh&#34;,
                                &#34;-L&#34;, &#34;4321:localhost:4321&#34;,
                                &#34;fl@114.67.109.5&#34;, &#34;-p6166&#34;,
                                &#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;
                            ],
                        &#34;osx&#34;: [&#34;R&#34;, &#34;--interactive&#34;, &#34;--no-readline&#34;],
                        &#34;windows&#34;:
                            [
                                &#34;ssh&#34;,
                                &#34;-L&#34;, &#34;4321:localhost:4321&#34;,
                                &#34;fl@114.67.109.5&#34;, &#34;-p6166&#34;,
                                &#34;R&#34;,&#34;--interactive&#34;, &#34;--no-readline&#34;,
                                 &#34;--encoding=$win_cmd_encoding&#34;
                            ]
                    },
                &#34;cwd&#34;: &#34;$file_path&#34;,
                &#34;extend_env&#34;:
                    {
                        &#34;osx&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
                        &#34;linux&#34;: {&#34;PATH&#34;: &#34;{PATH}:/usr/local/bin&#34;},
                        // 需要把 cygwin 路径添加到这里
                        &#34;windows&#34;: {&#34;PATH&#34;: &#34;{PATH};C:\\cygwin64\\bin&#34;}
                    },
                &#34;cmd_postfix&#34;: &#34;\n&#34;,
                &#34;suppress_echo&#34;:
                    {
                        &#34;osx&#34;: true,
                        &#34;linux&#34;: true,
                        &#34;windows&#34;: true
                    },
                &#34;syntax&#34;: &#34;Packages/R/R Console.tmLanguage&#34;
            }
    },
```

# Windows 无法传送命令的问题

在 Windows 操作系统中，有一个问题，我现在还是没有很好的方法，只能提供一个权宜之计：

&gt; 有时候，打开 SublimeREPL，却无法发送代码到解释器。

这个有可能是 Window 在处理信号的时候，找不到 Sublime。

我现在的做法是：

- 先使用 `kill` 杀死进程
- 然后在重新 `restart` 一个进程

可以设置快捷键如下 `F1` -&gt; `F12`

```json
  // 使用 Sublime REPL  F1 先杀死 python
  // F1:kill
  { &#34;keys&#34;: [&#34;f1&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Kill&#34;,
      &#34;command&#34;: &#34;repl_kill&#34;, &#34;caption&#34;: &#34;Kill&#34;
  },
  // F12:restart
  { &#34;keys&#34;: [&#34;f12&#34;],
      &#34;caption&#34;: &#34;SublimeREPL: Restart&#34;,
      &#34;command&#34;: &#34;repl_restart&#34;, &#34;caption&#34;: &#34;Restart&#34;
  },
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-02-04-windows--%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE-sublime-text-3/  

