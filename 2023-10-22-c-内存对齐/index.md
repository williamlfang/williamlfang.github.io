# c&#43;&#43; 内存对齐


我们在设计结构体时，需要慎重考虑**内存对齐**的问题，因为不同的内存对齐方式对程序的性能有极大的影响。


## CPU 读取内存的最小有效值

计算机的内存是按照 `byte(8 bits)` 进行有序排序，理论上，我们可以在最小有效值为 `1 byte` 进行随机内存读取。然而，如果每次都是按照这个节奏，每取一个 `int（假设为 4byte）` 变量，`CPU` 都需要进行 4 次操作，毫无疑问效率极低。

我们知道 `CPU` 架构有 `32bit` 与 `64bit` 两种，其含义是在 `CPU` 每次从内存地址取值时，是以对应**最小有效内存地址**进行快速操作的。简单讲

- 对于 `32bit`，最优操作为每次取 `4 byte` 的内存空间进行识别
- 对于 `64bit`，最优操作为每次取 `8 byte` 的内存空间进行识别

现在的操作系统一般都是 `64bit` 了，所以每次的最佳取内存地址为 `8byte`，这也是我们经常说的，内存对齐按照 `8byte`，也是编译器 `gcc` 默认采用的大小。

```c&#43;&#43;&#43;
#pragama pack(8)
```

&lt;!--more--&gt;

## 如果计算 struct 的内存大小

1. 先计算操作系统 `CPU` 的对齐单位（一般为 `8byte`），根据结构体成员最大的内存单位，取 **两者的最小值**作为有效对齐单位(x)
2. 对于结构体的每一个成员，取其大小与有效对齐单位的**较小者**，作为单个成员的有效单位(e)。第一个成员变量的偏移值从 0 开始，按照每个成员的有效对齐单位排列，不足之处进行补位填充
3. 最后，整个结构体还需要按照有效对齐单位(x)的整数倍进行填充

```c&#43;&#43;&#43;
#include &lt;iostream&gt;
using namespace std;

#pragma pack(push)
#pragma pack(4)
struct
{
    int a;
    double b;
    short c;
} u;
#pragma pack(pop)

#pragma pack(push)
#pragma pack(1)
struct
{
    int a;
    double b;
    short c;
} v;
#pragma pack(pop)

struct
{
    int a;
    double b;
    short c;
} x;

struct
{
    int a;
    char b;
    short c;
} y;

struct
{
    int a;
    char b;
    short c;
} __attribute__((packed)) z;

int main()
{
    cout &lt;&lt; &#34;sizeof(u):&#34; &lt;&lt; sizeof(u) &lt;&lt; endl;
    cout &lt;&lt; &#34;sizeof(v):&#34; &lt;&lt; sizeof(v) &lt;&lt; endl;
    cout &lt;&lt; &#34;sizeof(x):&#34; &lt;&lt; sizeof(x) &lt;&lt; endl;
    cout &lt;&lt; &#34;sizeof(y):&#34; &lt;&lt; sizeof(y) &lt;&lt; endl;
    cout &lt;&lt; &#34;sizeof(z):&#34; &lt;&lt; sizeof(z) &lt;&lt; endl;
    return 0;
}
```
- `sizeof(u)`:16, int(4) &#43; double(8) &#43; short(2) = (14/4&#43;1) * 4 = 16

- `sizeof(v)`:14, int(4) &#43; double(8) &#43; short(2) = 14/1 = 14

