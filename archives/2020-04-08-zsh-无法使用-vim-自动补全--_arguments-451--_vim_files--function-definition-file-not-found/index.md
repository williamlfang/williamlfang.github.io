# zsh 无法使用 vim 自动补全: _arguments:451: _vim_files: function definition file not found


在 zsh 中使用 vim 补全功能时，会出现以下报错：

```bash
_arguments:451: _vim_files: function definition file not found
```

参考 SO 的答疑：[zsh fails at path completition when command is vim](https://unix.stackexchange.com/questions/280622/zsh-fails-at-path-completition-when-command-is-vim)。

解决方法是：

```bash
rm $ZSH_COMPDUMP
## 一定要执行一次
exec zsh
```





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-08-zsh-%E6%97%A0%E6%B3%95%E4%BD%BF%E7%94%A8-vim-%E8%87%AA%E5%8A%A8%E8%A1%A5%E5%85%A8--_arguments-451--_vim_files--function-definition-file-not-found/  

