# cmake 指定编译器路径


原来是在 `CMakeLists.txt` 里设置编译器路径，但是发现这个没有生效：

```cmake
set(CMAKE_CXX_COMPILER g&#43;&#43;)
```

后面在 SO 上面找到答案：需要使用 export 指定路径。[How to specify new GCC path for CMake](https://stackoverflow.com/questions/17275348/how-to-specify-new-gcc-path-for-cmake)

```bash
export CC=/usr/local/bin/gcc
export CXX=/usr/local/bin/g&#43;&#43;
cmake /path/to/your/project
make
```

这里提醒一下，尽量避免使用 `set` 语句。

&gt; 使用set()在CMakeLists.txt 文件中设置CMAKE_FOO_COMPILER 变量值为有效的编译器名称或者全路径。必须在任何语言之前调用set（比如project()或enable_language()）。



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-08-cmake-%E6%8C%87%E5%AE%9A%E7%BC%96%E8%AF%91%E5%99%A8%E8%B7%AF%E5%BE%84/  

