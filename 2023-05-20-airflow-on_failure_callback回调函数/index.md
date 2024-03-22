# airflow on_failure_callback回调函数


注册回调函数，一旦 `DAG` 触发相关条件，会执行该回调函数

&lt;!--more--&gt;

## 支持 DAG 与 Operator

可以在 `DAG` 或者 单独一个 `Operator`(Task) 里面定义回调，入参使用为  `on_failure_callback=[callback_func_1, callback_func_2]`

## Callback Types

There are five types of task events that can trigger a callback:

| Name                  | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| `on_success_callback` | Invoked when the task [succeeds](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html#concepts-task-instances) |
| `on_failure_callback` | Invoked when the task [fails](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html#concepts-task-instances) |
| `sla_miss_callback`   | Invoked when a task misses its defined [SLA](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html#concepts-slas) |
| `on_retry_callback`   | Invoked when the task is [up for retry](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html#concepts-task-instances) |
| `on_execute_callback` | Invoked right before the task begins executing.              |

同时，在 `airflow2.6.0` 以上版本，还可以支持多个回调函数，将其放入一个 `list` 即可

&gt; As of Airflow 2.6.0, callbacks now supports a list of callback functions, allowing users to specify multiple functions to be executed in the desired event. Simply pass a list of callback functions to the callback args when defining your DAG/task callbacks: e.g `on_failure_callback=[callback_func_1, callback_func_2]`

```python
from docker.types import Mount
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.decorators import task
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.docker.operators.docker import DockerOperator
from wepy.utils.init import *

import pendulum
local_tz = pendulum.timezone(&#34;Asia/Shanghai&#34;)
DEFAULT_ARGS = {
    &#39;owner&#39;            : &#39;william&#39;,
    &#39;email&#39;            : &#39;xxx@xxx.com&#39;,
    &#39;email_on_failure&#39; : False,
    &#39;email_on_retry&#39;   : False,
    &#39;depends_on_past&#39;  : False,
    &#39;retries&#39;          : 3,
    &#39;retry_delay&#39;      : timedelta(minutes=1)
}

def dag_failure_alert(context):
    msg = f&#34;&#34;&#34;DAG has failed,
        ---------------------
        {context}
        ---------------------
        {context.get(&#39;dag&#39;)=}
        {context.get(&#39;dag_run&#39;)=}
        ---------------------
        {context.get(&#39;task&#39;)=}
        {context.get(&#39;task_instance&#39;)=}
        &#34;&#34;&#34;
    log.err(msg)
    wx_test.send(msg, &#39;error&#39;)

def task_failure_alert(context):
    msg = f&#34;&#34;&#34;Task has failed,
        task_instance_key_str: {context[&#39;task_instance_key_str&#39;]}
        &#34;&#34;&#34;
    log.err(msg)
    wx_test.send(msg, &#39;error&#39;)

def checking():
    if not cal.is_today_trading():
        raise Exception(&#34;Not TradingDay.&#34;)

with DAG(
    dag_id         = &#34;hello&#34;,
    default_args   = DEFAULT_ARGS,
    schedule       = &#34;*/1 * * *&#34;,
    start_date     = datetime(2023, 1, 1, tzinfo=local_tz),
    catchup        = False,
    dagrun_timeout = timedelta(seconds=60*3),
    tags           = [&#39;hello&#39;],
    on_failure_callback = [dag_failure_alert],
) as dag:
    checking = PythonOperator(
        task_id = &#39;checking&#39;,
        python_callable = checking,
        dag = dag,
        on_failure_callback = [task_failure_alert],
    )

    checking

```





---

> 作者: william  
> URL: https://williamlfang.github.io/2023-05-20-airflow-on_failure_callback%E5%9B%9E%E8%B0%83%E5%87%BD%E6%95%B0/  

