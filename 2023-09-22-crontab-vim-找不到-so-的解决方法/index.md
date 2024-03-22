# crontab vim 找不到 so 的解决方法


报错

```bash
crontab -e                                                                                                                                                                                                                                                                                                                                                 [08:40:07]
vim: error while loading shared libraries: libpython3.9.so.1.0: cannot open shared object file: No such file or directory
crontab: &#34;vim&#34; exited with status 127
```

这是因为 `vim` 编译的时候使用了动态库 `libpython3.9.so.1.0`，需要拷贝一份到

- `/usr/lib`
- `/usr/lib64`

```bash
cp /home/ops/vim9/local/lib/libpython3.9.so.1.0 /usr/lib
cp /home/ops/vim9/local/lib/libpython3.9.so.1.0 /usr/lib64
```

如果没有 `root` 权限，则可以通过 `alias` 来设置 `crontab` 命令

```bash
alias crontab=&#34;export VISUAL=&#39;export VIMRUNTIME=$HOME/vim9/local/share/vim/vim90; LD_LIBRARY_PATH=$HOME/vim9/local/lib:$LD_LIBRARY_PATH PATH=$HOME/vim9/local/bin:$HOME/vim9/local/node-v16.20.0-linux-x64/bin:$PATH $HOME/vim9/local/bin/vim -u $HOME/vim9/.vimrc&#39;; crontab&#34;
alias crontab=&#34;export VISUAL=nvim; crontab&#34;
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-09-22-crontab-vim-%E6%89%BE%E4%B8%8D%E5%88%B0-so-%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/  

