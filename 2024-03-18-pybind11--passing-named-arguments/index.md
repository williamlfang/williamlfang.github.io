# pybind11: passing named arguments


`pybind11` allow us **to expose c&#43;&#43; class/function to higher abstraction level of python programming language**, bringing high performance and flexibility into `python`.

To pass **named arguments** in `python`, it&#39;s required to specify argument names in `pybind11`&#39;s interface. In this post, I will illustrate how to do that.


&lt;!--more--&gt;

# c&#43;&#43; class

## header

```c&#43;&#43;
#include &lt;pybind11/pybind11.h&gt;
#include &lt;pybind11/embed.h&gt;
#include &lt;pybind11/stl.h&gt;
#include &lt;iostream&gt;
#include &lt;cstdlib&gt;
#include &lt;cstdio&gt;

// from SnailCore
#include &lt;util/acct_info.hpp&gt;
#include &lt;util/shm.hpp&gt;
#include &lt;util/shm_tool.hpp&gt;
#include &lt;util/shm_status.hpp&gt;
#include &lt;util/shm_struct.hpp&gt;
#include &lt;util/shmv.hpp&gt;
#include &lt;util/time_util.hpp&gt;
#include &lt;util/index_type.hpp&gt;
#include &lt;util/str_util.hpp&gt;
```

## function

```c&#43;&#43;
py::dict pybind11_read_shm_acc(const std::string&amp; shm_tag)
{
    std::unique_ptr&lt;snail::acct_info_t::shm_reader_t&gt; reader {new snail::acct_info_t::shm_reader_t(shm_tag)};

    auto total = reader-&gt;size();
    std::cout &lt;&lt; &#34;total:&#34; &lt;&lt; total &lt;&lt; std::endl;

    std::vector&lt;std::string&gt; client_id, us;
    std::vector&lt;double&gt; beg_balance, curr_balance, enabled_balance,
                        frozen_balance, deposit, margin, frozen_margin,
                        fee, frozen_fee, pos_profit, close_profit;

    for (size_t i = 0; i &lt; total; &#43;&#43;i)
    {
        auto e = reader-&gt;safe_get(i);

        client_id.emplace_back(e-&gt;client_id);
        us.emplace_back(microtime::from_count(e-&gt;us).to_zgc_str());

        beg_balance.emplace_back(e-&gt;beg_balance);
        curr_balance.emplace_back(e-&gt;curr_balance);
        enabled_balance.emplace_back(e-&gt;enabled_balance);
        frozen_balance.emplace_back(e-&gt;frozen_balance);
        deposit.emplace_back(e-&gt;deposit);
        margin.emplace_back(e-&gt;margin);
        frozen_margin.emplace_back(e-&gt;frozen_margin);
        fee.emplace_back(e-&gt;fee);
        frozen_fee.emplace_back(e-&gt;frozen_fee);
        pos_profit.emplace_back(e-&gt;pos_profit);
        close_profit.emplace_back(e-&gt;close_profit);
    }

    py::dict d;
    d[&#34;US&#34;] = us;
    d[&#34;ClientID&#34;] = client_id;
    d[&#34;BegBalance&#34;] = beg_balance;
    d[&#34;CurrBalance&#34;] = curr_balance;
    d[&#34;EnabledBalance&#34;] = enabled_balance;

    d[&#34;FrozenBalance&#34;] = frozen_balance;
    d[&#34;Deposit&#34;] = deposit;
    d[&#34;Margin&#34;] = margin;
    d[&#34;FrozenMargin&#34;] = frozen_margin;
    d[&#34;Fee&#34;] = fee;
    d[&#34;FrozenFee&#34;] = frozen_fee;
    d[&#34;PosProfit&#34;] = pos_profit;
    d[&#34;CloseProfit&#34;] = close_profit;

    return d;
}
```

## class

