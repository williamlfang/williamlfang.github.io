# Unix编程


`Unix`/`Linux` 编程实践，主要为实际生产过程中经常使用的**命令行以及简单的执行任务的程序脚本**。
&lt;!--more--&gt;

![Unix](/images/UNIX HD Wallpaper.png)

# `Unix` 常用命令行

-----

## 用户管理

### 用户权限

- `root`：超级权限，是系统的管理员
- `sudo su`：允许当前用户使用系统管理员权限，主要是修改系统相关配置、安装软件包等
- 增加用户：`sudo adduser`

### 修改文件权限

- `chmod &#43;x file.sh`：给予文件可执行权限

-----

## 文件操作

### `cd`
指向文件路径
    
- `cd ~` / `cd `：这指向当前用户的主目录 `/home/you`
- `cd ..`：返回上一级父目录

### `pwd`
打印/显示*当前绝对路径*

### `ls`
显示当前目录下的文件

- `-a`：等同于 `ll`，显示所有的文件，包含隐藏的文件
- `-h`：显示文件大小

```bash
Usage: ls [OPTION]... [FILE]...
List information about the FILEs (the current directory by default).
Sort entries alphabetically if none of -cftuvSUX nor --sort.

Mandatory arguments to long options are mandatory for short options too.
  -a, --all                  do not ignore entries starting with .
  -A, --almost-all           do not list implied . and ..
      --author               with -l, print the author of each file
  -b, --escape               print octal escapes for nongraphic characters
      --block-size=SIZE      use SIZE-byte blocks.  See SIZE format below
  -B, --ignore-backups       do not list implied entries ending with ~
  -c                         with -lt: sort by, and show, ctime (time of last
                               modification of file status information)
                               with -l: show ctime and sort by name
                               otherwise: sort by ctime
  -C                         list entries by columns
      --color[=WHEN]         colorize the output.  WHEN defaults to `always&#39;
                               or can be `never&#39; or `auto&#39;.  More info below
  -d, --directory            list directory entries instead of contents,
                               and do not dereference symbolic links
  -D, --dired                generate output designed for Emacs&#39; dired mode
  -f                         do not sort, enable -aU, disable -ls --color
  -F, --classify             append indicator (one of */=&gt;@|) to entries
      --file-type            likewise, except do not append `*&#39;
      --format=WORD          across -x, commas -m, horizontal -x, long -l,
                               single-column -1, verbose -l, vertical -C
      --full-time            like -l --time-style=full-iso
  -g                         like -l, but do not list owner
      --group-directories-first
                             group directories before files.
                               augment with a --sort option, but any
                               use of --sort=none (-U) disables grouping
  -G, --no-group             in a long listing, don&#39;t print group names
  -h, --human-readable       with -l, print sizes in human readable format
                               (e.g., 1K 234M 2G)
      --si                   likewise, but use powers of 1000 not 1024
  -H, --dereference-command-line
                             follow symbolic links listed on the command line
      --dereference-command-line-symlink-to-dir
                             follow each command line symbolic link
                             that points to a directory
      --hide=PATTERN         do not list implied entries matching shell PATTERN
                               (overridden by -a or -A)
      --indicator-style=WORD  append indicator with style WORD to entry names:
                               none (default), slash (-p),
                               file-type (--file-type), classify (-F)
  -i, --inode                print the index number of each file
  -I, --ignore=PATTERN       do not list implied entries matching shell PATTERN
  -k                         like --block-size=1K
  -l                         use a long listing format
  -L, --dereference          when showing file information for a symbolic
                               link, show information for the file the link
                               references rather than for the link itself
  -m                         fill width with a comma separated list of entries
  -n, --numeric-uid-gid      like -l, but list numeric user and group IDs
  -N, --literal              print raw entry names (don&#39;t treat e.g. control
                               characters specially)
  -o                         like -l, but do not list group information
  -p, --indicator-style=slash
                             append / indicator to directories
  -q, --hide-control-chars   print ? instead of non graphic characters
      --show-control-chars   show non graphic characters as-is (default
                             unless program is `ls&#39; and output is a terminal)
  -Q, --quote-name           enclose entry names in double quotes
      --quoting-style=WORD   use quoting style WORD for entry names:
                               literal, locale, shell, shell-always, c, escape
  -r, --reverse              reverse order while sorting
  -R, --recursive            list subdirectories recursively
  -s, --size                 print the allocated size of each file, in blocks
  -S                         sort by file size
      --sort=WORD            sort by WORD instead of name: none -U,
                             extension -X, size -S, time -t, version -v
      --time=WORD            with -l, show time as WORD instead of modification
                             time: atime -u, access -u, use -u, ctime -c,
                             or status -c; use specified time as sort key
                             if --sort=time
      --time-style=STYLE     with -l, show times using style STYLE:
                             full-iso, long-iso, iso, locale, &#43;FORMAT.
                             FORMAT is interpreted like `date&#39;; if FORMAT is
                             FORMAT1&lt;newline&gt;FORMAT2, FORMAT1 applies to
                             non-recent files and FORMAT2 to recent files;
                             if STYLE is prefixed with `posix-&#39;, STYLE
                             takes effect only outside the POSIX locale
  -t                         sort by modification time
  -T, --tabsize=COLS         assume tab stops at each COLS instead of 8
  -u                         with -lt: sort by, and show, access time
                               with -l: show access time and sort by name
                               otherwise: sort by access time
  -U                         do not sort; list entries in directory order
  -v                         natural sort of (version) numbers within text
  -w, --width=COLS           assume screen width instead of current value
  -x                         list entries by lines instead of by columns
  -X                         sort alphabetically by entry extension
  -1                         list one file per line

