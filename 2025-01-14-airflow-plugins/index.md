# Airflow Plugins


`ariflow` 的 `schedule` 可以使用 `timetable` 或者 `cron expression` 配置任务调度的时间。对于使用 `cron expression`，如果我们需要更加细粒度的控制，则比较困难。比如我有一个任务设定在两个时间执行

- `45 08 * * 1-5`
- `01 09 * * 1-5`

这个在 `cron expression` 无法合并成同一个任务。

&lt;!--more--&gt;

# 拆开多个子任务

一个方法是我们可以把这个拆开成两个 `DAG`，分别命名为 `task1` 和 `task2`，然后各自按照自己的时间进行调度。这个方法的问题是：如果我们有多个时间段，则要对应多个子任务。这个在管理上不是很直观，本质上我们还是管理同一个 `DAG`，但是现在反而分散到不同的子任务，明显违反了 `DRY` 的原则。

# 自定义 Timetable

在底层，`ariflow` 其实是把我们传递给 `schedule` 的表达式转化成一个 `timetable` 类，然后根据一定的规则识别下一次任务的执行时间。因此，我们可以从 `timetable` 继承一个子类，自定义任务执行的时间间隔，比如多个 `cron expression` 进行对比，就可以实现多时段的设置了。

## plugins

如果我们要添加自定义的 `timetable` 子类，需要以 `airflow plugins` 的方式进行添加，这样 `ariflow` 的 `sheduler`、`webserver` 等组件才能识别。

