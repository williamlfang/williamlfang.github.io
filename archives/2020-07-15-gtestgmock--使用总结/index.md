# gtest,gmock: 使用总结


项目地址：[googletest](https://github.com/google/googletest)

# GoogleTest

考虑到 `gtest` 和 `gmock` 两个项目均是针对单元测试

&gt; This repository is a merger of the formerly separate GoogleTest and GoogleMock projects. These were so closely related that it makes sense to maintain and release them together.

&lt;!--more--&gt;

## 安装

### Ubuntu

```bash
git clone git@github.com:google/googletest.git
cd googletest
cmake -DBUILD_SHARED_LIBS=ON ..
make -j

## install: YES
sudo make install

## install: NO
cp -r ../include/gtest ~/usr/gtest/include/
cp ./lib/*.so ~/usr/gtest/lib

## check
sudo ldconfig -v | grep gtest
sudo ldconfig -v | grep gmock
```

### CentOS7

## Demo

### 单独文件

vim `test.cpp`:

```C&#43;&#43;
#include &lt;gtest/gtest.h&gt;
TEST(MathTest, TwoPlusTwoEqualsFour) {
    EXPECT_EQ(2 &#43; 2, 4);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest( &amp;argc, argv );
    return RUN_ALL_TESTS();
}
```

Compile:

```bash
g&#43;&#43; test.cpp -lgtest -o test

./test

[==========] Running 1 test from 1 test suite.
[----------] Global test environment set-up.
[----------] 1 test from MathTest
[ RUN      ] MathTest.TwoPlusTwoEqualsFour
[       OK ] MathTest.TwoPlusTwoEqualsFour (0 ms)
[----------] 1 test from MathTest (0 ms total)

[----------] Global test environment tear-down
[==========] 1 test from 1 test suite ran. (0 ms total)
[  PASSED  ] 1 test.
```

 ### 使用 Cmake

#### 测试文件

可以使用类，注意这里使用 `TEST_F`

```c&#43;&#43;
#include &lt;gtest/gtest.h&gt;
#include &lt;vector&gt;

// 使用共享数据
class VectorTest : public testing::Test
{
protected:
    virtual void SetUp() override
    {
        vec.push_back(1);
        vec.push_back(2);
        vec.push_back(3);
    }
    std::vector&lt;int&gt; vec;
};

// 注意这里使用 TEST_F，而不是 TEST
TEST_F(VectorTest, PushBack)
{
    // 虽然这里修改了 vec，但对其它测试函数来说是不可见的
    vec.push_back(4);
    EXPECT_EQ(vec.size(), 4);
    EXPECT_EQ(vec.back(), 4);
}

TEST_F(VectorTest, Size)
{
    EXPECT_EQ(vec.size(), 3);
}

int main(int argc, char *argv[])
{
    ::testing::InitGoogleTest(&amp;argc, argv);
    return RUN_ALL_TESTS();
}
```

#### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.15)
project(mytest)

find_package(GTest REQUIRED)

add_executable(mytest main.cpp)

target_include_directories(mytest PRIVATE ${GTEST_INCLUDE_DIRS})
target_link_libraries(mytest PRIVATE ${GTEST_BOTH_LIBRARIES})

add_test(Test mytest)
enable_testing()
```

#### 构建

```bash

$ cmake ..

-- The C compiler identification is GNU 7.5.0
-- The CXX compiler identification is GNU 9.2.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c&#43;&#43;
-- Check for working CXX compiler: /usr/bin/c&#43;&#43; -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Found GTest: /usr/local/lib/libgtest.so
-- Configuring done
-- Generating done
-- Build files have been written to: /home/william/Desktop/mycpp/build

$ make -j

Scanning dependencies of target mytest
[ 50%] Building CXX object CMakeFiles/mytest.dir/main.cpp.o
[100%] Linking CXX executable mytest
[100%] Built target mytest

$./mytest

[==========] Running 2 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 2 tests from VectorTest
[ RUN      ] VectorTest.PushBack
[       OK ] VectorTest.PushBack (0 ms)
[ RUN      ] VectorTest.Size
[       OK ] VectorTest.Size (0 ms)
[----------] 2 tests from VectorTest (0 ms total)

[----------] Global test environment tear-down
[==========] 2 tests from 1 test suite ran. (0 ms total)
[  PASSED  ] 2 tests.
```

当然，可以直接使用命令运行测试

```bash
make test

Running tests...
Test project /home/william/Desktop/mycpp/build
    Start 1: Test
1/1 Test #1: Test .............................   Passed    0.02 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   0.02 sec
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-07-15-gtestgmock--%E4%BD%BF%E7%94%A8%E6%80%BB%E7%BB%93/  

