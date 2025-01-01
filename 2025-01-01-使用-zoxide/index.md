# 使用 zoxide


`zoxide` 是一款类比 `cd` 的目录导航工具，但是提供了基于使用频率的快速跳转功能。

{{&lt; youtube aghxkpyRVDY &gt;}}

&lt;!--more--&gt;

## 安装

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

默认安装在 `~/.local/bin/zoxide`

```bash
total 1.3M
drwxrwxr-x 2 william william 4.0K Jan  1 12:26 .
drwxrwxr-x 7 william william 4.0K Mar 13  2024 ..
-rwxr-xr-x 1 william william 1.2M Jan  1 12:26 zoxide

## clear .zcompdump
rm ~/.zcompdump*; compinit

which z

z () {
    __zoxide_z &#34;$@&#34;
}
```

## 配置

```
##=============================================================================
## zoxide
export PATH=/home/william/.local/bin:$PATH
eval &#34;$(zoxide init --cmd cd zsh)&#34;
```

这里，我使用了 `cd` 替代 `z`，使得 `z` 依然保留其他的快捷键。

使用 `cd path` 进行跳转

```bash
which cd
cd () {
    __zoxide_z &#34;$@&#34;
}
```

同时，还可以使用 `cdi` 进行交互式的操作。

## zsh-z

需要注意的，如果使用 `zsh` 安装了 `zsh-z`，可能导致 `z` 命令冲突，这时候需要从 `~/.zshrc`   去掉

```zsh
## z vs autojump vs zoxide
# zinit light agkozak/zsh-z
```

## 使用技巧

- 使用 `z abs &lt;space&gt;&lt;Tab&gt;` 进行补全
- `zoxide add`
- `zoxide remove`
- `zoxide query`
- `zoxide edit` 可以进行编辑操作(add, detele)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-01-%E4%BD%BF%E7%94%A8-zoxide/  

