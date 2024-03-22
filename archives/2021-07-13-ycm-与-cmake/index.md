# Ycm 与 cmake


最近在配置 `vim` 的 `ycm` 插件，发现如果需要针对某个非系统的头文件路径，需要单独修改 `third_party/ycmd/.ycm_extra_conf.py`。

```bash
&#39;-isystem&#39;,&#39;cpp/ycm/benchmarks/benchmark/include&#39;,
&#39;-isystem&#39;,&#39;/shared/trading/Wuya/release/include&#39;,
```

这样的话，如果更换了项目，需要每次都重新修改配置文件，显得似乎有点多余。后来在网站看到可以通过配置 `CMakeLists.txt` 文件来达到编译的时候自动更新 `ycm` 的查找路径，从而可以针对每个项目进行独立的配置。

具体是在 `CMakeListst.txt` 添加一下编译选项：

```bash
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

IF(EXISTS &#34;${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json&#34;)
  EXECUTE_PROCESS( COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
    ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
  )
ENDIF()
```

可以参考链接：[YouCompleteMe and CMake](https://bastian.rieck.me/blog/posts/2015/ycm_cmake/)




---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-07-13-ycm-%E4%B8%8E-cmake/  

