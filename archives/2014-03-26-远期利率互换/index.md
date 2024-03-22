# 远期利率互换


下面我们来推导远期利率与互换利率。这两个利率变量常常在金融建模中有重要的作用。

## 远期利率互换(FRA)

远期利率互换（Forward Rate Agreement）指的是这样一种金融合约，$FRA(t; T, S)$:

- 在 $\(t\)$ 时期确定的；
- 到 $\(T\)$ 以事先约定的支付金额 $\(K\)$;
- 交割到期日为 $\(S\)$ 的债券。

其合约价值为
$$
\begin{align}
 V_{FRA} &amp;= N P(t, S) \tau(T, S) \big[ K- L(T, S) \big], \label{value-fra}
\end{align}
$$
其中，$\tau(T,S)$ 表示在两个时期的时间差，通常按照年为单位计算。$L(T,S)$ 是简单复合利率，通常指的是**LIBOR**。下面我们来求得远期即期利率$F(t;T,S)$。

&lt;!-- more --&gt;

由式子$\eqref{value-fra}$展开
$$
\begin{align}
 V_{FRA} &amp;= N \Big[ P(t, S) \tau(T, S)  K - P(t, S) \tau(T, S)  L(T, S) \Big].
\end{align}
$$
根据无套利条件，我们有以下关系成立(详细推导见：Filipovic: Term Structure Model: A Graduate Course)
$$
\begin{align}
 P(t,S) &amp;= P(t,T) P(T,S)
\end{align}
$$

同时,我们有

$$
\begin{align}
 L(T,S) :=&amp; \frac{1}{\tau(T,S)}\Big( \frac{1}{P(T,S)} - 1 \Big) \\
 \tau(T,S)L(T,S)  =&amp; \frac{1}{P(T,S)} - 1 \\
\end{align}
$$

