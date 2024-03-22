# feather:在R与python之间共享数据存储格式






# 更新

看新闻报道，`feather` 现在正式升级为 `Apache Arrow` 项目成员，得到业内大佬们的提携，性能上更加优秀。

项目地址：[Apache Arrow](https://github.com/williamlfang/arrow)

- Python 的版本现在改成了 `pyarrow`
- R 的版本改成了 ``arrrow`



```bash
## python 安装


## R 安装
install.packages(&#34;arrow&#34;)
arrow::install_arrow()
```





# 使用 R 与 Python 共同的数据存储文件格式：feather

项目的详细介绍在github: https://github.com/wesm/feather

## python

```bash
pip install feather-format
```

## R

```r
install.packages(&#34;feather&#34;)
```


```bash
%%bash
ls -alh /home/william/20200414
```

    total 2.4G
    drwx------   2 william william 4.0K Apr 15 17:57 .
    drwxr-xr-x 107 william william  12K Apr 15 17:57 ..
    -rw-r--r--   1 william william 6.4K Apr 14 08:37 commission.csv
    -rw-r--r--   1 william william 1.6M Apr 14 08:37 instrument.csv
    -rw-r--r--   1 william william 2.4G Apr 14 15:32 tick.csv


## 性能测试: python


```python
import pandas as pd
import numpy as np
import feather
```


```python
%time tick_csv = pd.read_csv(&#34;/home/william/20200414/tick.csv&#34;)
for col in tick_csv.columns[6:]:
    tick_csv[col] = tick_csv[col].astype(float)
```

    &lt;string&gt;:2: DtypeWarning: Columns (6,7,13,14,15,16,17,19) have mixed types.Specify dtype option on import or set low_memory=False.


    CPU times: user 37.1 s, sys: 3.31 s, total: 40.4 s
    Wall time: 41.1 s



```python
tick_csv.head(10)
```



```python
len(tick_csv)
```




    13373363




```python
## 写文件相对比较慢，因为要做序列化
%time tick_csv.to_feather(&#34;/home/william/20200414/tick.feather&#34;)
```

    CPU times: user 3.26 s, sys: 1.49 s, total: 4.75 s
    Wall time: 6.13 s



```python
## 读文件非常快
%time tick_feather = pd.read_feather(&#34;/home/william/20200414/tick.feather&#34;)
```

    CPU times: user 4.34 s, sys: 1.51 s, total: 5.85 s
    Wall time: 5.15 s



```python
tick_feather.head(10)
```




```python
len(tick_feather)
```




    13373363



## 性能测试: R


```python
%load_ext rpy2.ipython
```


```r
%%R
library(data.table)
```


```r
%%R
system.time({dt &lt;- fread(&#39;/home/william/20200414/tick.csv&#39;, verbose = FALSE, showProgress = FALSE)})
```

       user  system elapsed
     63.591   1.474  18.146



```r
%%R
head(dt)
```


```r
%%R
system.time({dt_feather &lt;- feather::read_feather(&#39;/home/william/20200414/tick.feather&#39;)})
```

       user  system elapsed
      8.342   0.761   9.112



```r
%%R
head(dt_feather)
```



```r
%%R
system.time({
    fst::write_fst(dt, &#34;/home/william/20200414/tick.fst&#34;)
})
```

       user  system elapsed
     10.718   1.065   4.356



```r
%%R
system.time({
    dt_fst &lt;- fst::read_fst(&#34;/home/william/20200414/tick.fst&#34;, as.data.table = TRUE)
})
```

       user  system elapsed
      6.918   0.751   5.671


# R -&gt; Python


```python
from rpy2.robjects import r, pandas2ri
pandas2ri.activate()
```


```r
%%R
r_data = data.table(x = 1, y = 2)
```


```python
r.r_data
```




&lt;div&gt;
&lt;style scoped&gt;
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }


    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }

&lt;/style&gt;

&lt;table border=&#34;1&#34; class=&#34;dataframe&#34;&gt;
  &lt;thead&gt;
    &lt;tr style=&#34;text-align: right;&#34;&gt;
      &lt;th&gt;&lt;/th&gt;
      &lt;th&gt;x&lt;/th&gt;
      &lt;th&gt;y&lt;/th&gt;
    &lt;/tr&gt;
  &lt;/thead&gt;
  &lt;tbody&gt;
    &lt;tr&gt;
      &lt;th&gt;1&lt;/th&gt;
      &lt;td&gt;1.0&lt;/td&gt;
      &lt;td&gt;2.0&lt;/td&gt;
    &lt;/tr&gt;
  &lt;/tbody&gt;
&lt;/table&gt;

&lt;/div&gt;




```python
py_data = r.r_data
```


```python
print(py_data)
```

         x    y
    1  1.0  2.0



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-15-feather-%E5%9C%A8r%E4%B8%8Epython%E4%B9%8B%E9%97%B4%E5%85%B1%E4%BA%AB%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E6%A0%BC%E5%BC%8F/  

