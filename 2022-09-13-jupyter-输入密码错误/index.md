# jupyter 输入密码错误


解决密码输入正确，但是依然报错的问题。

&lt;!--more--&gt;

```bash
jupyter notebook list

## 生成配置文件，输入密码
## 但是需要修改配置，否则会出现密码错误: Invalid credentials
cd ~
jupyter notebook --generate-config
jupyter-notebook password

jupyter notebook --no-browser --port 58888
## 要把把 passwor 和 token 都设置为空字符串
vim jupyter_notebook_config.py

c.NotebookApp.password = u&#39;&#39;
c.NotebookApp.token = &#39;&#39;

c.NotebookApp.open_browser = False
c.NotebookApp.ip = &#39;0.0.0.0&#39;
c.NotebookApp.port = 58888
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-jupyter-%E8%BE%93%E5%85%A5%E5%AF%86%E7%A0%81%E9%94%99%E8%AF%AF/  

