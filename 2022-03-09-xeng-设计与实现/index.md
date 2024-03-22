# xeng 设计与实现


在金融市场交易中，我们可以获取两类行情：

- 基于订单、成交的逐笔行情
- 对订单薄进行切片得到的快照行情

我们可以利用以上数据复原订单薄「orderbook」。

&lt;!--more--&gt;

## 利用 TtickByTick

## 利用 Snapshot

### Talk is cheap

&gt; sliu:
&gt;
&gt; 这样啊，就是之前每一个没有trade的价位上，我们本来算了一个max(snap1_vol-snap2_vol,0)视作cxl，现在新加一个max(snap2_vol-snap1_vol,0)视作order吧
&gt;
&gt; 这样一来，假如一个价位的order从10到了20，那么我们就用一个10的order去消一下outstanding

### Show me code

1. 计算两个 `snaps1`、`snaps2` 之间的 `vwap`

   - 设 $\Delta Volume = Volume_2 - Volume_1$

   - 如果 $\Delta Volume = 0$，

     &gt; sliu:
     &gt;
     &gt; **计算 cxl 的订单，刷新一下ob，然后用 cxl**
     &gt;
     &gt; 噢！有一个点，我忽略了，如果完全没有Turnover，但是挂单超过了我们的outstanding，其实也应该撮合的
     &gt;
     &gt; ![如果 vwap = 0](/post/2022-03-09-xeng-设计与实现/vwap_0.png)
     &gt;
     &gt; ![如果 vwap = 0](/post/2022-03-09-xeng-设计与实现/vwap_outstanding.png)

   - 否则$\Delta Volume \neq 0$，需要计算 `vwap`

   $$
   \begin{align}
   vwap &amp;= \frac{\Delta Turnover}{\Delta Volume} \newline        &amp;= \frac{Turnover_2 - Turnover_1}{Volume_2 - Volume_1}\end{align}
   $$

2. 我们可以对比 `vwap` 与 `snaps1.ap1`，来判断这是**主动买方向**还是**主动卖方向**（用来提取 `snap1` 的价格）。区分主动买/主动卖的目的，在于找到哪些是 `full_traded`，哪些是 `partial_traded` 的情况

    - if $vwap \gt snaps1.ap1$，判断为**主动买**，需要找到**卖单序列**（`snaps.ask_px`）:

        - `full` ：从 `snaps1.ask_px[0]` 开始直到 `snaps1.ask_px[i] &lt; vwap`
        - `part`：`snaps1.ask_px[j] &gt; vwap` 且不在 `snap2.ask_px` 里面的，从 `snaps1.ask_px[j] &gt; vwap` 开始处理，遇到 `snaps2.ask_px[j] &gt;= snaps1.ask_px[i]` 且  `snaps2.ask_qty[j] != 0` 就停止搜索；如果没有找到，使用最后遇到的 `snaps2.ask_qty[j]`

    - else if $snaps1.bp1 \lt vwap \lt snaps.ap1$，特殊情况，发现序列都是空的，使用 **`snap1.bp1`** 与 **`snaps.ap1`**，然后转化成第一种情况处理

    - else if $vwap \lt snaps1.bp1$，判断为**主动卖**，需要找到**买单序列**（`snaps1.bid_px`）:

        - `full` ：从 `snaps1.bid_px[i] &lt; vwap` 开始直到 `snaps1.bid_px[0]`
        - `part`：`snaps1.ask_px[j] &gt; vwap` 且不在 `snap2.ask_px` 里面的，从 `snaps1.bid_px[j] &lt; vwap` 开始处理，遇到 `snaps2.bid_px[j] &lt;= snaps1.bid_px[i]` 且  `snaps2.bid_qty[j] != 0` 就停止搜索；如果没有找到，使用最后遇到的 `snaps2.bid_qty[j]`

