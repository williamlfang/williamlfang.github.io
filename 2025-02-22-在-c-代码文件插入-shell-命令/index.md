# 在 c 代码文件插入 shell 命令


今天看到一个帖子：[Just realized you can put shell script inside c source files](https://www.reddit.com/r/C_Programming/comments/1iuvu0f/just_realized_you_can_put_shell_script_inside_c/)，想到以前有个朋友也是这么使用 `c`，觉得挺神奇的。

这个是在 `c` 源代码文件，使用 `macro` 宏定义一组 `shell` 命令，然后再退出 `shell`，这样就不会在继续执行真正的 `c` 代码了。这样做的好处是可以使用一个命令 `sh main.c` 即可快速运行可执行文件，对于一些简单部署的任务比较方便。

```c
#if 0
cc -o /tmp/app main.c
/tmp/app
exit # required, otherwise sh will try to interpret the C code below
#endif

#include &lt;stdio.h&gt;

int main(void)
{
    printf(&#34;quick script\n&#34;);
    return 0;
}
```

```bash
sh main.c

quick script
```

&lt;!--more--&gt;
&gt; This is called a Polyglot and it&#39;s possible to get more than just 2 languages in one file

[Polyglot](https://www.wikiwand.com/en/articles/Polyglot_(computing))

在这个帖子的回复评论里，可以找到其他实际的工程使用例子：

- [ ] [libmemory.c](https://github.com/skeeto/w64devkit/blob/master/src/libmemory.c)
- [ ] [libchkstk.S](https://github.com/skeeto/w64devkit/blob/master/src/libchkstk.S)
- [ ] [libregex.c](https://github.com/skeeto/w64devkit/blob/master/contrib/libregex.c)
- [ ] [libgc.c](https://github.com/skeeto/w64devkit/blob/master/contrib/libgc.c)


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-02-22-%E5%9C%A8-c-%E4%BB%A3%E7%A0%81%E6%96%87%E4%BB%B6%E6%8F%92%E5%85%A5-shell-%E5%91%BD%E4%BB%A4/  

