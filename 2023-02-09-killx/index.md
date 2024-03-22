# killx


通过获取进程 `PID` 来杀死进程。


```bash
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
```

&lt;!--more--&gt;


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-02-09-killx/  

