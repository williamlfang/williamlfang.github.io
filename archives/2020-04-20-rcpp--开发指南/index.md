# Rcpp: 开发指南




R 是一门统计编程语言，提供了丰富的统计分析方法，并允许用户安装第三方软件库，可以快速地构建从想法到实践的全过程。但是 R 毕竟是一门解释性语言，天然具有一定的性能瓶颈。Rcpp 正是为了解决性能问题，实现了用户使用更高性能的编译语言 c&#43;&#43; 优化运行速度。



# 安装 Rcpp

# 开发

## 使用 `cppFunction`



## 使用 `sourceRcpp`



# 注意

## Reference v.s. Copy

在 `Rcpp` 中，当我们把一个向量【赋值】给另外一个向量时，如果是使用 `=` (如 `v2=v1`)，则 `v2` 变成了 `v1` 的引用（`reference`），是 `v1` 的一个别名（`alias`）。也就是说，两者实际上依然指向同一个指针位置，从而修改 `v2` 会产生副作用：`v1` 也会跟着变化。

如果先完全复制一个向量，需要使用 `clone` 函数，此时两者就变成独立的变量了。

```cpp
NumericVector v1 = {1,2,3};   // create a vector v1
NumericVector v2 = v1;        // v1 is assigned to v2 through shallow copy.
NumericVector v3 = clone(v1); // v1 is assigned to v3 through deep copy.

v1[0] = 100; // changing value of a element of v1

// Following output shows that
// the modification of v1 element
// is also applied to v2 but not to v3
Rcout &lt;&lt; &#34;v1 = &#34; &lt;&lt; v1 &lt;&lt; endl; // 100 2 3
Rcout &lt;&lt; &#34;v2 = &#34; &lt;&lt; v2 &lt;&lt; endl; // 100 2 3
Rcout &lt;&lt; &#34;v3 = &#34; &lt;&lt; v3 &lt;&lt; endl; // 1 2 3
```



# 性能优化



# 参考链接

1. [Rcpp FAQ](https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-FAQ.pdf#page=23)：Dirk Eddelbuettel 亲自编写的关于 `Rcpp` 问题小结，短小精悍，非常值得一读。
2. [Rcpp for everyone](https://teuder.github.io/rcpp4everyone_en/)：可以说是非常通俗易懂的一个网上电子书，并且还提供实例。对于 `c&#43;&#43;` 基础相对薄弱的同学，`Rcpp` 的入门比较高，因此可以先对照着这本书上面的案例，从编写简单的 demo 开始逐步掌握。


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-20-rcpp--%E5%BC%80%E5%8F%91%E6%8C%87%E5%8D%97/  

