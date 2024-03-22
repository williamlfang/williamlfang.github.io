# Abseil 代码阅读


Google 评价 Abseil 为：

&gt; 它是从 Google 内部代码块中抽取出来的一系列最基础的软件库。作为基本的组成部分，这些软件库支撑了几乎全部 Google 在运行的项目。以前这些 API 是零零散散地嵌入在 Google 的大部分开源项目中，现在我们将它们规整在一起，形成这样一个全面的项目。
&gt;
&gt; Abseil 是 Google 代码库的最基本构建模块，其代码经过了生产环节测试，此后还会继续得到完全的维护。

Abseil 中包括如下的库：

- [base ](https://github.com/abseil/abseil-cpp/tree/master/absl/base)：初始化，以及其它的基础代码。
- [algorithm ](https://github.com/abseil/abseil-cpp/tree/master/absl/algorithm)：对 C&#43;&#43; 的`&lt;algorithm&gt;`库的补充，并为原算法提供了基于容器的版本。
- [container ](https://github.com/abseil/abseil-cpp/tree/master/absl/container)：提供了更多的 STL 类型容器。
- [debugging ](https://github.com/abseil/abseil-cpp/tree/master/absl/debugging)：用于检查泄漏的调试库。
- [memory ](https://github.com/abseil/abseil-cpp/tree/master/absl/memory)：包括兼容 C&#43;&#43; 11 版本的`std::make_unique()`和内存管理。
- [meta ](https://github.com/abseil/abseil-cpp/tree/master/absl/meta)：包括兼容 C&#43;&#43; 11 版本的类型检查，在 C&#43;&#43; 14 和 C&#43;&#43; 17 版本的 C&#43;&#43; `&lt;type_traits&gt;`库中可用。
- [numeric ](https://github.com/abseil/abseil-cpp/tree/master/absl/numeric)：兼容 C&#43;&#43; 11 的 128 位整数。
- [strings ](https://github.com/abseil/abseil-cpp/tree/master/absl/strings)：各种字符串工具。
- [synchronization ](https://github.com/abseil/abseil-cpp/tree/master/absl/synchronization)：并发原语和同步抽象。
- [time ](https://github.com/abseil/abseil-cpp/tree/master/absl/time)：抽象了绝对时间点操作和时区操作。
- [types ](https://github.com/abseil/abseil-cpp/tree/master/absl/types)：非容器工具的类型。


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-08-06-abseil-%E4%BB%A3%E7%A0%81%E9%98%85%E8%AF%BB/  

