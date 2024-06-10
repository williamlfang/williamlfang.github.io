# c&#43;&#43; inline浅析


`gcc` 提供关键词 `inline`，允许我们标注函数需要在编译时展开，这样可以避免函数调用，减低函数栈开销，从而达到优化程序的目地。然而，天下并没有免费的午餐，在引入 `inline` 的同时，我们也需要注意其带来的程序体积变大、`cache locality` 减少的风险。

&gt; Pros of inlining:
&gt; - Removes function call overhead (yay!)
&gt; - May reveal additional optimization opportunities (sometimes yay!)
&gt;
&gt; Cons of inlining:
&gt; - Increases program size (boo!)
&gt; - May reduce cache locality (sometimes boo!)
&gt; - May increase build times (boo!)


&lt;!--more--&gt;

## inline 使用

## 避免

## Ref

- [Smarter C/C&#43;&#43; inlining with __attribute__((flatten))](https://awesomekling.github.io/Smarter-C&#43;&#43;-inlining-with-attribute-flatten/)


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-10-c-inline%E6%B5%85%E6%9E%90/  

