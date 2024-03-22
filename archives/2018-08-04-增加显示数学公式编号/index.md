# 增加显示数学公式编号


```r
knitr::opts_chunk$set(comment = &#39;&#39;,
                      fig.align = &#39;center&#39;,
                      eval = FALSE)
```

这两天在重新搭建博客网站，一切重新归零后，再次放空自己，也许会做得更好。

刚好翻阅到以前写的博客，原来发现自己竟然也会写一些跟数学或者金融搭边的内容。这兴许是之前一直想走学术的道路，所以得到事情都是比较偏学究型的。现在再回过头来看这些内容，虽然记忆有些模糊，不过还是能大体知道这些公式讲了什么内容，背后的金融逻辑是什么。看来以前受过的那些苦，至少没有白冤枉。

现在的问题是，我想把以前在博客中写到的数学公式，用 `AMS` 那套规则进行重新编排，也就是在引用数学公式的时候，能够自动链接到相关的式子。这个功能其实在 $\LaTex$ 里面是非常常见的。与之相对应的，我们可以使用 `MathJax` 来进行相关的处理。具体的代码如下所示。

```javascript
&lt;script type=&#34;text/javascript&#34;&gt;
    window.MathJax = {
      {{ if or .Params.mathjaxEnableSingleDollar (and .Site.Params.mathjaxEnableSingleDollar (ne .Params.mathjaxEnableSingleDollar false)) -}}
        tex2jax: {inlineMath: [[&#39;$&#39;,&#39;$&#39;], [&#39;\\(&#39;,&#39;\\)&#39;]]},
      {{ end -}}
      {{ if or .Params.mathjaxEnableAutoNumber (and .Site.Params.mathjaxEnableAutoNumber (ne .Params.mathjaxEnableAutoNumber false)) -}}
        TeX: {equationNumbers: {autoNumber: &#34;AMS&#34;}},
      {{ end -}}
      showProcessingMessages: false,
      messageStyle: &#39;none&#39;
    };
&lt;/script&gt;

&lt;script async src=&#39;https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-MML-AM_CHTML&#39;&gt;&lt;/script&gt;
```

其中，我在 `config.toml` 增加了参数设置，这样可以在博客里面指定是不是要用到 `MathJax`，毕竟启用这个功能还是需要进行额外的插件加载，难免会影响网页的载入速度。

通过以上的设置，文章内容便会自动进行数学公式编号的自动处理。如以下这个公式：

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

😆，可以愉快的更新博客了。当然，现在估计已经没有能力写大段的数学推演过程了。😭


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2018-08-04-%E5%A2%9E%E5%8A%A0%E6%98%BE%E7%A4%BA%E6%95%B0%E5%AD%A6%E5%85%AC%E5%BC%8F%E7%BC%96%E5%8F%B7/  

