# SnailCore: 开发实例


# 项目结构

```bash
.
├── CMakeLists.txt
└── main.cpp

0 directories, 2 files
```
&lt;!--more--&gt;


# `CMakeLists.txt`

```cmake
########################################################
snail_add_bin(test main.cpp)
snail_bin_dep(test util shell)
```

# `main.cpp`

```c&#43;&#43;
#include &lt;shell/main.hpp&gt;
#include &lt;util/calendar.hpp&gt;
#include &lt;util/log.hpp&gt;

using namespace snail;
using namespace std;

class playground_t: public snail::Main
{
public:
    using base_t = snail::Main;
    using base_t::base_t;

    playground_t() {};
    ~playground_t() {};

    const char* name() const override { return &#34;playground_t&#34;; };
    bool do_init() override;
    void run() override;
};

bool playground_t::do_init()
{
    if (!base_t::do_init()) return false;

    return true;
}

void playground_t::run()
{
    base_t::run();

    for (auto&amp; td : _calendar.trading_days())
    {
        cout &lt;&lt; &#34;night:&#34; &lt;&lt; td.night &lt;&lt; &#34;, day:&#34; &lt;&lt; td.day &lt;&lt; endl;
    }

    if (_calendar.has_session(microtime::now()))
    {
        cout &lt;&lt; &#34;has session:&#34; &lt;&lt; microtime::now().to_zgc_str() &lt;&lt; endl;
    }
}

int main(int argc, char* argv[])
{
    playground_t pl;
    return pl.main(argc, argv);
}

```

# 注意事项

1. 在 `bool do_init() override;` 的最后，一定要返回 `return true;`，否则会默认 `false`，导致后面面的 `run` 不会再继续运行。

    ```c&#43;&#43;
        bool playground_t::do_init()
        {
           if (!base_t::do_init()) return false;

           return true;  // 需要加上
        }
    ```

2. 在 `run` 继承的时候，最好加上 `base_t::run();` 以保证可以调用其他的参数

    ```c&#43;&#43;
    void playground_t::run()
    {
       base_t::run();  // 需要加上

       for (auto&amp; td : _calendar.trading_days())
       {
           cout &lt;&lt; &#34;night:&#34; &lt;&lt; td.night &lt;&lt; &#34;, day:&#34; &lt;&lt; td.day &lt;&lt; endl;
       }

       if (_calendar.has_session(microtime::now()))
       {
           cout &lt;&lt; &#34;has session:&#34; &lt;&lt; microtime::now().to_zgc_str() &lt;&lt; endl;
       }
    }
    ```


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-10-15-snailcore--%E5%BC%80%E5%8F%91%E5%AE%9E%E4%BE%8B/  

