# airflow: 使用 cli 进行操作


`ariflow` 是一款优秀的开源任务管理架构，通过 `DAG` 的图形关系，指定各个子任务之间的依赖关系，并自动执行流水线。同时，`airflow` 还提供了美观的 `UI`，方便用户通过鼠标点击进行相关操作。

而本文要介绍的，则是 `airflow` 的命令行（CLI）操作模式。`CLI` 相比于 `UI` ，提供了更加灵活、可重现的运作方式，通过代码和配置，我们可以进行大规模的系统部署，避免鼠标操作存在的失误与不可重复性。

&lt;!--more--&gt;

## airflow UI 操作

在研究 `CLI` 之前，我尝试使用 `UI` 进行相关操作，如添加 `role`、`user`、`DAGs` 管理等。大体的经验是

1. 最基础的用户组应该具备以下几组，权限才能获取相关页面、按钮、执行任务的权限

    ```python
    {&#39;actions&#39;: [
        {&#39;action&#39;: {&#39;name&#39;: &#39;can_read&#39;},    &#39;resource&#39;: {&#39;name&#39;:&#39;Website&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;can_read&#39;},    &#39;resource&#39;: {&#39;name&#39;: &#39;Triggers&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;can_create&#39;},  &#39;resource&#39;: {&#39;name&#39;: &#39;DAG Runs&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;menu_access&#39;}, &#39;resource&#39;: {&#39;name&#39;: &#34;User&#39;s Statistics&#34;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;menu_access&#39;}, &#39;resource&#39;: {&#39;name&#39;: &#39;Actions&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;menu_access&#39;}, &#39;resource&#39;: {&#39;name&#39;: &#39;DAG Runs&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;menu_access&#39;}, &#39;resource&#39;: {&#39;name&#39;: &#39;Task Instances&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;menu_access&#39;}, &#39;resource&#39;: {&#39;name&#39;: &#39;Triggers&#39;}},
        {&#39;action&#39;: {&#39;name&#39;: &#39;menu_access&#39;}, &#39;resource&#39;: {&#39;name&#39;: &#39;DAGs&#39;}}
        ],
    &#39;name&#39;: &#39;trader&#39;}
    ```

    ![trader](./trader.png &#34;最基础的用户组应该具备&#34;)

2. 对于的特定用户，需要有具体的 `DAG` 权限：read、edit、delete

    ![trader4](./trader4.png &#34;对于的特定用户&#34;)

3. 通过 `role` 的组合，可以让 `user` 获取多个权限。如上面的 `trader` &#43; `trader4` 的组合，可以允许用户获取两者的权限并集。

4. `airflow` 提供了 `DAG-specific` 的权限控制，通过在 `DAG` 任务指定 `role` 权限，可以以更加细粒度的方式进行控制

    ```python
        with DAG(
            dag_id         = &#34;trading.hyena15.comm.c2s&#34;,
            default_args   = AirflowUtil.default_args(retry=0),
            schedule       = &#34;50 08 * * 1-5&#34;,
            start_date     = datetime(2023, 1, 1, tzinfo=AirflowUtil.local_tz()),
            catchup        = False,
            dagrun_timeout = timedelta(seconds=60*30),
            tags           = [&#39;trading&#39;, &#39;futures&#39;, &#39;hyena15&#39;, &#39;comm&#39;, &#39;c2s&#39;],
            on_failure_callback = dag_failure_alert,
            on_success_callback = dag_success_alert,
            access_control={
                # &#34;trader&#34; : {&#34;can_edit&#34;, &#34;can_read&#34;, &#34;can_delete&#34;},
                &#34;trader4&#34;: {&#34;can_edit&#34;, &#34;can_read&#34;, &#34;can_delete&#34;},
            },
        ) as dag:
    ```

## 启用 airflow cli 功能

`airflow` 提供的 `cli` 功能，主要是通过 `REST API` 实现，默认是关闭的。因此，我们需要修改配置文件，使其生效。

打开配置文件 `airflow.cfg`，修改 `[api]` 下面的 `auth_backends`

```
[api]
# Comma separated list of auth backends to authenticate users of the API. See
# https://airflow.apache.org/docs/apache-airflow/stable/security/api.html for possible values.
# (&#34;airflow.api.auth.backend.default&#34; allows all requests for historic reasons)
#
# Variable: AIRFLOW__API__AUTH_BACKENDS
#
# auth_backends = airflow.api.auth.backend.session
auth_backends = airflow.api.auth.backend.basic_auth
```

然后重启 `ariflow`

```bash
#!/bin/bash
## =============================================================================
killx () {
    list=$(ps aux | grep -i $1| grep -v grep |grep -v color)

    if [ -n &#34;$list&#34; ]; then
        dead=$(ps aux | grep -i $1| grep -v grep| grep -v color | awk &#39;{print $2}&#39;)
        echo &#34;Killing... $1&#34;
        echo $dead |xargs kill -9
    else
        echo &#34;Not running $1&#34;
    fi
}
killx airflow

## ------------------------------------
export AIRFLOW_HOME=/app
export AIRFLOW__CORE__LOAD_EXAMPLES=False

ps -ef | egrep &#39;scheduler|airflow|webserver&#39; | awk &#39;{print $2}&#39;| xargs kill -15

for var in scheduler webserver
do
   x=`cat $AIRFLOW_HOME/airflow-${var}.pid`
   if [ &#34;$x&#34; != &#34;&#34; ]
   then
       cat $AIRFLOW_HOME/airflow-${var}.pid | xargs kill -9
   fi

   cat /dev/null &gt;  $AIRFLOW_HOME/airflow-${var}.pid
   rm $AIRFLOW_HOME/airflow-${var}.pid
done

rm -rf airflow-scheduler.pid
rm -rf airflow-webserver-monitor.pid
rm -rf airflow-webserver.pid
#airflow db init
## ------------------------------------
airflow webserver -p 8080 -D
airflow scheduler -D
## ------------------------------------
```

## python 调用相关接口

`airflow` 提供 `REST API`，通过 `GET` 与 `POST` 方法，我们可以很方便的与服务端进行交互。

```python
from typing import List
import requests
import argparse
import base64
from pprint import pprint

def make_permissions(action, resources):
    permissions = []
    for perm in resources:
        permissions.append(make_permission(action, perm))
    return permissions

def make_permission(action, resource):
    return {
        &#34;action&#34;: {&#34;name&#34;: action},
        &#34;resource&#34;: {&#34;name&#34;: resource}
    }

airflow_url = &#34;http://192.168.1.160:18080/&#34;
new_role_name = &#39;testingx&#39;
dag_names = [&#39;pretrading.check.init.pos&#39;]
airflow_username = &#39;william&#39;
airflow_password = &#39;xxxxxx&#39;
headers = {
    &#39;Accept&#39;: &#39;text/html,application/xhtml&#43;xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7&#39;,
    &#39;Accept-Encoding&#39;: &#39;gzip, deflate&#39;,
    &#39;Accept-Language&#39;: &#39;zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-TW;q=0.6&#39;,
    &#39;Cache-Control&#39;: &#39;max-age=0&#39;,
    &#39;Connection&#39;: &#39;keep-alive&#39;,
    &#39;Upgrade-Insecure-Requests&#39;: &#39;1&#39;,
    &#39;User-Agent&#39;: &#39;Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36&#39;,
}
auth_str = f&#34;{airflow_username}:{airflow_password}&#34;
base64_auth_str = base64.b64encode(auth_str.encode()).decode()
headers[&#34;Authorization&#34;] = &#34;Basic &#34; &#43; base64_auth_str

## REST API -------------------------------------------------------------------
airflow_url &#43;= &#34;/api/v1/roles&#34;

## GET ------------------------------------------------------------------------
info = requests.get(airflow_url, headers=headers).json()
tmp = [k for k in info[&#39;roles&#39;] if k[&#39;name&#39;] == &#39;trader&#39;][0]
pprint(tmp)

## POST -----------------------------------------------------------------------
read = &#34;can_read&#34;
edit = &#34;can_edit&#34;
create = &#34;can_create&#34;
delete = &#34;can_delete&#34;
menu = &#34;menu_access&#34;

# add general permissions
permissions = []
read_permissions = make_permissions(read, [
    &#34;Website&#34;,
    &#34;DAG Runs&#34;,
    &#34;Task Instances&#34;,
    &#34;Audit Logs&#34;,
    &#34;ImportError&#34;,
    &#34;XComs&#34;,
    &#34;DAG Code&#34;,
    &#34;Plugins&#34;,
    &#34;My Password&#34;,
    &#34;My Profile&#34;,
    &#34;Jobs&#34;,
    &#34;SLA Misses&#34;,
    &#34;DAG Dependencies&#34;,
    &#34;Task Logs&#34;])
edit_permissions = make_permissions(edit, [
    &#34;Task Instances&#34;,
    &#34;My Password&#34;,
    &#34;My Profile&#34;,
    &#34;DAG Runs&#34;])
create_permissions = make_permissions(create, [
    &#34;DAG Runs&#34;,
    &#34;Task Instances&#34;])
delete_permissions = make_permissions(delete, [
    &#34;DAG Runs&#34;,
    &#34;Task Instances&#34;])
menu_permissions = make_permissions(menu, [
    &#34;View Menus&#34;,
    &#34;Browse&#34;,
    &#34;Docs&#34;,
    &#34;Documentation&#34;,
    &#34;SLA Misses&#34;,
    &#34;Jobs&#34;,
    &#34;DAG Runs&#34;,
    &#34;Task Instances&#34;,
    &#34;Audit Logs&#34;,
    &#34;DAG Dependencies&#34;])

## all in one
permissions &#43;= read_permissions &#43; edit_permissions &#43; create_permissions &#43; delete_permissions &#43; menu_permissions

# add dag-specific permissions
for dag in dag_names:
    dag = &#34;DAG:&#34; &#43; dag
    read_permissions = make_permissions(read,[dag])
    edit_permissions = make_permissions(edit, [dag])
    delete_permissions = make_permissions(delete, [dag])
    permissions &#43;= read_permissions &#43; edit_permissions &#43; delete_permissions

data = {
    &#34;actions&#34;: [
        *permissions
    ],
    &#34;name&#34;: new_role_name
}

airflow_url &#43;= &#34;/api/v1/roles&#34;
response = requests.post(airflow_url, json=data, headers=headers)
print(response.status_code)

if response.status_code == 403:
    raise PermissionError(f&#34;Error 403 returned, please check if your AirFlow account is Op/Admin or verify the dags exist. \n {response.json()}&#34;)
elif response.status_code == 401:
    raise PermissionError(f&#34;Error 401 returned, please check the access token if the page is protected by an authentication&#34;)
elif response.status_code == 200:
    print(f&#34;Role `{new_role_name}` successfully created.&#34;)
    return
elif response.status_code == 409:  # Role already exists, update it
    print(&#34;Role already exists, updating...&#34;)
    airflow_role_update_url = f&#34;{airflow_url}/{new_role_name}&#34;
    update_response = requests.patch(airflow_role_update_url, json=data, headers=headers)
    if update_response.status_code == 200:
        print(f&#34;Role `{new_role_name}` successfully updated.&#34;)
    else:
        raise ConnectionError(f&#34;An error occurred during role update: {update_response.json()}&#34;)
else:
    raise ConnectionError(f&#34;An error occurred during role creation: {response.json()}&#34;)
```


整理以上的脚本

```python
from typing import List
import requests
import argparse
import base64
from pprint import pprint

def make_permissions(action, resources):
    permissions = []
    for perm in resources:
        permissions.append(make_permission(action, perm))
    return permissions

def make_permission(action, resource):
    return {
        &#34;action&#34;: {&#34;name&#34;: action},
        &#34;resource&#34;: {&#34;name&#34;: resource}
    }

def create_rbac_role_with_permissions(
    airflow_url: str,
    new_role_name: str,
    dag_names: List[str],
    google_access_token: str=None,
    airflow_username: str=None,
    airflow_password: str=None
):
    &#34;&#34;&#34;
    airflow_url = &#34;http://192.168.1.160:18080/&#34;
    new_role_name = &#39;testingx&#39;
    dag_names = [&#39;pretrading.check.init.pos&#39;]
    airflow_username = &#39;william&#39;
    airflow_password = &#39;xxxxxx&#39;
    google_access_token = None
    &#34;&#34;&#34;
    if isinstance(dag_names, str):
        dag_names = [dag_names]

    headers = {
        &#39;Accept&#39;: &#39;text/html,application/xhtml&#43;xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7&#39;,
        &#39;Accept-Encoding&#39;: &#39;gzip, deflate&#39;,
        &#39;Accept-Language&#39;: &#39;zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,zh-TW;q=0.6&#39;,
        &#39;Cache-Control&#39;: &#39;max-age=0&#39;,
        &#39;Connection&#39;: &#39;keep-alive&#39;,
        &#39;Upgrade-Insecure-Requests&#39;: &#39;1&#39;,
        &#39;User-Agent&#39;: &#39;Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36&#39;,
    }

    if google_access_token:
        headers[&#34;Authorization&#34;] = &#34;Bearer &#34; &#43; google_access_token
    elif airflow_username and airflow_password:
        auth_str = f&#34;{airflow_username}:{airflow_password}&#34;
        base64_auth_str = base64.b64encode(auth_str.encode()).decode()
        headers[&#34;Authorization&#34;] = &#34;Basic &#34; &#43; base64_auth_str

    read = &#34;can_read&#34;
    edit = &#34;can_edit&#34;
    create = &#34;can_create&#34;
    delete = &#34;can_delete&#34;
    menu = &#34;menu_access&#34;

    # add general permissions
    permissions = []
    read_permissions = make_permissions(read, [
        &#34;Website&#34;,
        &#34;DAG Runs&#34;,
        &#34;Task Instances&#34;,
        &#34;Audit Logs&#34;,
        &#34;ImportError&#34;,
        &#34;XComs&#34;,
        &#34;DAG Code&#34;,
        &#34;Plugins&#34;,
        &#34;My Password&#34;,
        &#34;My Profile&#34;,
        &#34;Jobs&#34;,
        &#34;SLA Misses&#34;,
        &#34;DAG Dependencies&#34;,
        &#34;Task Logs&#34;])
    edit_permissions = make_permissions(edit, [
        &#34;Task Instances&#34;,
        &#34;My Password&#34;,
        &#34;My Profile&#34;,
        &#34;DAG Runs&#34;])
    create_permissions = make_permissions(create, [
        &#34;DAG Runs&#34;,
        &#34;Task Instances&#34;])
    delete_permissions = make_permissions(delete, [
        &#34;DAG Runs&#34;,
        &#34;Task Instances&#34;])
    menu_permissions = make_permissions(menu, [
        &#34;View Menus&#34;,
        &#34;Browse&#34;,
        &#34;Docs&#34;,
        &#34;Documentation&#34;,
        &#34;SLA Misses&#34;,
        &#34;Jobs&#34;,
        &#34;DAG Runs&#34;,
        &#34;Task Instances&#34;,
        &#34;Audit Logs&#34;,
        &#34;DAG Dependencies&#34;])

    ## all in one
    permissions &#43;= read_permissions &#43; edit_permissions &#43; create_permissions &#43; delete_permissions &#43; menu_permissions

    # add dag-specific permissions
    for dag in dag_names:
        dag = &#34;DAG:&#34; &#43; dag
        read_permissions = make_permissions(read,[dag])
        edit_permissions = make_permissions(edit, [dag])
        delete_permissions = make_permissions(delete, [dag])
        permissions &#43;= read_permissions &#43; edit_permissions &#43; delete_permissions

    data = {
        &#34;actions&#34;: [
            *permissions
        ],
        &#34;name&#34;: new_role_name
    }

    airflow_url &#43;= &#34;/api/v1/roles&#34;
    response = requests.post(airflow_url, json=data, headers=headers)
    print(response.status_code)

    if response.status_code == 403:
        raise PermissionError(f&#34;Error 403 returned, please check if your AirFlow account is Op/Admin or verify the dags exist. \n {response.json()}&#34;)
    elif response.status_code == 401:
        raise PermissionError(&#34;Error 401 returned, please check the access token if the page is protected by an authentication&#34;)
    elif response.status_code == 200:
        print(f&#34;Role `{new_role_name}` successfully created.&#34;)
        return
    elif response.status_code == 409:  # Role already exists, update it
        print(&#34;Role already exists, updating...&#34;)
        airflow_role_update_url = f&#34;{airflow_url}/{new_role_name}&#34;
        update_response = requests.patch(airflow_role_update_url, json=data, headers=headers)
        if update_response.status_code == 200:
            print(f&#34;Role `{new_role_name}` successfully updated.&#34;)
        else:
            raise ConnectionError(f&#34;An error occurred during role update: {update_response.json()}&#34;)
    else:
        raise ConnectionError(f&#34;An error occurred during role creation: {response.json()}&#34;)


if __name__ == &#34;__main__&#34;:
    parser = argparse.ArgumentParser()
    parser.add_argument(&#34;-u&#34;, &#34;--airflow-url&#34;, required=True, help=&#34;URL to the composer Airflow UI root page&#34;)
    parser.add_argument(&#34;-r&#34;, &#34;--role-name&#34;, required=True, help=&#34;Name of the new created role&#34;)
    parser.add_argument(&#34;-d&#34;, &#34;--dags&#34;, nargs=&#34;&#43;&#34;, required=True, help=&#34;List of accessible dags for the role&#34;)
    parser.add_argument(&#34;-t&#34;, &#34;--access-token&#34;, required=False, help=&#34;Google access token used only if Airflow is managed by Cloud Composer&#34;)
    parser.add_argument(&#34;-afu&#34;, &#34;--airflow-username&#34;, required=False, help=&#34;Airflow username for Basic Auth&#34;)
    parser.add_argument(&#34;-afp&#34;, &#34;--airflow-password&#34;, required=False, help=&#34;Airflow password for Basic Auth&#34;)

    args = parser.parse_args()
    create_rbac_role_with_permissions(
        airflow_url=args.airflow_url,
        new_role_name=args.role_name,
        dag_names=args.dags,
        google_access_token=args.access_token,
        airflow_username=args.airflow_username,
        airflow_password=args.airflow_password
    )
```

## DAGs 权限管理


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-08-22-airflow--%E4%BD%BF%E7%94%A8-cli-%E8%BF%9B%E8%A1%8C%E6%93%8D%E4%BD%9C/  

