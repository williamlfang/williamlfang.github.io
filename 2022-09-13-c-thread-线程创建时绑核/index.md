# c&#43;&#43; thread 线程创建时绑核


在 `C&#43;&#43; std::thread` 创建的时候，绑定 `cpu` 核。

&lt;!--more--&gt;

```c&#43;&#43;
//先申明一个 thread
std::thread _thr;

#define FOR_EACH_ALGO(FUNC)                                             \
    for (auto&amp; e : _symbols)                                            \
    {                                                                   \
        auto single_eng = e.second.get();                               \
        for (auto&amp; exec : single_eng-&gt;algos())                          \
        {                                                               \
            auto algo = reinterpret_cast&lt;exec_algo_cv_alpha_t*&gt;(exec);  \
            algo-&gt;FUNC(_ac);                                            \
        }                                                               \
    }

std::thread(
[this]()
{
    const auto&amp; cfg = _shell-&gt;conf();
    if (cfg.has(&#34;auction_cpu&#34;))
    {
        int cpuid = std::stoi(cfg(&#34;auction_cpu&#34;));
        cpu_set_t cpuset;
        CPU_ZERO(&amp;cpuset);
        CPU_SET(cpuid, &amp;cpuset);
        int rtn = pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &amp;cpuset);
        if (rtn != 0)
            L_err(&#34;fail to call pthread_setaffinity_np, error rtn:&#34;, rtn);
        else
            L_inf(&#34;succ to call pthread_setaffinity_np&#34;);
        DBG({
            print_cpu_affinity(cpuid);
        })
    }

    while (true)
    {
        _ac.ntime = to_ntime(microtime().now().count());
        if (_ac.ntime &gt; _ac.end_ntime &#43; 10)
        {
            FOR_EACH_ALGO(on_auction_deactivate)
            break;
        }

        if (_ac.ntime &gt;= _ac.insert_ntime &amp;&amp; _ac.ntime &lt;= _ac.end_ntime &amp;&amp; !_ac.is_triggered)
        {
            _ac.is_triggered = true;
            FOR_EACH_ALGO(on_auction_activate)
        }
        std::this_thread::sleep_for(std::chrono::microseconds(10));
    }

    L_inf(&#34;end of engine thread, ntime:&#34;, _ac.ntime);
}).swap(_thr);

// 从主线程分离
_thr.detach();


// 在析构停止
if (_thr.joinable())
	_thr.join();
```

有一个小工具可以查看是否绑核成功

```c&#43;&#43;
void print_cpu_affinity(int coreid)
{
    cpu_set_t mask;
    long nproc;

    if (::sched_getaffinity(0, sizeof(cpu_set_t), &amp;mask) == -1)
    {
        L_inf(&#34;fail to sched_getaffinity:&#34;, coreid);
    }
    nproc = sysconf(_SC_NPROCESSORS_ONLN);

    if (coreid &lt; 0)
    {
        for (int i = 0; i &lt; nproc; i&#43;&#43;)
            L_inf(&#34;cpu afffinity core:&#34;, i, &#34;, is_set:&#34;, CPU_ISSET(i, &amp;mask));
    }
    else
    {
        L_inf(&#34;cpu afffinity core:&#34;, coreid, &#34;, is_set:&#34;, CPU_ISSET(coreid, &amp;mask));
    }
}
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-c-thread-%E7%BA%BF%E7%A8%8B%E5%88%9B%E5%BB%BA%E6%97%B6%E7%BB%91%E6%A0%B8/  

