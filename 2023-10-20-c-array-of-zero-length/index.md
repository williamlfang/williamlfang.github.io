# c&#43;&#43; array of ZERO length


## old-style:[0]

我在查看代码的时候，发现有一个 `struct` 有 **长度为0** 的数组。

```c&#43;&#43;
struct data_t
{
    size_t size;
    int data[0];
};
```

&lt;!--more--&gt;

如果打印出上面结构体，发现长度正好为 `size_t`，其中的 `data` 是不占用内存的。

```c&#43;&#43;
cout &lt;&lt; &#34;sizeof(size_t):&#34; &lt;&lt; sizeof(size_t) &lt;&lt; endl;
cout &lt;&lt; &#34;sizeof(data_t):&#34; &lt;&lt; sizeof(data_t) &lt;&lt; endl;

//sizeof(size_t):8
//sizeof(data_t):8
```


原来，这样做的目的，是为了可以添加不限长度的数组，通过 `malloc` 分配内存大小，从而实现在代码中灵活分配数据的目的。

```c&#43;&#43;
data_t* get_data(size_t size)
{
    data_t* d = (data_t*) malloc(sizeof(data_t) &#43; size * sizeof(int));
    if (d)
        d-&gt;size = size;
    return d;
}
```

## new-style:[]

其实，这是一种比较古老的写法，我们完全可以使用 `arr[]` (flexible array member) 来替代

```c&#43;&#43;
struct data_t
{
    size_t size;
    //In C99 standard this is not neccessary as it supports the arr[] syntax.
    int data[];
};
```

完整的测试代码如下：

```c&#43;&#43;
#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;vector&gt;
#include &lt;cstdlib&gt;
using namespace std;

struct data_t
{
    size_t size;
    //This is an old C hack to allow a flexible sized arrays.
    int data[0];
    //In C99 standard this is not neccessary as it supports the arr[] syntax.
    //int data[];
};

data_t* get_data(size_t size)
{
    data_t* d = (data_t*) malloc(sizeof(data_t) &#43; size * sizeof(int));
    if (d) d-&gt;size = size;
    return d;
}

int main()
{
    cout &lt;&lt; &#34;sizeof(size_t):&#34; &lt;&lt; sizeof(size_t) &lt;&lt; endl;
    cout &lt;&lt; &#34;sizeof(data_t):&#34; &lt;&lt; sizeof(data_t) &lt;&lt; endl;

    auto x = get_data(10);
    for (size_t i = 0; i &lt; x-&gt;size; &#43;&#43;i)
        x-&gt;data[i] = i*i;

    for (size_t i = 0; i &lt; x-&gt;size; &#43;&#43;i)
        cout &lt;&lt; &#34;x[&#34; &lt;&lt; i &lt;&lt; &#34;]:&#34; &lt;&lt; x-&gt;data[i] &lt;&lt; endl;

    return 0;
}
```

## best-style:[1]

上面的做法有一个问题，如果使用编译器选项 `-pedantic` 会有报错提示：

```bash
## 对于 int data[0]
main.cpp:11:14: warning: ISO C&#43;&#43; forbids zero-size array ‘data’ [-Wpedantic]
   11 |     int data[0];
      |              ^

## 对于 int data[]
main.cpp:13:9: warning: ISO C&#43;&#43; forbids flexible array member ‘data’ [-Wpedantic]
   13 |     int data[];
      |         ^~~~
```

&gt; It&#39;s worth pointing out IMO the best way to do the size calculation, which is used in the Raymond Chen article linked above.

```c&#43;&#43;
struct data_t
{
    size_t size;
    int data[1];
};

data_t* get_data(size_t size)
{
    // 使用 offsetof 计算出 data[size] 占用的大小
    data_t* d = (data_t*) malloc(offsetof(data_t, data[size]));
    if (d) d-&gt;size = size;
    return d;
}
```

完整的测试代码如下：

```c&#43;&#43;
#include &lt;cstddef&gt;
#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;vector&gt;
#include &lt;cstdlib&gt;
using namespace std;

struct data_t
{
    size_t size;
    int data[1];
};

data_t* get_data(size_t size)
{
    data_t* d = (data_t*) malloc(offsetof(data_t, data[size]));
    if (d) d-&gt;size = size;
    return d;
}

int main()
{
    cout &lt;&lt; &#34;sizeof(size_t):&#34; &lt;&lt; sizeof(size_t) &lt;&lt; endl;
    cout &lt;&lt; &#34;sizeof(data_t):&#34; &lt;&lt; sizeof(data_t) &lt;&lt; endl;

    auto x = get_data(20);
    for (size_t i = 0; i &lt; x-&gt;size; &#43;&#43;i)
        x-&gt;data[i] = i*i;

    cout &lt;&lt; &#34;x.size:&#34; &lt;&lt; x-&gt;size &lt;&lt; endl;
    for (size_t i = 0; i &lt; x-&gt;size; &#43;&#43;i)
        cout &lt;&lt; &#34;x[&#34; &lt;&lt; i &lt;&lt; &#34;]:&#34; &lt;&lt; x-&gt;data[i] &lt;&lt; endl;

    return 0;
}
```


## Ref:

- [Array of zero length](https://stackoverflow.com/questions/295027/array-of-zero-length)
- [Why do some structures end with an array of size 1?](https://devblogs.microsoft.com/oldnewthing/20040826-00/?p=38043)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-10-20-c-array-of-zero-length/  

