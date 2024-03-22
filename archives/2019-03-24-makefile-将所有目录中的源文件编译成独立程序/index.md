# makefile 将所有目录中的源文件编译成独立程序


`makefile` 是一款功能强大的**工程项目管理套件**，可以根据各个文件之间的依赖关系，自动生成事物处理的完整流程。我们现在有一个要求：使用 `make` 来一次性的把目录下的所有源文件编译成单独可运行的程序。

&lt;!--more--&gt;

# 搜索目录总的所有源文件

使用*通配符*(wildcard)来获取当前目录总的所有 `.cpp` 文件

```makefile
SRCS = $(wildcard *.cpp)
```

# 指定编译成相应名称的独立程序

```makefile
PROGS = $(patsubst %.cpp, %, $(SRCS))
```

# 执行相应的功能

```makefile
# 自动完成编译过程

CC      = g&#43;&#43;
CFLAGS  = -ggdb3 -std=c&#43;&#43;11 -Wall
SRCS    = $(wildcard *.cpp)
PROGS   = $(patsubst %.cpp, %, $(SRCS))
.PHONY: all info clean

all: $(PROGS)

%: %.cpp
	$(CC) $(CFLAGS) -o $@ $&lt;

info:
	@echo &#34;all source files...&#34;
	@echo $(SRCS)
	@echo &#34;all target programms...&#34;
	@echo $(PROGS)

clean:
	rm -f $(PROGS)
```

![make](/images/2019-03-24-makefile-将所有目录中的源文件编译成独立程序/make.gif)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-03-24-makefile-%E5%B0%86%E6%89%80%E6%9C%89%E7%9B%AE%E5%BD%95%E4%B8%AD%E7%9A%84%E6%BA%90%E6%96%87%E4%BB%B6%E7%BC%96%E8%AF%91%E6%88%90%E7%8B%AC%E7%AB%8B%E7%A8%8B%E5%BA%8F/  

