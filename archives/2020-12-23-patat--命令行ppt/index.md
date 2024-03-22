# patat: 命令行ppt


[patat](https://github.com/jaspervdj/patat#evaluating-code) 是一款比较符合极客风格的课件制作工具。



# 安装



## 安装 stack

```bash
curl -sSL https://get.haskellstack.org/ | sh
```

## 安装 patat

```bash
git clone git@github.com:jaspervdj/patat.git
cd patat
stack setup
stack install

## Make sure $HOME/.local/bin is in your $PATH

patat v0.8.6.1

Usage: patat [FILENAME] [-w|--watch]
  Terminal-based presentations using Pandoc

  Controls:
  - Next slide:             space, enter, l, right, pagedown
  - Previous slide:         backspace, h, left, pageup
  - Go forward 10 slides:   j, down
  - Go backward 10 slides:  k, up
  - First slide:            0
  - Last slide:             G
  - Jump to slide N:        N followed by enter
  - Reload file:            r
  - Quit:                   q

Available options:
  -h,--help                Show this help text
  FILENAME                 Input file
  -f,--force               Force ANSI terminal
  -d,--dump                Just dump all slides and exit
  -w,--watch               Watch file for changes
  --version                Display version info and exit
```



# 使用

```bash
cd /home/william/workspace/patat

cd tests/golden/inputs
patat -w syntax.md
```



常用选项:

- `-w`：可以实时查看效果

- `-f`：忽略 ANSI 不支持的问题



控制：

- **Next slide**: `space`, `enter`, `l`, `→`, `PageDown`
- **Previous slide**: `backspace`, `h`, `←`, `PageUp`
- **Go forward 10 slides**: `j`, `↓`
- **Go backward 10 slides**: `k`, `↑`
- **First slide**: `0`
- **Last slide**: `G`
- **Jump to slide N**: `N` followed by `enter`
- **Reload file**: `r`
- **Quit**: `q`



# 效果



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-12-23-patat--%E5%91%BD%E4%BB%A4%E8%A1%8Cppt/  

