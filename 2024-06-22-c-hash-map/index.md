# c&#43;&#43; hash map


我们在组织不同信号、不同策略时，往往需要一个容器存放对应合约标识的容器。这个容器要求具有一定的扩展性（即事先无法知晓容器大小），具有良好的插入效率、以及较高性能的查找性能。对于一般的算法，我们直接使用标准库里的哈希容器即可，这包括 `std::unordered_map`。

然后，对于一个低延迟的交易系统，我们总是对性能有着极致的渴望，尽力开发性的数据容器，提升查找性能。

- 1. 对于特化容器，如 `&lt;int, typename T&gt;`，可以更加快速的实现查找
- 2. 对于较大对象，如 `&lt;std::string, typename T&gt;`, 则尽量避免运行期的构造开销，例如在确认不同的合约标识肯定的唯一情况下，可以大胆使用类型转化，直接 `cast` 为 `int` 类型。

&lt;!--more--&gt;

## 代码测试

```c&#43;&#43;
// https://github.com/martinus/nanobench
// g&#43;&#43; -O2 -I../../include main.cpp -o m

#include &lt;cstdint&gt;
#define ANKERL_NANOBENCH_IMPLEMENT
#include &lt;nanobench.h&gt;

#include &lt;unordered_map&gt;
#include &lt;emhash/hash_table7.hpp&gt;
#include &lt;emhash/hash_table8.hpp&gt;
#include &lt;util/str_util.hpp&gt;

std::unordered_map&lt;std::string, std::string&gt; stl_map =
{
   {&#34;stl_hash&#34;, &#34;unordered_map&#34;},
   {&#34;stl_map&#34;, &#34;stl_map&#34;},
   {&#34;fmap&#34;, &#34;flat_map&#34;},
   {&#34;btree&#34;, &#34;btree_map&#34;},

   {&#34;emhash2&#34;, &#34;emhash2&#34;},
   {&#34;emhash3&#34;, &#34;emhash3&#34;},
   {&#34;emhash4&#34;, &#34;emhash4&#34;},
   {&#34;emhash5&#34;, &#34;emhash5&#34;},
   {&#34;emhash6&#34;, &#34;emhash6&#34;},
   {&#34;emhash7&#34;, &#34;emhash7&#34;},
   {&#34;emhash8&#34;, &#34;emhash8&#34;},

   {&#34;emilib2&#34;, &#34;emilib2&#34;},
   {&#34;emilib1&#34;, &#34;emilib1&#34;},
   {&#34;emilib3&#34;, &#34;emilib3&#34;},
   {&#34;martind&#34;, &#34;martin_dense&#34;},
};

emhash7::HashMap&lt;int, std::string&gt; emhash7_map =
{
   {0, &#34;unordered_map&#34;},
   {1, &#34;stl_map&#34;},
   {2, &#34;flat_map&#34;},
   {3, &#34;btree_map&#34;},

   {4, &#34;emhash2&#34;},
   {5, &#34;emhash3&#34;},
   {6, &#34;emhash4&#34;},
   {7, &#34;emhash5&#34;},
   {8, &#34;emhash6&#34;},
   {9, &#34;emhash7&#34;},
   {10, &#34;emhash8&#34;},

   {11, &#34;emilib2&#34;},
   {12, &#34;emilib1&#34;},
   {13, &#34;emilib3&#34;},
   {14, &#34;martin_dense&#34;},
};

emhash8::HashMap&lt;std::string, std::string&gt; emhash8_map =
{
   {&#34;stl_hash&#34;, &#34;unordered_map&#34;},
   {&#34;stl_map&#34;, &#34;stl_map&#34;},
   {&#34;fmap&#34;, &#34;flat_map&#34;},
   {&#34;btree&#34;, &#34;btree_map&#34;},

   {&#34;emhash2&#34;, &#34;emhash2&#34;},
   {&#34;emhash3&#34;, &#34;emhash3&#34;},
   {&#34;emhash4&#34;, &#34;emhash4&#34;},
   {&#34;emhash5&#34;, &#34;emhash5&#34;},
   {&#34;emhash6&#34;, &#34;emhash6&#34;},
   {&#34;emhash7&#34;, &#34;emhash7&#34;},
   {&#34;emhash8&#34;, &#34;emhash8&#34;},

   {&#34;emilib2&#34;, &#34;emilib2&#34;},
   {&#34;emilib1&#34;, &#34;emilib1&#34;},
   {&#34;emilib3&#34;, &#34;emilib3&#34;},
   {&#34;martind&#34;, &#34;martin_dense&#34;},
};

emhash8::HashMap&lt;int64_t, std::string&gt; emhash8_map_int64 =
{
   {snail::str2i64(&#34;stl_hash&#34;), &#34;unordered_map&#34;},
   {snail::str2i64(&#34;stl_map&#34;), &#34;stl_map&#34;},
   {snail::str2i64(&#34;fmap&#34;), &#34;flat_map&#34;},
   {snail::str2i64(&#34;btree&#34;), &#34;btree_map&#34;},

   {snail::str2i64(&#34;emhash2&#34;), &#34;emhash2&#34;},
   {snail::str2i64(&#34;emhash3&#34;), &#34;emhash3&#34;},
   {snail::str2i64(&#34;emhash4&#34;), &#34;emhash4&#34;},
   {snail::str2i64(&#34;emhash5&#34;), &#34;emhash5&#34;},
   {snail::str2i64(&#34;emhash6&#34;), &#34;emhash6&#34;},
   {snail::str2i64(&#34;emhash7&#34;), &#34;emhash7&#34;},
   {snail::str2i64(&#34;emhash8&#34;), &#34;emhash8&#34;},

   {snail::str2i64(&#34;emilib2&#34;), &#34;emilib2&#34;},
   {snail::str2i64(&#34;emilib1&#34;), &#34;emilib1&#34;},
   {snail::str2i64(&#34;emilib3&#34;), &#34;emilib3&#34;},
   {snail::str2i64(&#34;martind&#34;), &#34;martin_dense&#34;},
};

int main(int, char**)
{
    ankerl::nanobench::Bench().run(&#34;stl_map&#34;, [&amp;]()
    {
        auto itor = stl_map.find(&#34;stl_hash&#34;);
        if (stl_map.end() != itor)
        {}
    });

    ankerl::nanobench::Bench().run(&#34;emhash7_map&#34;, [&amp;]()
    {
        auto itor = emhash7_map.find(0);
        if (emhash7_map.end() != itor)
        {}

        ankerl::nanobench::doNotOptimizeAway(itor);
    });

    ankerl::nanobench::Bench().run(&#34;emhash8_map::find&#34;, [&amp;]()
    {
        auto itor = emhash8_map.find(&#34;emhash8&#34;);
        if (emhash8_map.end() != itor)
        {}

        ankerl::nanobench::doNotOptimizeAway(itor);
    });

    ankerl::nanobench::Bench().run(&#34;emhash8_map_int64::find&#34;, [&amp;]()
    {
        auto itor = emhash8_map_int64.find(snail::str2i64(&#34;emhash8&#34;));
        if (emhash8_map_int64.end() != itor)
        {}

        ankerl::nanobench::doNotOptimizeAway(itor);
    });

    ankerl::nanobench::Bench().run(&#34;emhash8_map::try_get&#34;, [&amp;]()
    {
        auto e = emhash8_map.try_get(&#34;emhash8&#34;);
        if (e)
        {}

        ankerl::nanobench::doNotOptimizeAway(e);
    });

    return 0;
}
```


