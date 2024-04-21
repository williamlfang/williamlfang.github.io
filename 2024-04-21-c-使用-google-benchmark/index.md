# c&#43;&#43; 使用 google benchmark


在低延迟场景中，我们对性能有极致的要求。为了方便对比不同函数的开心，需要借助一些测试手段。这些测试的基本流程是：
1. 在函数调用开始是计算 rdtsc 初始值
2. 函数调用结束后，计算 rdtsc 的差值
3. 循环以上流程若干次
4. 最终得到一个平均的函数开销时间

整个测试流程其实是非常的标准化，我们完全可以利用一些框架进行快速的测试。比如我现在使用的 `google benchmark`。

&lt;!--more--&gt;

## 安装

```bash
git clone https://github.com/google/benchmark.git
git clone https://github.com/google/googletest.git benchmark/googletest
mkdir build &amp;&amp; cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE ../benchmark
```

## 测试

### 函数原型

测试有两部分构成

- 测试函数，原型为 `std::function&lt;void(benchmark::State&amp;)&gt;`，然后使用宏命令 `BENCHMARK(func)` 将其注册到主程序。`google benchmark` 会循环运行该函数，并统计相关指标
- 主程序入口：`BENCHMARK_MAIN()`

### 代码

```c&#43;&#43;
#include &lt;benchmark/benchmark.h&gt;
#include &lt;array&gt;
#include &lt;utils/nanotime.hpp&gt;

using namespace falcon;

//-----------------------------------------------------------------------------
void now_ns(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        nanotime_t::ns();
    }
}
BENCHMARK(now_ns);

void now_sysns(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        nanotime_t::sysns();
    }
}
BENCHMARK(now_sysns);

void now_ntime(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        nanotime_t::ntime();
    }
}
BENCHMARK(now_ntime);

void ns2ntime(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        auto ns = nanotime_t::ns();
        nanotime_t::ns2ntime(ns);
    }
}
BENCHMARK(ns2ntime);

void ns2str(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        auto ns = nanotime_t::ns();
        nanotime_t::ns2str(ns);
    }
}
BENCHMARK(ns2str);

void ns2str_slow(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        auto ns = nanotime_t::ns();
        nanotime_t::to_str_slow(ns);
    }
}
BENCHMARK(ns2str_slow);

void ns2datetimestr(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        auto ns = nanotime_t::ns();
        nanotime_t::ns2datetimestr(ns);
    }
}
BENCHMARK(ns2datetimestr);

void strftime(benchmark::State&amp; state)
{
    for (auto _: state)
    {
        auto ns = nanotime_t::ns();
        nanotime_t::strftime(ns);
    }
}
BENCHMARK(strftime);
//-----------------------------------------------------------------------------


///////////////////////////////////////////////////////////////////////////////
BENCHMARK_MAIN();
///////////////////////////////////////////////////////////////////////////////

```

## 结果

```
2024-04-21T13:52:30&#43;08:00
Running ./test_benchmark
Run on (20 X 4800 MHz CPU s)
CPU Caches:
  L1 Data 48 KiB (x10)
  L1 Instruction 32 KiB (x10)
  L2 Unified 1280 KiB (x10)
  L3 Unified 25600 KiB (x1)
Load Average: 1.13, 1.27, 1.62
***WARNING*** CPU scaling is enabled, the benchmark real time measurements may be noisy and will incur extra overhead.
---------------------------------------------------------
Benchmark               Time             CPU   Iterations
---------------------------------------------------------
now_ns               5.49 ns         5.49 ns    107478294
now_sysns            11.3 ns         11.3 ns     62195134
now_ntime            5.43 ns         5.43 ns    130701288
ns2ntime             5.47 ns         5.47 ns    123446131
ns2str               15.0 ns         15.0 ns     47280993
ns2str_slow          60.9 ns         60.9 ns     11144495
ns2datetimestr        460 ns          460 ns      1577622
strftime            15785 ns        15785 ns        44630
```

从上述结果可以比较清楚的知道，我们的函数调用 `ns` 的开销对比系统调用 `sysns` 是非常小的，但在转化成字符串的时候，不同的设计是有明显的差异。其中 `ns2str` 是最快的，这主要是因为我们使用来一个针对小对象设计的 `Str&lt;N&gt;` 类。


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-04-21-c-%E4%BD%BF%E7%94%A8-google-benchmark/  

