# 庖丁解牛之 Ito 公式


## 股票价格建模

假设股票价格的变化服从以下运动方程（随机微分方程，SDE）：
$$
\begin{align}
 d S_t = \mu S_t dt &#43; \sigma S_t dW_t,
\end{align}
$$
其中 `\(dW_t\)` 是一个（连续的）**Brownian motion**，$W_t \sim \mathcal{N} (0, t)$。等价的，我们可以得到股票价格变化率：
$$
\begin{align}
 d \ln S_t = \frac{ d S_t }{ S_t } = \mu dt &#43; \sigma dW_t.
\end{align}
$$

下面我们来推导股票价格 `\(S_t\)` 的动态方程，这主要是使用著名的 **Ito 公式**。过于理论的东西我在这里不推导了，主要是利用一个简单的例子来说明如何使用 **Ito 公式** 解 **SDE** 类问题。

&lt;!-- more --&gt;

## Ito 公式求解

首先，令 `\(Y_t = ln S_t\)`，由简单的偏微分求导得到
$$
\begin{align}
\frac{ \partial Y }{ \partial t} &amp;= 0  \\
\frac{ \partial Y }{ \partial S} &amp;= \frac{ 1 }{ S }  \\
\frac{ \partial^2 Y }{ \partial S^2} &amp;= - \frac{ 1 }{ S^2 }  \\
\end{align}
$$
则根据 **Ito 公式**，我们可以推出以下方程
$$
\begin{align}
 d \ln S_t = d Y_t
  &amp;= \frac{ \partial Y }{ \partial t} dt &#43; \frac{ \partial Y }{ \partial S} dS_t &#43; \frac{1}{2} \frac{ \partial^2 Y }{ \partial S^2} dS_t dS_t \nonumber\\
  &amp;= 0 · dt &#43; \frac{ 1 }{ S_t } dS_t - \frac{1}{2} · \frac{ 1 }{ S_t^2 } dS_t dS_t \nonumber\\
  &amp;=  \frac{ 1 }{ S_t } · S_t · (\mu dt &#43; \sigma dW_t) - \frac{1}{2} · \frac{ 1 }{ S_t^2 } · \sigma^2 S_t^2 dt
 \nonumber\\
  &amp;= (\mu - \frac{1}{2} \sigma^2) dt &#43; \sigma dW_t. \\
\end{align}
$$
两边求积分，得到如下式子
$$
\begin{align}
 \int_{0}^{t} d \ln S_u = \int_{0}^{t} d Y_u
    &amp;= \int_{0}^{t}  (\mu - \frac{1}{2} \sigma^2) du &#43; \int_{0}^{t}  \sigma dW_u \\
\Rightarrow \ln S_t - \ln S_0 = Y_t - Y_0 &amp;= (\mu - \frac{1}{2} \sigma^2) t &#43; \int_{0}^{t}  \sigma dW_u.
\end{align}
$$
我们知道，**Brownian Motion** 表示在一定时间段内随机游走走过的路径，并且如果我们假定在初始阶段为 `\(W(0)=0\)`，那么，上面等式的最后一项是
$$
\begin{align}
\int_{0}^{t}  \sigma dW_u &amp;= \sigma (W_t - W_0 ) = \sigma W_t.
\end{align}
$$

因此，我们有
$$
\begin{align}
 \ln S_t - \ln S_0 = Y_t - Y_0 &amp;= (\mu - \frac{1}{2} \sigma^2) t &#43; \sigma W_t \nonumber\\
  \Rightarrow Y_t &amp;= Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t &#43; \sigma W_t \nonumber\\
 \Rightarrow S_t &amp;= S_0 · \exp\{  (\mu - \frac{1}{2} \sigma^2) t &#43; \sigma W_t  \}.
\end{align}
$$

## 几何布朗运动

我们知道，对于任何一个正态分布做线性转换后依然服从正态分布。由于布朗运动 `\(W_t \sim \mathcal{N} (0, t)\)`，则
$$
\begin{align}
  Y_t &amp;= Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t &#43; \sigma W_t \nonumber\\
\Rightarrow E[Y_t|Y_0] &amp;= E[ Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t &#43; \sigma W_t] \nonumber\\
                       &amp;= Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t &#43; \underbrace{E[\sigma W_t]}_{0} = Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t \\
\Rightarrow Var[Y_t|Y_0] &amp;= Var [\sigma W_t] = \sigma^2 Var(Wt) = \sigma^2 ·t \nonumber\\
\Rightarrow Y_t &amp;\sim \mathcal{N}(  Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t, \sigma^2 t  ) \label{gbm_norm}
\end{align}
$$

那么，$\ln S_t = Y_t$ 则服从 **正态分布**，则 `\(S_t = e^{Y_t}\)`服从 *log-normal disctribution*，即 `\(\ln S_t \sim \mathcal{N} (E[S_t], Var[S_t])\)`.

下面我们来推导 `\(S_t\)` 的分布特征。

### Moment Generation Function

我们知道，对于对任何一个随机变量建模，往往需要假设该变量服从某一类随机过程，而这个随机过程由分布函数（distribution function）给定。可是，有些时候，我们并不一定需要知道整个分布函数的具体形式，而只是关注该随机变量的几个「统计特征」，如一阶矩、二阶矩等。下面要介绍的「矩条件生成函数」就针对这种情况提出的。随机变量的矩条件可以在 **Moment Generation Function** (MGF) 十分方便的推导出来。比如，对于正态分布，我们只需要知道一阶矩和二阶矩条件就可以对变量做统计推断（method of moment, MM，还有更一般的 GMM）。

对于一个**可测空间** `\((\Omega, \mathcal{F}, P)\)`，随机变量 `\(X \in \sigma(\mathcal{F})\)` 的 MGF 定义为
$$
\begin{align}
 M_{X}(\tau) &amp;= E[ e^{x\tau}] = \int_{\Omega} e^{x(\omega)\tau} dP(\omega)
\end{align}
$$
其任一 `\(m-\)` 阶的矩公式可以对 `\(\tau\)` 在 `\(\tau = 0\)` 处求 `\(m\)` 次导数得到
$$
\begin{align}
  \frac{\partial M_{X}(\tau)}{\partial \tau}|_{\tau = 0}
  &amp;=   \frac{\partial}{\partial \tau} E[ e^{x\tau}] |_{\tau = 0}
  =  E[ x · e^{x\tau}] |_{\tau = 0}    \nonumber\\
  &amp;= E[x] \\
   \frac{\partial ^2 M_{X}(\tau)}{\partial \tau ^2 }|_{\tau = 0}
 &amp;= E[x^2] \\
 \frac{\partial ^m M_{X}(\tau)}{\partial \tau ^m }|_{\tau = 0}
 &amp;= E[x^m]
\end{align}
$$
特别的，对于一个正态分布，$X \sim \mathcal{N}(\mu, \sigma^2)$，有
$$
\begin{align}
  M_{X}(\tau) &amp;= E[ e^{x\tau}] = \exp\{ \mu \tau &#43; \frac{1}{2} \sigma^2 \tau^2 \}
\end{align} \\
$$

### 期望与方差

这个特征对于求一个「对数正态分布」十分有用。由$\eqref{gbm_norm}$
$$
\begin{align}
  Y_t &amp;\sim \mathcal{N}(  Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t, \sigma^2 t  )
\end{align}
$$
则其 MGF 为
$$
\begin{align}
 M_{Y}(\tau) &amp;= E[e^{y\tau}] = \exp\{ \tilde{\mu} \tau &#43; \frac{1}{2} \tilde{\sigma}^2 \tau^2 \},
\end{align}
$$
其中，$\tilde{\mu} = Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t$，$\tilde{\sigma}^2= \sigma ^2 t$ .

因此，我们可以得到如下公式
$$
 \begin{align}
  E[S^{\tau}] &amp;=  E[e^{y\tau}]  = \exp\{ \tilde{\mu} \tau &#43; \frac{1}{2} \tilde{\sigma}^2 \tau^2 \}
 \end{align}
$$

即，期望可以表示为
$$
 \begin{align}
  E[S_t] &amp;=  E[e^{y\tau}]|_{\tau = 1}  = \exp\{ \tilde{\mu}  &#43; \frac{1}{2} \tilde{\sigma}^2  \}  \nonumber\\
        &amp;= \exp\{ Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t &#43; \frac{1}{2} \sigma^2 t  \} \nonumber\\
        &amp;= S_0 · e^{\mu t } \\
\end{align}
$$

$$
 \begin{align}
  E[S^2] &amp;= E[e^{y\tau}]|_{\tau = 2}  = \exp\{ 2 \tilde{\mu}  &#43; 2 \tilde{\sigma}^2  \} \nonumber\\
  &amp;= \exp\{ 2 [Y_0 &#43; (\mu - \frac{1}{2} \sigma^2) t ] &#43; 2 \sigma^2 t \}   \nonumber\\
  &amp;= S_0^2 · \exp\{ 2 \mu t &#43; \sigma^2 t\}
 \end{align}
$$

因此，$S_t$ 的方差可以表示为
$$
 \begin{align}
  Var[S_t]
  &amp;=   E[S^2] -  ( E[S] )^2 \nonumber\\
  &amp;= S_0^2 · \exp\{ 2 \mu t &#43; \sigma^2 t\} - S_0^2 · \exp\{ 2 \mu t \} \nonumber\\
  &amp;= S_0^2 · e^{ 2 \mu t } · (e^{ \sigma^2 t - 1 })
 \end{align}
$$

## O-U Process

其实，我们同样可是使用这种方法来解一类更加广义的随机过程——O-U过程。这个过程为
$$
 \begin{align}
  d X(t) &amp;=  - \kappa (X(t) - \theta) d t &#43; \sigma dW(t). \label{ou}
 \end{align}
$$
在式子$\eqref{ou}$中，我们注意到参数 `\((\kappa, \theta, \sigma)\)` 决定了整个随机过程的特征：

- `\(\kappa\)`：是随机过程的「变化率」，即控制了整个随机过程向长期均值回归的快慢程度;
- `\(\theta\)`：代表了随机过程的「长期均值水平」，O-U 过程最显著的特征是其具有了「均值回复」，即在变化率 `\(\kappa\)` 的控制下变量趋于稳定的状态。这个在利率期限结构建模中经常使用，如最早的 Vasicek 利率模型就是一个典型的 O-U 过程。
- `\(\sigma\)`：表示随机过程的「瞬时方差」。


下面我们来求解显示解。

首先对方程$\eqref{ou}$在区域 `\([0, t]\)` 进行积分得到
$$
  \begin{align}
   \int_{0}^{t} d X(u) &amp;= -\int_{0}^{t} \kappa X(u) du &#43; \int_{0}^{t}  \kappa \theta du &#43;  \int_{0}^{t}  \sigma  dW(u),
  \end{align}
$$
然后两边同时乘以 `\(e^{\kappa u}\)` 得到
$$
\begin{align}
    \int_{0}^{t} e^{\kappa u} d X(u) &amp;= -\int_{0}^{t} \kappa X(u) e^{\kappa u} du &#43; \int_{0}^{t}  \kappa \theta e^{\kappa u} du &#43;  \int_{0}^{t} \sigma  e^{\kappa u} dW(u). \label{ou-int}
\end{align}
$$
我们分开求解等式两边。

- 先是对左边进行**分步积分**得到
$$
 \begin{align}
   LHS &amp;= e^{\kappa u} X(u) |_{u=0}^{t} - \int_{0}^{t} \kappa X(u) e^{\kappa u} du \nonumber \\
   &amp;= e^{\kappa t } X(t) - X(0) - \int_{0}^{t} \kappa X(u) e^{\kappa u} du . \label{lhs}
 \end{align}
$$

- 同样的，我们也可以求出右边式子
$$
 \begin{align}
   RHS &amp;= - \int_{0}^{t} \kappa X(u) e^{\kappa u} du &#43; \int_{0}^{t} \theta de^{\kappa u} &#43; \int_{0}^{t}  \sigma  e^{\kappa u} dW(u) \nonumber\\
   &amp;= - \int_{0}^{t} \kappa X(u) e^{\kappa u} du &#43; \theta (e^{\kappa t} - 1) &#43; \int_{0}^{t}  \sigma  e^{\kappa u} dW(u)  \label{rhs}
 \end{align}
$$

- 对比$\eqref{lhs}$与$\eqref{rhs}$，
$$
 \begin{align}
   e^{\kappa t } X(t) - X(0) - \int_{0}^{t} \kappa X(u) e^{\kappa u} du
   &amp;=
   -\int_{0}^{t} \kappa X(u) e^{\kappa u} du &#43; \theta (e^{\kappa t} - 1) &#43; \int_{0}^{t}  \sigma  e^{\kappa u} dW(u)  \nonumber \\
   e^{\kappa t } X(t) - X(0)
   &amp;=
   \theta (e^{\kappa t} - 1) &#43; \int_{0}^{t}  \sigma  e^{\kappa u} dW(u)   \nonumber \\
\Rightarrow
    X(t)  &amp;= e^{-\kappa t} (X(0)-\theta) &#43; \theta &#43; \int_{0}^{t}  \sigma  e^{-\kappa (t-u)} dW(u)  \label{oup} \\
 \end{align}
$$

### 期望
由$\eqref{oup}$得到
$$
 \begin{align}
  X(t)  &amp;= e^{-\kappa t} (X(0)-\theta) &#43; \theta &#43; \int_{0}^{t}  \sigma  e^{-\kappa (t-u)} dW(u) . \nonumber
 \end{align}
$$
则其期望可以表示为
$$
 \begin{align}
   E[X(t)|X(0)] &amp;= E[ e^{-\kappa t} (X(0)-\theta) &#43; \theta &#43; \int_{0}^{t}  \sigma  e^{-\kappa (t-u)} dW(u) ] \nonumber \\
   &amp;= e^{-\kappa t} (X(0)-\theta) &#43; \theta. \label{exp}
 \end{align}
$$
最后一项由 `\(W_t \sim \mathcal{N} (0, t)\)` 得到。

利用$\eqref{exp}$，我们可以求出 O-U 过程在长期的一个均值回复项，即
$$
 \begin{align}
   \lim_{t \rightarrow &#43; \infty } e^{-\kappa t} (X(0)-\theta) &#43; \theta = \theta.
 \end{align}
$$

### 协方差

任一区间内 `\([s,t]\)` 协方差可以由以下求出。
$$
 \begin{align}
   cov(X_s, X_t)
   &amp;= E[ (X_s-E[X_s])·(X_t-E[X_t])] \nonumber\\
   &amp;= \sigma^2 E\bigg[
        \int_{0}^{s}    e^{-\kappa (s-u)} dW(u) ·
         \int_{0}^{t}   e^{-\kappa (t-v)} dW(v)
            \bigg] \label{cov}
 \end{align}
$$

这里我们需要使用到两个基本的概念

- 布朗运动的「独立增量」(indepdent increasement)，即任何一个布朗运动在不同期间内的增量是相互独立的，即对于区间 `\([0,t], 0 \leq t_0 \leq t_1 \leq \cdots \leq t_n \leq t\)`, `\(W(t_1)-W(t_0)\)`, `\(W(t_2)-W(t_1)\)`,$\cdots$, `\(W(t_n)-W(t_{n-1})\)` 是相互独立的增量过程。

- **Ito Isometry** 性质：即对于一个布朗运动的独立增量，$dW_t$，有关其多项式有如下性质
$$
 \begin{align}
   E\bigg[ \bigg( \int_{0}^{t} F(u) dW(u) \bigg)^2\bigg]
   &amp;= \int_{0}^{t} E \big[ F^2(u) \big] du
 \end{align}
$$

利用这两个性质，对于$\eqref{cov}$，如果 `\(s \geq t\)` (反之，$s \leq t$，则令二者调换，即 `\(t=\min\{s,t\}\)`)，我们有
$$
 \begin{align}
   cov(X_s, X_t)
   &amp;=  \sigma^2
   E\bigg[
        \bigg( \int_{0}^{t}  e^{-\kappa (s-u)} dW(u)  &#43; \int_{t}^{s}   e^{-\kappa (s-u)} dW(u)
        \bigg)
        ·
         \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
            \bigg] \\
    &amp;=  \sigma^2
    E\bigg[
          \int_{0}^{t}  e^{-\kappa (s-u)} dW(u)  · \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
           \nonumber \\
        &amp; \qquad &#43; \int_{t}^{s}   e^{-\kappa (s-u)} dW(u) · \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
            \bigg] \\
     &amp;=  \sigma^2 \Bigg\{
     E\bigg[
          \int_{0}^{t}  e^{-\kappa (s-u)} dW(u)  · \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
          \bigg]
          \nonumber \\
    &amp; \qquad &#43;  E\bigg[
          \int_{t}^{s}   e^{-\kappa (s-u)} dW(u) · \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
          \bigg]
    \Bigg\}，    \label{cov1}   \\
 \end{align}
$$

- 对于第一项我们需要使用 **Ito Isometry** 性质,
$$
 \begin{align}
   E\bigg[
          \int_{0}^{t}  e^{-\kappa (s-u)} dW(u)  · \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
          \bigg]
    &amp;=
    E\bigg[
          \int_{0}^{t}  e^{-\kappa (s-u)} · e^{-\kappa (t-u)}  du
          \bigg] \\
 \end{align}
$$

- 而第二向可以由布朗运动的独立增量性质消除，
$$
 \begin{align}
   &amp; E\bigg[
          \int_{t}^{s}   e^{-\kappa (s-u)} dW(u) · \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
          \bigg] &amp; \nonumber \\
    =&amp; E\bigg[
          \int_{t}^{s}   e^{-\kappa (s-u)} dW(u)
          \bigg]
          ·
       E\bigg[
         \int_{0}^{t}  e^{-\kappa (t-v)} dW(v)
          \bigg]
    = 0
 \end{align}
$$
因此，方程$\eqref{cov1}$变为
$$
 \begin{align}
   cov(X_s, X_t)
   &amp;= \sigma^2 \Bigg\{
     E\bigg[
          \int_{0}^{t}  e^{-\kappa (s-u)} · e^{-\kappa (t-u)}  du
          \bigg]
     \Bigg\}   \label{cov2} \\
  &amp;= \sigma^2 \Bigg\{
      e^{-\kappa (s&#43;t)}
      E\bigg[
          \int_{0}^{t}  e^{2\kappa u}  du
          \bigg]
   \Bigg\}
    = \sigma^2 ·
      e^{-\kappa (s&#43;t)}
      ·
      \frac{1}{2\kappa}
      ·  e^{2\kappa u}\bigg|_{u=0}^{t} \\
    &amp;= \frac{\sigma^2}{2\kappa} e^{-\kappa (s&#43;t)} · \Bigg( e^{2\kappa t} -1 \Bigg).
 \end{align}
$$
也就是说，对于任何一个协方差，我们都有
$$
 \begin{align}
   cov(X_s, X_t)
   &amp;= \frac{\sigma^2}{2\kappa} e^{-\kappa (s&#43;t)} · \Bigg( e^{2\kappa · \min\{s,t\} } -1 \Bigg).
 \end{align}
$$

### 方差

方差也就是0阶协方差，
$$
 \begin{align}
   Var(X_t)
   &amp;= cov(X_t, X_t)
   = \frac{\sigma^2}{2\kappa} e^{-\kappa (t&#43;t)} · \Bigg( e^{2\kappa · \min\{t,t\} } -1 \Bigg) \nonumber\\
   &amp;= \frac{\sigma^2}{2\kappa} \Bigg( 1 - e^{ -2\kappa t } \Bigg)
 \end{align}
$$


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2014-03-16-%E5%BA%96%E4%B8%81%E8%A7%A3%E7%89%9B%E4%B9%8B-ito-%E5%85%AC%E5%BC%8F/  

