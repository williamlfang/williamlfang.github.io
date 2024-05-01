# CRTP 与 std::variant

**Curriously Recursive Template Method**(`CRTP`) 一种是实现了编译期多态（静态多态）的方法，相比于虚函数（`virtual`）跳过了虚表`vtable`查找，提供了比动态多态（运行时多态）更好的性能。


&lt;!--more--&gt;

## demo

```c&#43;&#43;
#include &lt;functional&gt;
#include &lt;vector&gt;
#include &lt;iostream&gt;
#include &lt;unordered_map&gt;
#include &lt;string&gt;
#include &lt;utility&gt;
#include &lt;variant&gt;
using namespace std;

template&lt;typename T&gt;
struct B
{
public:
    using cb_t = std::function&lt;void()&gt;;

    B() { _cbs.reserve(10); }
    virtual ~B() { cout &lt;&lt; &#34;~B&#34; &lt;&lt; endl; }

    void foo() noexcept
    {
        this-&gt;get()-&gt;foo_impl();
        for (const auto&amp; cb : _cbs)
            cb();
    }
    void register_cb(cb_t cb) noexcept
    {
        _cbs.push_back(cb);
    }

private:
    T* get() noexcept { return static_cast&lt;T*&gt;(this); }
    std::vector&lt;cb_t&gt; _cbs;
};

struct D1: public B&lt;D1&gt;
{
    ~D1() { cout &lt;&lt; &#34;~D1&#34; &lt;&lt; endl; }
    void foo_impl() noexcept { cout &lt;&lt; &#34;D1:foo_impl&#34; &lt;&lt; endl; }
};

struct D2: public B&lt;D2&gt;
{
    ~D2() { cout &lt;&lt; &#34;~D2&#34; &lt;&lt; endl; }
    void foo_impl() noexcept { cout &lt;&lt; &#34;D2:foo_impl&#34; &lt;&lt; endl; }
};

int main()
{
    B&lt;D1&gt;* d1 = new D1;
    d1-&gt;register_cb([]()
    {
        cout &lt;&lt; &#34;[d1] cb called&#34; &lt;&lt; endl;
    });

    B&lt;D2&gt;* d2 = new D2;
    d2-&gt;register_cb([]()
    {
        cout &lt;&lt; &#34;[d2] cb called&#34; &lt;&lt; endl;
    });

    std::unordered_map&lt;std::string, std::variant&lt;B&lt;D1&gt;*, B&lt;D2&gt;*&gt;&gt; m;
    m[&#34;d1&#34;] = d1;
    m[&#34;d2&#34;] = d2;

    //sse
    {
        auto d = std::get&lt;B&lt;D1&gt;*&gt;(m[&#34;d1&#34;]);
        d-&gt;foo();
    }

    //szse
    {
        auto d = std::get&lt;B&lt;D2&gt;*&gt;(m[&#34;d2&#34;]);
        d-&gt;foo();

    }
    delete d1;
    delete d2;

    return 0;
}
```

## 运行结果

```bash
D1:foo_impl
[d1] cb called
D2:foo_impl
[d2] cb called
~D1
~D2
```

## Tips

- cb 需要绑定 `lambda` 表达式的引用或者函数指针，编译器有可能认为这是同一个代码段，导致上面的 cb 一直打印 `d2 cb`


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-01-crtp-%E4%B8%8E-std--variant/  