- `sizeof(x)`:24
    - 1. 结构体 x 的最大成员 (double)b 的内存占用 8，操作系统64位，则有效对齐单位 x = min(8,8) = 8
    - 2. 对于结构体的每个成员
        - sizeof(a) = 4 &lt;= 8, 则按照4的倍数进行偏移（4byte），占用4个字节，已用:4
        - sizeof(b) = 1 &lt;= 8, 则按照1的倍数进行偏移，从（4byte）开始，先对齐 8 byte，占用 8 byte，已用: 4 &#43; 4(填充) &#43; 8 = 16
        - sizeof(c) = 2 &lt;= 8, 则按照2的倍数进行偏移，从上面 16 后面按照 2 的倍数，占用两个字节，已用：16 &#43; 2 = 18
    - 3. 最后，整个结构体再按照 x=8 的倍数对齐，(18/8&#43;1) * 8 = 24，所以整个结构体大小为24字节
    - 4. 内存空间为
    ```
    xxxx  ____   xxxxxxxx xx ______
     4    pad(4) 8        2  pad(6)
    ```

- `sizeof(y)`:8
    - 1. 结构体 y 的最大成员 a 的内存占用 4，操作系统64位，则有效对齐单位 x = min(4,8) = 4
    - 2. 对于结构体的每个成员
        - `sizeof(a)` = 4 &lt;= 4, 则按照4的倍数进行偏移（4byte），占用4个字节，已用:4
        - `sizeof(b)` = 1 &lt;= 4, 则按照1的倍数进行偏移，从（4byte）开始，占用一个字节，已用: 4 &#43; 1 = 5
        - `sizeof(c)` = 2 &lt;= 4, 则按照2的倍数进行偏移，从上面 5 后面按照 2 的倍数，占用两个字节，已用：5 &#43; 1(填充) &#43; 2 = 8
    - 3. 最后，整个结构体再按照 x=4 的倍数对齐，刚好为 8，所以整个结构体大小为8字节

- `sizeof(z)`:7
    - 我们告诉编译器不用对齐，所以按照实际占用的字节占用 7 byte.

## 使用 pack 指定对齐

可以使用编译器提供的 `pack(n)` 指定对齐大小：

```c&#43;&#43;
#pragma pack(n)
```

或者使用压栈的方式

```c&#43;&#43;
#pragma pack(push, n)

#pragma pop()
```

## 不同内存对齐影响程序性能

```bash
## 可以看到，在 64 位操作系统中，最佳实践为 8byte 对齐
SampleStructPack1: 1000000000000000000 bytes allocated in 8202 nanoseconds
SampleStructPack2: 1200000000000000000 bytes allocated in 276 nanoseconds
SampleStructPack4: 1600000000000000000 bytes allocated in 205 nanoseconds
SampleStructPack4: 1600000000000000000 bytes allocated in 131 nanoseconds
```

程序如下：

```c&#43;&#43;
#include &lt;iostream&gt;
#include &lt;chrono&gt;

#pragma pack (1)
struct SampleStructPack1
{
    bool flag;
    unsigned int timeout;
};
//#pragma pack(0)

#pragma pack (2)
struct SampleStructPack2
{
    bool flag;
    unsigned int timeout;
};
// #pragma pack(0)

#pragma pack (4)
struct SampleStructPack4
{
    bool flag;
    unsigned int timeout;
};
// #pragma pack(0)

#pragma pack (8)
struct SampleStructPack8
{
    bool flag;
    unsigned int timeout;
};
// #pragma pack(0)

struct SampleStruct
{
    bool flag;
    unsigned int timeout;
};

static const long long MAX_ELEMENTS = 200000000000000000;
using namespace std;
using namespace std::chrono;

void allocate1()
{
    SampleStructPack1 elements [MAX_ELEMENTS];
    cout &lt;&lt; &#34;SampleStructPack1: &#34; &lt;&lt; sizeof(elements) &lt;&lt; &#34; bytes allocated&#34;;
}

void allocate2()
{
    SampleStructPack2 elements [MAX_ELEMENTS];
    cout &lt;&lt; &#34;SampleStructPack2: &#34; &lt;&lt; sizeof(elements) &lt;&lt; &#34; bytes allocated&#34;;
}

void allocate4()
{
    SampleStructPack4 elements [MAX_ELEMENTS];
    cout &lt;&lt; &#34;SampleStructPack4: &#34; &lt;&lt; sizeof(elements) &lt;&lt; &#34; bytes allocated&#34;;
}

void allocate8()
{
    SampleStructPack8 elements [MAX_ELEMENTS];
    cout &lt;&lt; &#34;SampleStructPack8: &#34; &lt;&lt; sizeof(elements) &lt;&lt; &#34; bytes allocated&#34;;
}

void chrono1()
{
    auto begin = high_resolution_clock::now() ;
    allocate1();
    cout &lt;&lt; &#34; in &#34; &lt;&lt; duration_cast&lt;nanoseconds&gt;(high_resolution_clock::now() - begin).count() &lt;&lt; &#34; nanoseconds&#34; &lt;&lt; endl;
}

void chrono2()
{
    auto begin = high_resolution_clock::now() ;
    allocate2();
    cout &lt;&lt; &#34; in &#34; &lt;&lt; duration_cast&lt;nanoseconds&gt;(high_resolution_clock::now() - begin).count() &lt;&lt; &#34; nanoseconds&#34; &lt;&lt; endl;
}

void chrono4()
{
    auto begin = high_resolution_clock::now() ;
    allocate4();
    cout &lt;&lt; &#34; in &#34; &lt;&lt; duration_cast&lt;nanoseconds&gt;(high_resolution_clock::now() - begin).count() &lt;&lt; &#34; nanoseconds&#34; &lt;&lt; endl;
}

void chrono8()
{
    auto begin = high_resolution_clock::now() ;
    allocate4();
    cout &lt;&lt; &#34; in &#34; &lt;&lt; duration_cast&lt;nanoseconds&gt;(high_resolution_clock::now() - begin).count() &lt;&lt; &#34; nanoseconds&#34; &lt;&lt; endl;
}

int main(int argc, char *argv[])
{
    chrono1();
    chrono2();
    chrono4();
    chrono8();

    return 0;
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-10-22-c-%E5%86%85%E5%AD%98%E5%AF%B9%E9%BD%90/  