因此，
$$
\begin{align}
 V_{FRA} &amp;= N \Big[ P(t, S) \tau(T, S)  K - P(t, S) \tau(T, S)  L(T, S) \Big] \\\
   &amp;= N \Big[ P(t, S) \tau(T, S)  K - P(t, S) \big(\frac{1}{P(T,S)} - 1 \big) \Big] \\\
   &amp;= N  \Big[ P(t, S) \tau(T, S)  K -   \big(\frac{P(t, S)}{P(T,S)} - P(t, S) \big) \Big]  \\\
   &amp;= N  \Big[ P(t, S) \tau(T, S)  K -   P(t,T)  &#43; P(t, S)  \Big]
\end{align}
$$

## 远期即期利率

在无套利的要求下，远期即期利率（Future spot rate）必需满足一个「公平价格」的原则，即使得远期利率协议的价值为零的利率水平，则
$$
\begin{align}
 V_{FRA} &amp;= 0 = N  \Big[ P(t, S) \tau(T, S)  F(t;T,S) -   P(t,T)  &#43; P(t, S)  \Big] \\\
 \Rightarrow
 F(t;T,S) &amp;= \frac{1}{\tau(T,S)} \bigg[ \frac{P(t,T)}{P(t,S)} - 1 \bigg].
\end{align}
$$

## 利率互换（IRS）

下面我们来介绍另外一种利率产品：利率互换（Interest Rate Swap,IRS):

- 固定支付：约定在未来的一个时间段内按照合同约定的比例支付，假定该水平值为 $\(K\)$
- 浮动利率：合同的另一方则需要根据合同拟采用的浮动利率水平来做对冲支付，一般而言，该浮动利率为短期简单复利的**LIBOR**, $\(L(T_{i-1}, T_{i})\)$。

我们记该时间段为 $\(\mathcal{T} = \{ T_{\alpha}, T_{\alpha&#43;1},\cdots,T_{\beta - 1}, T_{\beta}\}\)$，$\tau_{i} = \tau(T_{i-1}, T_{i}),$ 且有 $\(\mathcal{\tau} = \{ \tau_{\alpha &#43; 1}, \tau_{\alpha&#43;2},\cdots,\tau_{\beta - 1}, \tau_{\beta}\}\)$。

则我们可以得到 IRS 的合约价值为
$$
\begin{align}
 V_{IRS} &amp;= \sum_{i=\alpha&#43;1}^{\beta} D(t,T_i) N \tau_i \bigg[ K - L(T_{i-1}, T_{i}) \bigg] \label{value-irs}
\end{align}
$$

对比 $\(\eqref{value-fra}\)$ 和 $\(\eqref{value-irs}\)$，我们不难发现，利率互换可以看作来一系列的远期利率协议的总和，即
$$
\begin{align}
  V_{IRS} &amp;= \sum_{i=\alpha&#43;1}^{\beta} V_{FRA}  \\\
  &amp;= \sum_{i=\alpha&#43;1}^{\beta} N P(t, T_i) \tau_i \big[ K- F(t;T_{i-1},T_{i}) \big] \\\
  &amp;= N \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i  K - N \boxed{ \sum_{i=\alpha&#43;1}^{\beta} P(t, T_i) \tau_i F(t;T_{i-1},T_{i}) }.
\end{align}
$$

对于方框内的式子，我们可以做如下运算
$$
\begin{align*}
&amp; \boxed{ \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i F(t;T_{i-1},T_{i})  }  \\\
 =&amp; \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau(T_{i-1},T_{i}) \cdot \frac{1}{\tau(T_{i-1},T_{i})} \bigg[ \frac{P(t,T_{i-1})}{P(t,T_{i})} - 1 \bigg] \\\
 =&amp; \sum_{i=\alpha&#43;1}^{\beta} \bigg[ P(t,T_{i-1}) - P(t,T_{i}) \bigg]  \\\
 =&amp;  P(t,T_{\alpha}) - P(t,T_{\beta})
\end{align*}
$$

从而，
$$
\begin{align}
 V_{IRS} &amp;=  N \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i  K - N \bigg( P(t,T_{\alpha}) - P(t,T_{\beta}) \bigg)
\end{align}
$$

## 互换利率（Swap Rate）

同理，为来得到无套利条件，我们要求互换利率使得该利率互换的价值为零，即
$$
\begin{align}
 V_{IRS} &amp;= 0 = N \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i   S_{\alpha, \beta} (t)  - N \bigg( P(t,T_{\alpha}) - P(t,T_{\beta}) \bigg) \\\
 \Rightarrow
 S_{\alpha, \beta} (t) &amp;= \frac{ P(t,T_{\alpha}) - P(t,T_{\beta}) }{ \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i }
 \end{align}
$$

对此，我们可以这样理解：

- 首先，投资者为了对冲未来利率不确定所带来的影响，要求在未来的某个时间段内以固定的收益 $\(P(t,T_{\alpha})\)$ 提前买入债券，而将在更远的未来 $\(T_{\beta}\)$ 抛售手里的债券，价值为 $\(P(t,T_{\beta})\)$，其总和的盈余收益为 $\(P(t,T_{\alpha}) - P(t,T_{\beta})\)$。
- 在合约期间，投资者放弃的机会成本总共为 $\(\sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i\)$。
- 因此，在满足市场无套利的条件下，互换利率因该使得该投资策略的超额收益率是零，即该投掷策略的收益与互换利率持平，是故
$$
\begin{align}
 S_{\alpha, \beta} (t) &amp;= \frac{ P(t,T_{\alpha}) - P(t,T_{\beta}) }{ \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i   }
 \end{align}
$$

## 远期即期利率与远期互换利率的关系

我们知道任一两个债券价格可以通过远期即期利率产生联系，例如
$$
\begin{align}
 \frac{P(t,T_{k})}{P(t,T_{\alpha})}
 &amp;= \frac{P(t,T_{\alpha &#43; 1})}{P(t,T_{\alpha})} \cdot \frac{P(t,T_{\alpha &#43; 2})}{P(t,T_{\alpha &#43; 1})} \cdots \frac{P(t,T_{\beta})}{P(t,T_{\beta - 1})}  \\\
 &amp;= \prod_{j=\alpha&#43;1}^{k} \frac{1}{1 &#43; \tau_j F(t;T_{j-1}, T_j)}
\end{align}
$$

从而，我们也可以利用这个关系来推导得到远期即期利率与远期互换利率的关系
$$
\begin{align}
 S_{\alpha, \beta} (t) &amp;= \frac{ P(t,T_{\alpha}) - P(t,T_{\beta}) }{ \sum_{i=\alpha&#43;1}^{\beta}  P(t, T_i) \tau_i  K } \\\
 &amp;= \frac{ 1 - \frac{P(t,T_{\beta})}{P(t,T_{\alpha})} }{ \sum_{i=\alpha&#43;1}^{\beta} \tau_i \frac{P(t, T_i) }{ P(t,T_{\alpha}) } }  \\\
 &amp;= \frac{ 1 - \prod_{j=\alpha&#43;1}^{\beta} \frac{1}{1 &#43; \tau_j F(t;T_{j-1}, T_j)} }{ \sum_{i=\alpha&#43;1}^{\beta} \tau_i \prod_{j=\alpha&#43;1}^{i} \frac{1}{1 &#43; \tau_j F(t;T_{j-1}, T_j)}  }
 \end{align}
$$



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2014-03-26-%E8%BF%9C%E6%9C%9F%E5%88%A9%E7%8E%87%E4%BA%92%E6%8D%A2/  

