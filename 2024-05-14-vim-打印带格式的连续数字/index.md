# vim 打印带格式的连续数字


```bash
:put = map(range(0,17), &#39;printf(&#39;&#39;[%02d]&#39;&#39;, v:val)&#39;)
```

或者使用

```bash
:for i in range(0,10)| put=printf(&#39;[%02d]&#39;, i) |endfor
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-05-14-vim-%E6%89%93%E5%8D%B0%E5%B8%A6%E6%A0%BC%E5%BC%8F%E7%9A%84%E8%BF%9E%E7%BB%AD%E6%95%B0%E5%AD%97/  