3. 我们知道，

    - 对于 `full_trade` 的序列，已经推算出 `trade` 与 `cxl` 的情况 (`solve_equation`)

    - 但是对于 `part_trade` 的序列，我们还需要使用 `snaps2` 上面的**同一个价格档位的 qty** 来计算从 `snaps1` 变成 `snaps2` 过程中发生的 `cxl_qty`

    - 标记为 `part_snaps_qty_vec`，且记录

        ```c&#43;&#43;
        if (part_snaps_qty_vec.empty())
        {
            rsp.cxl_qty = std::max(qty_vec[i] - rsp.trade_qty, 0);
        }
        else
        {
            rsp.cxl_qty = std::max(qty_vec[i] - rsp.trade_qty - part_snaps_qty_vec[i], 0);
        }
        ```

4. 这样，我们一共有

```c&#43;&#43;
using px_qty_t = std::pair&lt;double/*px*/, int/*qty*/&gt;;

std::vector&lt;px_qty_t&gt; full_vec;
std::vector&lt;px_qty_t&gt; part_vec;

// NOTE[20220317 14:57:42]: 用来确定对应价位上面的 cxl 数量
std::vector&lt;int&gt; part_snaps_qty_vec;

double full_vwap {.0};
int    full_idx  { 0};
int    part_vwap {.0};
int    part_idx  { 0};
```

虚拟的 `rsp` 数据结构为

```c&#43;&#43;
struct fake_rsp_t
{
    double px     {.0};
    int order_qty {0}; // 订单的挂单数量，需要乘以 q 表示这个订单有多少概率排在我们订单前面
    int trade_qty {0}; //
    int cxl_qty   {0}; //
    int leaves_qty   {0}; // 前面一个 snaps 剩余的数量，表示一定会排在我们订单前面的数量
    bool is_long  {false};

    friend std::ostream&amp; operator&lt;&lt;(std::ostream&amp; os, const fake_rsp_t&amp; rsp)
    {
        os &lt;&lt; &#34;px:&#34; &lt;&lt; rsp.px
           &lt;&lt; &#34;, order_qty:&#34; &lt;&lt; rsp.order_qty
           &lt;&lt; &#34;, trade_qty:&#34; &lt;&lt; rsp.trade_qty
           &lt;&lt; &#34;, cxl_qty:&#34; &lt;&lt; rsp.cxl_qty
           &lt;&lt; &#34;, leaves_qty:&#34; &lt;&lt; rsp.leaves_qty
           &lt;&lt; std::endl;
        return os;
    }
};
```

5. 撮合

    &gt; 撮合的前半部分就是生成这些东西来和outstanding撮合
    &gt; 后半部分是我们自己的order进来，先和新ob撮合，生成rsp和outstanding撮合
    &gt; 如果完了还有剩的，就计算一个wait然后进入outstanding
    &gt; 那个时候的wait就是max{0, vol_1 - trade - cxl} &#43; max{0, vol_2 - max{0, vol_1 - trade - cxl}} * q
    &gt; max{0, vol_1 - trade - cxl} &#43; max{0, vol_2 - max{0, vol_1 - trade - cxl}} * q
    &gt; 里面其实 max{0, vol_2 - max{0, vol_1 - trade - cxl}}
    &gt; 就是你这里的order吧
    &gt; lfang：leaves_qty 相当于表示上次还剩多少肯定排在我们订单前面，然后再用一个 q 的概率表示在新 snaps2 上面的订单排在前面的可能性
	&gt; 所以 wait_qty = rsp.leaves_qty &#43; rsp.order_qty * q



## Ref

- [How to manage a local order book correctly](https://binance-docs.github.io/apidocs/spot/en/#diff-depth-stream)
  1. Open a stream to **wss://stream.binance.com:9443/ws/bnbbtc@depth**.
  2. Buffer the events you receive from the stream.
  3. Get a depth snapshot from **https://api.binance.com/api/v3/depth?symbol=BNBBTC&amp;limit=1000** .
  4. Drop any event where `u` is &lt;= `lastUpdateId` in the snapshot.
  5. The first processed event should have `U` &lt;= `lastUpdateId`&#43;1 **AND** `u` &gt;= `lastUpdateId`&#43;1.
  6. While listening to the stream, each new event&#39;s `U` should be equal to the previous event&#39;s `u`&#43;1.
  7. The data in each event is the **absolute** quantity for a price level.
  8. If the quantity is 0, **remove** the price level.
  9. Receiving an event that removes a price level that is not in your local order book can happen and is normal.


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-03-09-xeng-%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%AE%9E%E7%8E%B0/  

