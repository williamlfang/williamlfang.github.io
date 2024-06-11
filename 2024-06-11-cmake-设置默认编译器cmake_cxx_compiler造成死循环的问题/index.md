# cmake 设置默认编译器CMAKE_CXX_COMPILER造成死循环的问题


为了以指定版本的编译器进行编译，我们可以通过修改 `cmake` 默认编译器 (CMAKE_CXX_COMPILER)。然而，如果在多项目的 `add_subdirectory` 包含其他项目，可能造成死循环的问题。

&lt;!--more--&gt;

处理这个问题，需要我们在所有项目的顶层设置，即在最顶层的项目 `CMakeLists.txt` 的 `project` 之前设置

```cmake
# top setting ===========================================================----==
cmake_minimum_required(VERSION 3.15)
SET(CMAKE_C_COMPILER /usr/bin/gcc)
SET(CMAKE_CXX_COMPILER /usr/bin/g&#43;&#43;)
set(CMAKE_CXX_STANDARD 17 CACHE STRING &#34;v&#34;)
## =============================================================================
## need to be after top setting
project(snail CXX)
## =============================================================================
```

主要参考文章：[CMakeLists.txt 修改默认编译器导致死循环的问题解决](https://www.cnblogs.com/yqmcu/p/16309091.html)



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-11-cmake-%E8%AE%BE%E7%BD%AE%E9%BB%98%E8%AE%A4%E7%BC%96%E8%AF%91%E5%99%A8cmake_cxx_compiler%E9%80%A0%E6%88%90%E6%AD%BB%E5%BE%AA%E7%8E%AF%E7%9A%84%E9%97%AE%E9%A2%98/  