## 结果对比

```bash
Warning, results might be unstable:
* CPU frequency scaling enabled: CPU 0 between 800.0 and 4,500.0 MHz
* CPU governor is &#39;powersave&#39; but should be &#39;performance&#39;
* Turbo is enabled, CPU frequency will fluctuate

Recommendations
* Use &#39;pyperf system tune&#39; before benchmarking. See https://github.com/psf/pyperf

|               ns/op |                op/s |    err% |     total | benchmark
|--------------------:|--------------------:|--------:|----------:|:----------
|               11.97 |       83,558,711.04 |    0.1% |      0.01 | `stl_map`
|                4.82 |      207,602,617.74 |    0.7% |      0.01 | `emhash7_map`
|                8.60 |      116,226,532.44 |    4.9% |      0.01 | `emhash8_map::find`
|                7.01 |      142,642,133.00 |    1.4% |      0.01 | `emhash8_map_int64::find`
|               10.67 |       93,758,813.86 |    2.0% |      0.01 | `emhash8_map::try_get`
```

从上面的结果可以看出

- 1. 对于 `&lt;int, T&gt;` 具有更加极致的性能优势
- 2. 对于 `&lt;string, T&gt;` 也是比标准库更加快速
- 3. 对于 `&lt;string, T&gt;` ，如果我们能将其转化成 `int64_t`，也是可以大幅提升查询性能



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-22-c-hash-map/  

