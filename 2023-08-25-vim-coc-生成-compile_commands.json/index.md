# vim coc 生成 compile_commands.json


`vim` 使用 `coc` 需要找到 `compile_commands.json`。

&lt;!--more--&gt;

- 第一种方法，通过命令行添加，会在 `build` 目录下面自动生成

    ```bash
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1
    ```

- 第二种方法，通过修改 `CMakeLists.txt`

    ```cmake
    SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    IF(EXISTS &#34;${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json&#34;)
        EXECUTE_PROCESS( COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
            ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
      )
    ENDIF()
    ```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-08-25-vim-coc-%E7%94%9F%E6%88%90-compile_commands.json/  

