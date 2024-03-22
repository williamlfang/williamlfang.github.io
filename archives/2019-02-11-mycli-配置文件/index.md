# mycli 配置文件


&lt;!--more--&gt;

# 安装

因为是一个 `Python` 扩展，因此我们可以直接使用 `pip` 来安装

```bash
pip install mycli
```

安装完成后，即可享受轻松写 `mysql` 代码了。

# 用法

可以直接在终端使用该程序

```bash
mycli -h 192.168.1.188  -P 3306 -u trader -p ******
```

其中：

- `-h` 是需要运行 `mysql` 命令的服务器 IP 地址。很显然，`mycli` 不仅允许我们连接本地数据库，还可以让我们通过本地终端，轻松连接到远程服务器，进行数据库的「增删改查」操作。
- `-P` 注意是大写的，即 `mysql` 数据库的端口，一般默认是 `3306`。
- `-u` 用户名
- `-p` 注意是小写的，也可以不用在这一步明文输入，而是以交互的形式来操作，保证账户安全。

![使用](/images/2019-02-11-mycli-配置文件/mycli_01.gif)

当然，我们也可以使用短命令的启动，以后就可以直接在终端使用 `mysql@188` 来调用 `mycli` 用以连接数据库了

```bash
alias mysql@188=&#39;mycli -h 192.168.1.188  -P 3306 -u trader -p ******&#39;
```



# 配置

当然，我们今天的主题是如何配置 `mycli` 以符合我们的使用习惯。

![使用](/images/2019-02-11-mycli-配置文件/mycli_02.gif)

`mycli` 配置文件在 `~/.myclirc` ，可以根据需要进行相应的修改与设置，比如字体颜色、自动补全、键盘使用习惯(Emacs vs Vi/Vim)。

```bash
# vi: ft=dosini
[main]

# Enables context sensitive auto-completion. If this is disabled the all
# possible completions will be listed.
smart_completion = True

# Multi-line mode allows breaking up the sql statements into multiple lines. If
# this is set to True, then the end of the statements must have a semi-colon.
# If this is set to False then sql statements can&#39;t be split into multiple
# lines. End of line (return) is considered as the end of the statement.
multi_line = False

# Destructive warning mode will alert you before executing a sql statement
# that may cause harm to the database such as &#34;drop table&#34;, &#34;drop database&#34;
# or &#34;shutdown&#34;.
destructive_warning = True

# log_file location.
log_file = ~/.mycli.log

# Default log level. Possible values: &#34;CRITICAL&#34;, &#34;ERROR&#34;, &#34;WARNING&#34;, &#34;INFO&#34;
# and &#34;DEBUG&#34;. &#34;NONE&#34; disables logging.
log_level = INFO

# Log every query and its results to a file. Enable this by uncommenting the
# line below.
# audit_log = ~/.mycli-audit.log

# Timing of sql statments and table rendering.
timing = True

# Table format. Possible values: psql, plain, simple, grid, fancy_grid, pipe,
# orgtbl, rst, mediawiki, html, latex, latex_booktabs, tsv.
# Recommended: psql, fancy_grid and grid.
table_format = fancy_grid

# Syntax coloring style. Possible values (many support the &#34;-dark&#34; suffix):
# manni, igor, xcode, vim, autumn, vs, rrt, native, perldoc, borland, tango, emacs,
# friendly, monokai, paraiso, colorful, murphy, bw, pastie, paraiso, trac, default,
# fruity.
# Screenshots at http://mycli.net/syntax
# syntax_style = default
syntax_style = monokai

# Keybindings: Possible values: emacs, vi.
# Emacs mode: Ctrl-A is home, Ctrl-E is end. All emacs keybindings are available in the REPL.
# When Vi mode is enabled you can use modal editing features offered by Vi in the REPL.
key_bindings = emacs

# Enabling this option will show the suggestions in a wider menu. Thus more items are suggested.
wider_completion_menu = False

# MySQL prompt
# \t - Product type (Percona, MySQL, Mariadb)
# \u - Username
# \h - Hostname of the server
# \d - Database name
# \n - Newline
prompt = &#39;\t \u@\h:\d&gt; &#39;
prompt_continuation = &#39;-&gt; &#39;

# Skip intro info on startup and outro info on exit
# less_chatty = False
less_chatty = True

# Use alias from --login-path instead of host name in prompt
login_path_as_host = False

# Custom colors for the completion menu, toolbar, etc.
[colors]
# Completion menus.
## 选中的颜色
# Token.Menu.Completions.Completion.Current = &#39;bg:#00aaaa #000000&#39;
Token.Menu.Completions.Completion.Current = &#39;bg:#6A5ACD #aaffff&#39;
## 备选的颜色
Token.Menu.Completions.Completion = &#39;bg:#ebdbb2 #000000&#39;

# Token.Menu.Completions.MultiColumnMeta = &#39;bg:#aaffff #000000&#39;
Token.Menu.Completions.MultiColumnMeta = &#39;bg:#d79921 #000000&#39;
Token.Menu.Completions.ProgressButton = &#39;bg:#003333&#39;
Token.Menu.Completions.ProgressBar = &#39;bg:#00aaaa&#39;

# Selected text.
Token.SelectedText = &#39;#ffffff bg:#6666aa&#39;

# Search matches. (reverse-i-search)
Token.SearchMatch = &#39;#ffffff bg:#4444aa&#39;
Token.SearchMatch.Current = &#39;#ffffff bg:#44aa44&#39;

# The bottom toolbar.
Token.Toolbar = &#39;bg:#222222 #aaaaaa&#39;
Token.Toolbar.Off = &#39;bg:#222222 #888888&#39;
Token.Toolbar.On = &#39;bg:#222222 #ffffff&#39;

# Search/arg/system toolbars.
Token.Toolbar.Search = &#39;noinherit bold&#39;
Token.Toolbar.Search.Text = &#39;nobold&#39;
Token.Toolbar.System = &#39;noinherit bold&#39;
Token.Toolbar.Arg = &#39;noinherit bold&#39;
Token.Toolbar.Arg.Text = &#39;nobold&#39;

# Favorite queries.
[favorite_queries]
```



​


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-02-11-mycli-%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6/  

