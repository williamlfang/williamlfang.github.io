# c&#43;&#43; 巧用 do...while.false


今天看代码发现一个比较巧妙的方法，可以参考 [SO 链接](https://stackoverflow.com/questions/2314066/do-whilefalse)

对比两个 `c&#43;&#43;` 代码段

```c&#43;&#43;
do {
   // code
   if (condition) break; // or continue
   // more code
} while(false);
```

完爆一下的 `goto`

```cpp
{
   // code
   if (condition) goto end;
   // more code
}
end:
```

`do{...}while(false);`提供了提前退出的机制，可以替代臭名昭著的 `goto` 语法，实现在一个代码段内进行判断与退出的巧妙机制。

可以参考以下的这篇文章，讲解的更加清晰：
- [do...while](https://blog.csdn.net/zhenyusoso/article/details/7960477)





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-07-12-c&#43;&#43;-%E5%B7%A7%E7%94%A8-do...while.false/  

