# 可预先分配空间的 std::priority_queue


`c&#43;&#43;` 标准库 `&lt;queue&gt;` 提供了优先队列 `priority_queue`，以 `log(1)` 的算法获取队列头部、并以 `log(n)` 的算法插入元素。其原型为

```c&#43;&#43;
template&lt;
    class T,
    class Container = std::vector&lt;T&gt;,
    class Compare = std::less&lt;typename Container::value_type&gt;
&gt; class priority_queue;
```

&lt;!--more--&gt;

## 模板

- `T`: 元素类型

- `Container`: 提供以下操作的容器，一般是 `std::vector&lt;T&gt;`

    - `front()`, e.g., std::vector::front(),
    - `push_back()`, e.g., std::deque::push_back(),
    - `pop_back()`, e.g., std::vector::pop_back().

- `Compare`: 比较元素间大小的运算，可以是 `operator()`、`functor`、`lambda expression`。默认是 `std::less`，即**从大到小**排序。

## 数据成员

`std::priority_queue` 包含了 `protected` 的数据成员

- `c`：这个是底层的容器，用于存储元素的内存空间。如果我们使用 `std::vector&lt;T&gt;` 作为存储容器，则可以通过这个进行预先分配内存空间，以避免在运行时的动态扩张，进而可以提供程序性能。
- `comp`：比较函数

## 预先分配容器的存储空间

利用 `std::priority_queue` 里面的容器存储 `c`（为 `protected`），我们可以写一个继承类，并提供 `reserve` 接口。

```c&#43;&#43;
#include &lt;queue&gt;

template &lt;class T,
          class Container = std::vector&lt;T&gt;,
          class Compare = std::less&lt;typename Container::value_type&gt;&gt;
class reservable_priority_queue: public std::priority_queue&lt;T, Container, Compare&gt;
{
public:
    using size_type = typename std::priority_queue&lt;T, Container, Compare&gt;::size_type;

    reservable_priority_queue(size_type capacity = 0)
    {
        reserve(capacity);
    };

    void reserve(size_type capacity)
    {
        this-&gt;c.reserve(capacity);
    }

    size_type capacity() const
    {
        return this-&gt;c.capacity();
    }
};
```

## 完整代码

```c&#43;&#43;
#include &lt;queue&gt;
#include &lt;iostream&gt;
using namespace std;

template &lt;class T,
          class Container = std::vector&lt;T&gt;,
          class Compare = std::less&lt;typename Container::value_type&gt;&gt;
class reservable_priority_queue: public std::priority_queue&lt;T, Container, Compare&gt;
{
public:
    using size_type = typename std::priority_queue&lt;T, Container, Compare&gt;::size_type;

    reservable_priority_queue(size_type capacity = 0)
    {
        reserve(capacity);
    };

    void reserve(size_type capacity)
    {
        this-&gt;c.reserve(capacity);
    }

    size_type capacity() const
    {
        return this-&gt;c.capacity();
    }
};

struct entry_t
{
    int seq {-1};
    double val {.0};
};

struct cmp_t
{
    bool operator()(const entry_t&amp; lhs, const entry_t&amp; rhs)
    {
        return lhs.seq &gt;= rhs.seq;
    }
};

int main()
{
    reservable_priority_queue&lt;entry_t, std::vector&lt;entry_t&gt;, cmp_t&gt; q;
    q.reserve(10000);
    std::cout &lt;&lt; q.capacity() &lt;&lt; &#39;\n&#39;;

    for (int i = 0; i &lt; 10; &#43;&#43;i)
    {
        q.emplace(entry_t{i, i*i*1.0});
    }
    while (!q.empty())
    {
        auto&amp; e = q.top();
        cout &lt;&lt; &#34;seq:&#34; &lt;&lt; e.seq
             &lt;&lt; &#34;, val:&#34; &lt;&lt; e.val
             &lt;&lt; endl;
        q.pop();
    }
}
```

测试结果：
```bash
 g&#43;&#43; pq.cpp -std=c&#43;&#43;17
 ./a.out

10000
seq:0, val:0
seq:1, val:1
seq:2, val:4
seq:3, val:9
seq:4, val:16
seq:5, val:25
seq:6, val:36
seq:7, val:49
seq:8, val:64
seq:9, val:81
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-04-29-%E5%8F%AF%E9%A2%84%E5%85%88%E5%88%86%E9%85%8D%E7%A9%BA%E9%97%B4%E7%9A%84-std--priority_queue/  

