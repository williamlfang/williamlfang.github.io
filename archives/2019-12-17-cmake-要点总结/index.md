# cmake 要点总结


# 调试

通过 `CMAKE_BUILD_TYPE` 可以设置条件编译，执行生成可供调试的程序，这个相当于在命令行使用

```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug
```

```cmake
## 调试状态
set(CMAKE_BUILD_TYPE Debug)

## 发布状态
set(CMAKE_BUILD_TYPE Release)
```

# 头文件包含

## include_directories(include_path)

可以使用 `include_directories(include_path)`

```cmake
set(INCLUDE_PATH ./include)
include_directories(${INCLUDE_PATH})

## 也可以包含下一层的文件
include_directories(${INCLUDE_PATH}/sub_directory)
```

 # 使用 `find_`

 - `find_path`: 要求找到文件所在路径
 - `find_library`: 要求找到链接库
 - `find_package`: 找到安装的链接库，包含以上两个。如果依赖包是非标准安装的，则需要执行以上两个命令进行查找。

 以上命令执行后，可以生成

 - `XXX_LIBRARY`: 链接库
 - `XXX_INCLUDE_DIR`: 相关的头文件




## 递归包含

当然，如果头文件的依赖关系比较复杂，上述方法则显得有点迂腐。我们可以写个简单的函数，通过递归寻找目标路径下的所有 `.h` 头文件

```cmake
#获取当前目录及子目录(递归获取),添加到头文件搜索路径
function(include_sub_directories_recursively root_dir)

    if (IS_DIRECTORY ${root_dir})                               # 当前路径是一个目录吗，是的话就加入到包含目录
        message(&#34;include dir: &#34; ${root_dir})
        include_directories(${root_dir})
    endif()

    file(GLOB ALL_SUB RELATIVE ${root_dir} ${root_dir}/*)       # 获得当前目录下的所有文件，让如ALL_SUB列表中

    foreach(sub ${ALL_SUB})
    if (IS_DIRECTORY ${root_dir}/${sub})
        include_sub_directories_recursively(${root_dir}/${sub}) # 对子目录递归调用，包含
    endif()
    endforeach()

endfunction()


#项目的所有目录都为头文件搜索路径
include_sub_directories_recursively(${PROJECT_SOURCE_DIR})
```

# 动态链接库

## LINK_DIRECTORIES

## TARGET_LINK_DIRECTORIES



# 常用变量

## 变量引用

使用 `${VAR_NAME}` 获取变量值，但是在　`IF` 的语句中，是*直接使用变量名而不用通过 `${}`*来识别的，原因是这些语句要求显示得到变量。

## 宏变量

- `PROJECT_SOURCE_DIR`：最顶层 `CMakeLists.txt`所在的目录
- `PROJECT_BINARY_DIR`：
- `PROJECT_NAME`：通过 `project(pro_name)`定义得到的 `pro_name`
- `CMAKE_SOURCE_DIR`
- `CMAKE_BINARY_DIR`：执行 `cmake`（通常实在 build）的当前目录
- `CMAKE_CURRENT_SOURCE_DIR`: 当前 `CMakeLists.txt` 所在目录
- `EXECUTABLE_OUTPUT_PATH`：设置最终编译得到的可执行目标文件的路径
- `LIBRARY_OUTPUT_PATH`
- `CMAKE_C_FLAGS`
- `CMAKE_CXX_FLAGS`

## 自定义变量

### 使用 `set`

后面可以直接引用变量

```cmake
set(SRCS main.cpp math.cpp)
```

### 模糊匹配变量

把当前所有文件都命名为 `DIR_SRCS`

```cmake
aux_source_directory(. DIR_SRCS)
```

# 常用命令

## `CMAKE_MINIMUM_REQUIRED`

## `PROJECT(pro_name)`

## `INCLUDE(file.cmake)`

包含某个 `.cmake` 文件。

## `INCLUDE_DIRECTORIES(path_name)`

指定头文件路径，可以使用递归的方法包含文件夹下所有的头文件。

## `LINK_DIRECTORIES(path_name)`

指定动态链接库的文件路径。

## `ADD_SUBDIRECTORY(path_name)`

添加某个文件夹，实际上就是要求该文件夹下面存在 `CMakeLists.txt`，从而在执行 `cmake`的时候放入执行环境。

## `AUX_SOURCE_DIRECTORY(path_name DIR_NAME)`

相当于把某个文件夹下面的所有文件合并存放为变量 `DIR_NAME`，从而方便后面引用。这个指令临时被用来自动构建源文件列表。因为目前cmake还不能自动发现新添加的源文件。

```cmake
## 自动添加文件
AUX_SOURCE_DIRECTORY(. SRC_LIST)
## 变量引用
ADD_EXECUTABLE(main ${SRC_LIST})
```

## `ADD_EXECUTABLE(hello main.cpp)`

##  `TARGET_LINK_LIBRARY`

## `FIND` 系列

FIND_系列指令主要包含一下指令：

- `FIND_FILE(&lt;VAR&gt; name1 path1 path2 ...)`：VAR变量代表找到的文件全路径，包含文件名
- `FIND_LIBRARY(&lt;VAR&gt; name1 path1 path2 ...)`：VAR变量表示找到的库全路径，包含库文件名
    ```cmake
	## FIND_LIBRARY示例：
	FIND_LIBRARY(libX X11 /usr/lib)
	IF(NOT libX)
	MESSAGE(FATAL_ERROR “libX not found”)
	ENDIF(NOT libX)
	```
- `FIND_PATH(&lt;VAR&gt; name1 path1 path2 ...)`：VAR变量代表包含这个文件的路径。
- `FIND_PROGRAM(&lt;VAR&gt; name1 path1 path2 ...)`：VAR变量代表包含这个程序的全路径。
- `FIND_PACKAGE(&lt;name&gt; [major.minor] [QUIET] [NO_MODULE][[REQUIRED|COMPONENTS] [componets...]])`
    ```cmake
    FIND_PACKAGE(HELLO)
    IF(HELLO_FOUND)
    	ADD_EXECUTABLE(hello main.c)
        INCLUDE_DIRECTORIES(${HELLO_INCLUDE_DIR})
        TARGET_LINK_LIBRARIES(hello ${HELLO_LIBRARY})
    ENDIF(HELLO_FOUND)
    ```

## IF

**IF(expression_)** 和 **ENDIF(expression_)**需要成对出现，而且 `expression_` 内容要一样。

# 参考链接

1. [modern-cmake](https://cliutils.gitlab.io/modern-cmake/modern-cmake.pdf)
2. [Cmake实践](http://file.ncnynl.com/ros/CMake%20Practice.pdf)
3. [It&#39;s Time To Do CMake Right](https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-17-cmake-%E8%A6%81%E7%82%B9%E6%80%BB%E7%BB%93/  

