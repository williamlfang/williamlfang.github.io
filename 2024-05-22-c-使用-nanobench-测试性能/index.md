# c&#43;&#43; 使用 nanobench 测试性能


`nanobench` 是一个简易的代码性能测试工具，有助手我们深入理解程序运行的开销。

&lt;!--more--&gt;

## nanobench

代码仓库地址为：[nanobench](https://github.com/martinus/nanobench)。整个项目只有一个头文件，可以说十分简单了。

## 测试

```c&#43;&#43;
// https://github.com/martinus/nanobench
// g&#43;&#43; -O2 -I../../include main.cpp -o m

#define ANKERL_NANOBENCH_IMPLEMENT
#include &lt;nanobench.h&gt;

#include &lt;chrono&gt;
#include &lt;random&gt;
#include &lt;thread&gt;

int main(int, char**)
{
    uint64_t x = 1;
    ankerl::nanobench::Bench().run(&#34;x &#43;= x&#34;, [&amp;]() {
        ankerl::nanobench::doNotOptimizeAway(x &#43;= x);
    });

    ankerl::nanobench::Bench().run(&#34;sleep 10ms&#34;, [&amp;]() {
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    });

    std::random_device dev;
    std::mt19937_64 rng(dev());
    ankerl::nanobench::Bench().minEpochIterations(12045).run(&#34;random fluctuations&#34;, [&amp;]() {
        // each run, perform a random number of rng calls
        auto iterations = rng() &amp; UINT64_C(0xff);
        for (uint64_t i = 0; i &lt; iterations; &#43;&#43;i) {
            (void)rng();
        }
    });
}
```

编译以上代码，然后运行即可得到结果

```bash
Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 800.0 and 4,800.0 MHz
* Turbo is enabled, CPU frequency will fluctuate

Recommendations
* Use &#39;pyperf system tune&#39; before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |     total | benchmark
|--------------------:|--------------------:|--------:|----------:|:----------
|                0.40 |    2,485,348,469.62 |    2.6% |      0.01 | `x &#43;= x`
|       10,124,540.00 |               98.77 |    0.0% |      0.11 | `sleep 10ms`
|              237.14 |        4,216,912.81 |    4.2% |      0.04 | `random fluctuations`
```

## 对比 nanotime

```c&#43;&#43;
#include &#34;util/time_util.hpp&#34;
#include &lt;ctime&gt;
#include &lt;ratio&gt;
#define ANKERL_NANOBENCH_IMPLEMENT
#include &lt;nanobench.h&gt;

#include &lt;utils/nanotime.hpp&gt;
#include &lt;util/microtime.hpp&gt;

using namespace snail;

int main(int, char**)
{
    ankerl::nanobench::Bench().run(&#34;ns&#34;, [&amp;]()
    {
        int64_t ns {0};
        ankerl::nanobench::doNotOptimizeAway(ns = nanotime_t::ns());
    });

    ankerl::nanobench::Bench().run(&#34;microtime::us&#34;, [&amp;]()
    {
        int64_t us {0};
        ankerl::nanobench::doNotOptimizeAway(us = microtime::now().count());
    });

    ankerl::nanobench::Bench().run(&#34;ns2us&#34;, [&amp;]()
    {
        int64_t us {0};
        ankerl::nanobench::doNotOptimizeAway(us = nanotime_t::ns()/1000);
    });

    ankerl::nanobench::Bench().run(&#34;nanotime_t::us&#34;, [&amp;]()
    {
        int64_t us {0};
        ankerl::nanobench::doNotOptimizeAway(us = nanotime_t::us());
    });

    ankerl::nanobench::Bench().run(&#34;microtime::ntime&#34;, [&amp;]()
    {
        double ntime {.0};
        ankerl::nanobench::doNotOptimizeAway(ntime = to_ntime(microtime::now().count()));
    });

    ankerl::nanobench::Bench().run(&#34;nanotime_t::ntime&#34;, [&amp;]()
    {
        double ntime {.0};
        ankerl::nanobench::doNotOptimizeAway(ntime = nanotime_t::ntime());
    });

    ankerl::nanobench::Bench().run(&#34;nanotime_t::to_str&#34;, [&amp;]()
    {
        ankerl::nanobench::doNotOptimizeAway(nanotime_t::to_str(nanotime_t::ns()));
    });

    ankerl::nanobench::Bench().run(&#34;to_zgc_str&#34;, [&amp;]()
    {
        ankerl::nanobench::doNotOptimizeAway(microtime::now().to_zgc_str());
    });
}
```

```bash
Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 800.0 and 4,500.0 MHz
* CPU governor is &#39;powersave&#39; but should be &#39;performance&#39;
* Turbo is enabled, CPU frequency will fluctuate

Recommendations
* Use &#39;pyperf system tune&#39; before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |     total | benchmark
|--------------------:|--------------------:|--------:|----------:|:----------
|                6.67 |      149,864,077.86 |    2.1% |      0.01 | `ns`
|               15.90 |       62,902,027.27 |    1.9% |      0.01 | `microtime::us`
|                7.24 |      138,174,331.20 |    0.5% |      0.01 | `ns2us`
|                7.29 |      137,255,469.22 |    1.6% |      0.01 | `nanotime_t::us`
|               23.39 |       42,750,704.21 |    0.3% |      0.01 | `microtime::ntime`
|               12.31 |       81,232,849.21 |    0.2% |      0.01 | `nanotime_t::ntime`
|               46.80 |       21,366,089.17 |    2.6% |      0.01 | `nanotime_t::to_str`
|              393.31 |        2,542,506.82 |    2.0% |      0.01 | `to_zgc_str`
```

## 关于系统 cpu 性能

可以开启高性能模式。参考[Linux 设置 cpu 高性能performance模式](https://williamlfang.github.io/2023-06-18-linux-%E8%AE%BE%E7%BD%AE-cpu-%E9%AB%98%E6%80%A7%E8%83%BDperformance%E6%A8%A1%E5%BC%8F/)

```bash
sudo apt-get install cpufrequtils
sudo apt-get install sysfsutils

## 查看 CPU 状态
cpufreq-info
## 查看频率信息
cpupower frequency-info

## 把 cpu 调整到性能模式
sudo cpufreq-set -g performance

## 通过设置默认模式，防止重启后恢复
sudo vim  /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
## 填写
performance

## 或者全局设置
sudo vim /etc/default/cpufrequtils
GOVERNOR=&#34;performance&#34;

## 重启配置生效
systemctl restart cpufrequtils
```

## 关于 rdtsc

参考文章：[细说RDTSC的坑](http://www.wangkaixuan.tech/?p=901)

```c&#43;&#43;
uint64_t rdtsc()
{
    uint64_t a, d;
    __asm__ volatile(&#34;rdtsc&#34; : &#34;=a&#34;(a), &#34;=d&#34;(d));
    return (d &lt;&lt; 32) | a;
}
```

我们还可以直接使用 `gcc` 内置的函数。参考 StackOverflow [How to count clock cycles with RDTSC in GCC x86](https://stackoverflow.com/questions/9887839/how-to-count-clock-cycles-with-rdtsc-in-gcc-x86)

```c&#43;&#43;
/* rdtsc */
extern __inline unsigned long long
__attribute__((__gnu_inline__, __always_inline__, __artificial__))
__rdtsc (void)
{
    return __builtin_ia32_rdtsc ();
}
```

## 查看 CPU 是否支持 const tsc

```bash
cat /proc/cpuinfo |ag constant_tsc
```

![const tsc](./const_tsc.png &#34;const tsc&#34;)

## Ref

- [几种取时间的方法（附代码）](http://www.wangkaixuan.tech/?p=840)
- [simplx](https://github.com/Tredzone/simplx)


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-22-c-%E4%BD%BF%E7%94%A8-nanobench-%E6%B5%8B%E8%AF%95%E6%80%A7%E8%83%BD/  