我是参考了这篇 `SO` [airflow 2.2 timetable for schedule, always with error: timetable not registered](https://stackoverflow.com/questions/69732193/airflow-2-2-timetable-for-schedule-always-with-error-timetable-not-registered)。具体的实现步骤是：

1. 修改 `$AIRFLOW_HOME/airflow.cfg` 里面的配置，`lazy_discover_providers = True`

    ```
    # By default Airflow providers are lazily-discovered (discovery and imports happen only when required).
    # Set it to False, if you want to discover providers whenever &#39;airflow&#39; is invoked via cli or
    # loaded from module.
    #
    # Variable: AIRFLOW__CORE__LAZY_DISCOVER_PROVIDERS
    #
    lazy_discover_providers = True
    ```

2. 在 `$AIRFLOW_HOME/plugins` 目录添加 `__init__.py`
3. 在 `$AIRFLOW_HOME/plugins` 目录添加 `mycron.py`，这里面就是我们需要实现的自定义子类 `MultiCronTimetable`
4. 编写 `MultiCronTimetable` 类定义
5. 需要重启 `airflow`
6. 在 `dag` 的 `schedule` 添加设置的任务时间即可。需要注意的是，由于我们使用 `airflow` 的 `plugins_manager` 插件，已经把命名空间引进来了，因此可以直接 `import mycron`。

    ```python
    from airflow.plugins_manager import AirflowPlugin
    ## the file name of your plugin
    ## no import airflow.plugins.example_plugin
    ## since this has already been managed by airflow.plugins_manager
    ## Import plugin directly - Airflow&#39;s plugin manager handles the namespace
    # Define multiple cron schedules
    from mycron import MultiCronTimetable
    multi_cron = MultiCronTimetable(
        cron_defs = [
            &#34;50,59 08 * * 1-5&#34;,  # Original schedule
            &#34;01,05 09 * * 1-5&#34;,  # more cron expression
        ],
        timezone = &#34;Asia/Shanghai&#34;
    )

    with DAG(
        dag_id         = &#34;pretrading.pos&#34;,
        default_args   = AirflowUtil.default_args(retry=0),
        # schedule       = &#34;01,05 09,15 * * 1-5&#34;,
        schedule       = multi_cron,
        start_date     = datetime(2023, 1, 1, tzinfo=AirflowUtil.local_tz()),
        catchup        = False,
        dagrun_timeout = timedelta(seconds=60*30),
        tags           = [&#39;pretrading&#39;, &#39;pos&#39;, &#39;gui&#39;, &#39;stk&#39;, &#39;cv&#39;],
        on_failure_callback = dag_failure_alert,
        on_success_callback = dag_success_alert,
    ) as dag:
    ```


## MultiCronTimetable

### 类实现

```python
# This file is &lt;airflow plugins directory&gt;/timetable.py

from typing import Any, Dict, List, Optional
import pendulum
from croniter import croniter
from pendulum import DateTime, Duration, timezone, instance as pendulum_instance
from airflow.plugins_manager import AirflowPlugin
from airflow.timetables.base import DagRunInfo, DataInterval, TimeRestriction, Timetable
from airflow.exceptions import AirflowTimetableInvalid


class MultiCronTimetable(Timetable):
    valid_units = [&#39;minutes&#39;, &#39;hours&#39;, &#39;days&#39;]

    def __init__(self,
                 cron_defs: List[str],
                 timezone: str = &#39;Europe/Berlin&#39;,
                 period_length: int = 0,
                 period_unit: str = &#39;hours&#39;):

        self.cron_defs = cron_defs
        self.timezone = timezone
        self.period_length = period_length
        self.period_unit = period_unit

    def infer_manual_data_interval(self, run_after: DateTime) -&gt; DataInterval:
        &#34;&#34;&#34;
        Determines date interval for manually triggered runs.
        This is simply (now - period) to now.
        &#34;&#34;&#34;
        end = run_after
        if self.period_length == 0:
            start = end
        else:
            start = self.data_period_start(end)
        return DataInterval(start=start, end=end)

    def next_dagrun_info(
        self,
        *,
        last_automated_data_interval: Optional[DataInterval],
        restriction: TimeRestriction) -&gt; Optional[DagRunInfo]:
        &#34;&#34;&#34;
        Determines when the DAG should be scheduled.

        &#34;&#34;&#34;

        if restriction.earliest is None:
            # No start_date. Don&#39;t schedule.
            return None

        is_first_run = last_automated_data_interval is None

        if is_first_run:
            if restriction.catchup:
                scheduled_time = self.next_scheduled_run_time(restriction.earliest)

            else:
                scheduled_time = self.previous_scheduled_run_time()
                if scheduled_time is None:
                    # No previous cron time matched. Find one in the future.
                    scheduled_time = self.next_scheduled_run_time()
        else:
            last_scheduled_time = last_automated_data_interval.end

            if restriction.catchup:
                scheduled_time = self.next_scheduled_run_time(last_scheduled_time)

            else:
                scheduled_time = self.previous_scheduled_run_time()

                if scheduled_time is None or scheduled_time == last_scheduled_time:
                    # No previous cron time matched,
                    # or the matched cron time was the last execution time,
                    scheduled_time = self.next_scheduled_run_time()

                elif scheduled_time &gt; last_scheduled_time:
                    # Matched cron time was after last execution time, but before now.
                    # Use this cron time
                    pass

                else:
                    # The last execution time is after the most recent matching cron time.
                    # Next scheduled run will be in the future
                    scheduled_time = self.next_scheduled_run_time()

        if scheduled_time is None:
            return None

        if restriction.latest is not None and scheduled_time &gt; restriction.latest:
            # Over the DAG&#39;s scheduled end; don&#39;t schedule.
            return None

        start = self.data_period_start(scheduled_time)
        return DagRunInfo(run_after=scheduled_time, data_interval=DataInterval(start=start, end=scheduled_time))

    def data_period_start(self, period_end: DateTime):
        return period_end - Duration(**{self.period_unit: self.period_length})

    def croniter_values(self, base_datetime=None):
        if not base_datetime:
            tz = timezone(self.timezone)
            base_datetime = pendulum.now(tz)

        return [croniter(expr, base_datetime) for expr in self.cron_defs]

    def next_scheduled_run_time(self, base_datetime: DateTime = None):
        min_date = None
        tz = timezone(self.timezone)
        if base_datetime:
            base_datetime_localized = base_datetime.in_timezone(tz)
        else:
            base_datetime_localized = pendulum.now(tz)

        for cron in self.croniter_values(base_datetime_localized):
            next_date = cron.get_next(DateTime)
            if not min_date:
                min_date = next_date
            else:
                min_date = min(min_date, next_date)
        if min_date is None:
            return None
        return pendulum_instance(min_date)

    def previous_scheduled_run_time(self, base_datetime: DateTime = None):
        &#34;&#34;&#34;
        Get the most recent time in the past that matches one of the cron schedules
        &#34;&#34;&#34;
        max_date = None
        tz = timezone(self.timezone)
        if base_datetime:
            base_datetime_localized = base_datetime.in_timezone(tz)
        else:
            base_datetime_localized = pendulum.now(tz)

        for cron in self.croniter_values(base_datetime_localized):
            prev_date = cron.get_prev(DateTime)
            if not max_date:
                max_date = prev_date
            else:
                max_date = max(max_date, prev_date)
        if max_date is None:
            return None
        return pendulum_instance(max_date)


    def validate(self) -&gt; None:
        if not self.cron_defs:
            raise AirflowTimetableInvalid(&#34;At least one cron definition must be present&#34;)

        if self.period_unit not in self.valid_units:
            raise AirflowTimetableInvalid(f&#39;period_unit must be one of {self.valid_units}&#39;)

        if self.period_length &lt; 0:
            raise AirflowTimetableInvalid(f&#39;period_length must not be less than zero&#39;)

        try:
            self.croniter_values()
        except Exception as e:
            raise AirflowTimetableInvalid(str(e))

    @property
    def summary(self) -&gt; str:
        &#34;&#34;&#34;A short summary for the timetable.

        This is used to display the timetable in the web UI. A cron expression
        timetable, for example, can use this to display the expression.
        &#34;&#34;&#34;
        return &#39; || &#39;.join(self.cron_defs) &#43; f&#39; [TZ: {self.timezone}]&#39;

    def serialize(self) -&gt; Dict[str, Any]:
        &#34;&#34;&#34;Serialize the timetable for JSON encoding.

        This is called during DAG serialization to store timetable information
        in the database. This should return a JSON-serializable dict that will
        be fed into ``deserialize`` when the DAG is deserialized.
        &#34;&#34;&#34;
        return dict(cron_defs=self.cron_defs,
                    timezone=self.timezone,
                    period_length=self.period_length,
                    period_unit=self.period_unit)

    @classmethod
    def deserialize(cls, data: Dict[str, Any]) -&gt; &#34;MultiCronTimetable&#34;:
        &#34;&#34;&#34;Deserialize a timetable from data.

        This is called when a serialized DAG is deserialized. ``data`` will be
        whatever was returned by ``serialize`` during DAG serialization.
        &#34;&#34;&#34;
        return cls(**data)


class CustomTimetablePlugin(AirflowPlugin):
    name = &#34;custom_timetable_plugin&#34;
    timetables = [MultiCronTimetable]
```

### 注册插件

需要注意的是，我们在上面实现了自定义子类 `MultiCronTimetable`，还需要将其注册到 `airflow plugins`，否则会报错

```bash
MultiCronTimetable plugins not registered
```

具体实现就是上面最后那段代码

```python
class CustomTimetablePlugin(AirflowPlugin):
    name = &#34;custom_timetable_plugin&#34;
    timetables = [MultiCronTimetable]
```

此时我们通过 `airflow` 查看插件是否已经加载

```bash
airflow plugins

name                      | source                     | timetables
==========================&#43;============================&#43;===========================
custom_timetable_plugin   | $PLUGINS_FOLDER/mycron.py  | mycron.MultiCronTimetable
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-14-airflow-plugins/  

