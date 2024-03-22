# airflow cronjob timezone 设置


修改 `airflow` 默认的时区

&lt;!--more--&gt;

## 修改 `airflow.cfg` 配置

```bash
sed -i &#34;s|^default_timezone = .*|default_timezone = Asia/Shanghai|g&#34;        airflow.cfg
sed -i &#34;s|^default_ui_timezone = .*|default_ui_timezone = Asia/Shanghai|g&#34;  airflow.cfg
```

## 在 `DAG` 设定时区

```bash
from docker.types import Mount
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.decorators import task
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.docker.operators.docker import DockerOperator
from wepy.utils.init import *

import pendulum
local_tz = pendulum.timezone(&#34;Asia/Shanghai&#34;) ## 设置时区
DEFAULT_ARGS = {
    &#39;owner&#39;            : &#39;william&#39;,
    &#39;email&#39;            : &#39;lfang@wuyacapital.com&#39;,
    &#39;email_on_failure&#39; : False,
    &#39;email_on_retry&#39;   : False,
    &#39;retries&#39;          : 3,
    &#39;retry_delay&#39;      : timedelta(minutes=1)
}

with DAG(
    dag_id         = &#34;pretrading.all.csv&#34;,
    default_args   = DEFAULT_ARGS,
    schedule       = &#34;35 08,20 * * 1-5&#34;,
    start_date     = datetime(2023, 1, 1, tzinfo=local_tz), ## 指定时区
    catchup        = False,
    dagrun_timeout = timedelta(seconds=60*3),
    tags           = [&#39;pretrading&#39;, &#39;all.csv&#39;],
) as dag:
```





---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-19-airflow-cronjob-timezone-%E8%AE%BE%E7%BD%AE/  