```c&#43;&#43;
class Account
{
public:
    Account(const std::string&amp; shm_tag, int shm_size, bool continued = false)
        : _shm_tag{shm_tag}
        , _shm_size{shm_size}
        , _continued{false}
    {
        _shm_acc.reset(new acct_info_t::shm_writer_t(
            _shm_tag, _shm_size, _continued
            ));
    }

    ~Account()
    {}

    void write(const std::string&amp; client_id,
               double beg_balance,
               double curr_balance,
               double enabled_balance,
               double frozen_balance = 0.0,
               double deposit = 0.0,
               double margin = 0.0,
               double frozen_margin = 0.0,
               double fee = 0.0,
               double frozen_fee = 0.0,
               double pos_profit = 0.0,
               double close_profit = 0.0,
               uint64_t us = 0
               )
    {
        auto e = _shm_acc-&gt;get_slot();
        if (!e)
        {
            std::cout &lt;&lt; &#34;failed to get_slot, shm is full&#34; &lt;&lt; std::endl;
            return;
        }
        e-&gt;us = us == 0 ? microtime::now().count(): us;
        copy_str(e-&gt;client_id, client_id.c_str());

        e-&gt;beg_balance = beg_balance;
        e-&gt;curr_balance = curr_balance;
        e-&gt;enabled_balance = enabled_balance;

        e-&gt;frozen_balance = frozen_balance;
        e-&gt;deposit = deposit;
        e-&gt;margin = margin;
        e-&gt;frozen_margin = frozen_margin;
        e-&gt;fee = fee;
        e-&gt;frozen_fee = frozen_fee;
        e-&gt;pos_profit = pos_profit;
        e-&gt;close_profit = close_profit;

        _shm_acc-&gt;commit(e);
    }

    py::dict read()
    {
        return pybind11_read_shm_acc(_shm_tag);
    }

private:
    std::string _shm_tag;
    int _shm_size {0};
    bool _continued {false};
    std::shared_ptr&lt;typename acct_info_t::shm_writer_t&gt; _shm_acc;
};
```

# pybind11 interface

`pybind11` provides by **MACRO** interfaces of `c&#43;&#43;`. By defining `py::arg(&#34;shm_tag&#34;)`, it&#39;s possible to pass **named arguments** from `python` into `c&#43;&#43;`&#39;s functions/classes, with default values setting.

```c&#43;&#43;
PYBIND11_MODULE(snail, m)
{
    // Function Interface
    m.def(&#34;pybind11_read_shm_acc&#34;, &amp;pybind11_read_shm_acc, R&#34;pbdoc(
        read snail::acct_info_t
    )pbdoc&#34;);

    // Class Interface
    // define Account class
    py::class_&lt;Account&gt;(m, &#34;Account&#34;)
        // ctor
        .def(py::init&lt;const std::string&amp;, int, bool&gt;(),
             py::arg(&#34;shm_tag&#34;),
             py::arg(&#34;shm_size&#34;),
             py::arg(&#34;continued&#34;) = false
             )
        .def(&#34;write&#34;, &amp;Account::write,
             py::arg(&#34;client_id&#34;),
             py::arg(&#34;beg_balance&#34;),
             py::arg(&#34;curr_balance&#34;),
             py::arg(&#34;enabled_balance&#34;),
             py::arg(&#34;frozen_balance&#34;) = 0.0,
             py::arg(&#34;deposit&#34;) = 0.0,
             py::arg(&#34;margin&#34;) = 0.0,
             py::arg(&#34;frozen_margin&#34;) = 0.0,
             py::arg(&#34;fee&#34;) = 0.0,
             py::arg(&#34;frozen_fee&#34;) = 0.0,
             py::arg(&#34;pos_profit&#34;) = 0.0,
             py::arg(&#34;close_profit&#34;) = 0.0,
             py::arg(&#34;us&#34;) = 0
             )
        .def(&#34;read&#34;, &amp;Account::read)
        ;

#ifdef VERSION_INFO
    m.attr(&#34;__version__&#34;) = MACRO_STRINGIFY(VERSION_INFO);
#else
    m.attr(&#34;__version__&#34;) = &#34;dev&#34;;
#endif
}
```

# python calling

Now we can call `c&#43;&#43;` functions/class interfaces in `python`.

```python
import pandas as pd
from wepy.cpp.snail import pybind11_read_shm_acc
from wepy.cpp.snail import Account

## Function Interface
def read_shm_acc(shm_tag:str) -&gt; pd.DataFrame:
    data = pybind11_read_shm_acc(shm_tag)
    return pd.DataFrame(data)

## Class Interface
from wepy.cpp.snail import Account
acct = Account(shm_tag = &#34;lfang_acc&#34;, shm_size = 1000)
acct.write(client_id = &#34;lfang&#34;,
            beg_balance = 1000.0,
            curr_balance = 1000.0,
            enabled_balance = 1000.0,
            deposit = 100)
df = pd.DataFrame(acct.read())
df = read_shm_acc(&#34;lfang_acc&#34;)
```

![python-calling](./python-calling.png &#34;python-calling&#34;)


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-18-pybind11--passing-named-arguments/  