SELinux options:

  --lcontext                 Display security context.   Enable -l. Lines
                             will probably be too wide for most displays.
  -Z, --context              Display security context so it fits on most
                             displays.  Displays only mode, user, group,
                             security context and file name.
  --scontext                 Display only security context and file name.
      --help     display this help and exit
      --version  output version information and exit

SIZE may be (or may be an integer optionally followed by) one of following:
KB 1000, K 1024, MB 1000*1000, M 1024*1024, and so on for G, T, P, E, Z, Y.

Using color to distinguish file types is disabled both by default and
with --color=never.  With --color=auto, ls emits color codes only when
standard output is connected to a terminal.  The LS_COLORS environment
variable can change the settings.  Use the dircolors command to set it.
```

### `du`
显示文件夹小小：

- `-h`
- `--max-depth=1`:显示当前文件夹占用的磁盘空间
- `du -h ./file_path/ --max-depth=0`：显示当前文件夹的占用磁盘空间大小
    
```bash
Usage: du [OPTION]... [FILE]...
  or:  du [OPTION]... --files0-from=F
Summarize disk usage of each FILE, recursively for directories.

Mandatory arguments to long options are mandatory for short options too.
  -a, --all             write counts for all files, not just directories
      --apparent-size   print apparent sizes, rather than disk usage; although
                          the apparent size is usually smaller, it may be
                          larger due to holes in (`sparse&#39;) files, internal
                          fragmentation, indirect blocks, and the like
  -B, --block-size=SIZE  use SIZE-byte blocks
  -b, --bytes           equivalent to `--apparent-size --block-size=1&#39;
  -c, --total           produce a grand total
  -D, --dereference-args  dereference only symlinks that are listed on the
                          command line
      --files0-from=F   summarize disk usage of the NUL-terminated file
                          names specified in file F;
                          If F is - then read names from standard input
  -H                    equivalent to --dereference-args (-D)
  -h, --human-readable  print sizes in human readable format (e.g., 1K 234M 2G)
      --si              like -h, but use powers of 1000 not 1024
  -k                    like --block-size=1K
  -l, --count-links     count sizes many times if hard linked
  -m                    like --block-size=1M
  -L, --dereference     dereference all symbolic links
  -P, --no-dereference  don&#39;t follow any symbolic links (this is the default)
  -0, --null            end each output line with 0 byte rather than newline
  -S, --separate-dirs   do not include size of subdirectories
  -s, --summarize       display only a total for each argument
  -x, --one-file-system    skip directories on different file systems
  -X, --exclude-from=FILE  exclude files that match any pattern in FILE
      --exclude=PATTERN    exclude files that match PATTERN
      --max-depth=N     print the total for a directory (or file, with --all)
                          only if it is N or fewer levels below the command
                          line argument;  --max-depth=0 is the same as
                          --summarize
      --time            show time of the last modification of any file in the
                          directory, or any of its subdirectories
      --time=WORD       show time as WORD instead of modification time:
                          atime, access, use, ctime or status
      --time-style=STYLE  show times using style STYLE:
                          full-iso, long-iso, iso, &#43;FORMAT
                          FORMAT is interpreted like `date&#39;
      --help     display this help and exit
      --version  output version information and exit

Display values are in units of the first available SIZE from --block-size,
and the DU_BLOCK_SIZE, BLOCK_SIZE and BLOCKSIZE environment variables.
Otherwise, units default to 1024 bytes (or 512 if POSIXLY_CORRECT is set).
```

### `tree`
以树形显示当前目录下的文件结构

- `-L 0-9`：需要显示的级别数量

### `rm` 
删除文件

- `-r`：以递归形式删除指定目录下的所有文件 
- `-f`：系统不会发出询问，直接删除，**谨慎使用**

-----

# `shell` 编程

## 文件表头

最好在文件表头添加：

```bash
#!/bin/bash
```

## 执行文件

需要通过 **增加执行权限**：

```bash
chmod &#43;x file.sh
./file.sh
```

## 获取变量

变量赋值使用 `=` 时，不能有空格！！！

```bash
v=$(date &#43;&#34;%Y-%m-%d %M:%H:%S&#34;)
echo $v

## 也可以使用 `{}` 把变量包围起来
echo ${v}

## 使用 `-e` 增加 `echo` 转义字符
echo -e &#34;\n Hello, world! \n&#34;
```

## 日期格式命名的文件

- 使用 `&#43;` 来拼接
- 使用 `-d &#34;1 days&#34;` 来增加或者 `-d &#34;-1 days&#34;`减少日期

```bash
dataFile=$(date -d &#34;-$i days&#34; &#43;&#34;%Y%m%d&#34;)

echo $dataFile
```

## `for` 循环

```bash
for colo in XiFu YY1;
do
    for info in ContractInfo TickData;
    do 
        for i in {1..0}
        do
        dataFile=$(date -d &#34;-$i days&#34; &#43;&#34;%Y%m%d.csv&#34;)
        echo -e &#34;\n$colo :==&gt; $info :==&gt; $dataFile&#34;
        done
    done
done
```







---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-09-29-unix%E7%BC%96%E7%A8%8B/  

