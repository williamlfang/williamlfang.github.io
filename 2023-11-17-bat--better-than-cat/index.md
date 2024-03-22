# bat: better than cat



## 安装

```bash
## CentOS
wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
tar -xvf bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz
cd bat-v0.24.0-x86_64-unknown-linux-gnu

cp ./bat ~/local/bin
```

&lt;!--more--&gt;

## 设置

```bash
## cat
alias cat=&#39;~/local/bin/bat --style=plain&#39;
## help
alias bathelp=&#39;bat --plain --language=help&#39;
help() {
    &#34;$@&#34; --help 2&gt;&amp;1 | bathelp
}
alias -g -- -h=&#39;-h 2&gt;&amp;1 | bat --language=help --style=plain&#39;
alias -g -- --help=&#39;--help 2&gt;&amp;1 | bat --language=help --style=plain&#39;
## tail -f
taillog() {
    tail -f $1 | bat --paging=never -l log
}
## fzf
alias fzfx=&#39;fzf --preview &#34;bat --color=always --style=numbers --line-range=:500 {}&#34;&#39;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-11-17-bat--better-than-cat/  

