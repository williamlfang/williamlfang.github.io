# CentOS 调用显示器




参考链接：[Stack OverFlow](https://stackoverflow.com/questions/646930/cannot-connect-to-x-server-0-0-with-a-qt-application)

# 在系统添加显示屏

```bash
export DISPLAY=:0.0
xhost &#43;HOSTNAME
xhost &#43;local:root
```

# 在交易系统调用屏幕

```python
import os
os.putenv(&#39;DISPLAY&#39;, &#39;:0.0&#39;)
```


---

> 作者:   
> URL: https://williamlfang.github.io/archives/2017-12-18-centos-%E8%B0%83%E7%94%A8%E6%98%BE%E7%A4%BA%E5%99%A8/  

