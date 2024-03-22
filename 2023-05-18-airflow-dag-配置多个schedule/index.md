# airflow DAG 配置多个schedule


`airflow` 允许为一个相同的 `DAG` 配置多个 `schedule`

&lt;!--more--&gt;

```python
from airflow.datasets import Dataset

with DAG(
    dag_id         = &#34;pretrading.all.csv&#34;,
    default_args   = DEFAULT_ARGS,
    #  schedule       = &#34;35 08 * * 1-5&#34;,
    schedule       = [Dataset(&#34;*/5 * * * 1-5&#34;), Dataset(&#34;9 18 * * 1-5&#34;)],
    start_date     = datetime(2023, 1, 1),
    catchup        = False,
    dagrun_timeout = timedelta(seconds=60*3),
    tags           = [&#39;pretrading&#39;, &#39;all.csv&#39;],
) as dag:
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-18-airflow-dag-%E9%85%8D%E7%BD%AE%E5%A4%9A%E4%B8%AAschedule/  

