# JupyterLab: 配置指南


jupyterlab 是対 ipython notebook 的全新改良版，提供了一个基于网页的功能套件，集成了多种数据分析工具，如 python、R、Julia 的内核。

# 安装

```bash
## 使用 conda 安装，解决依赖包问题
conda install -c conda-forge jupyterlab

## 也可以使用 pip 安装
pip install jupyterlab

## 安装完成后查看版本信息
python -c &#34;import jupyterlab; print(jupyterlab.__version__)&#34;
```

# 设置

## 允许外部访问

```python
## 设置运行所有ip都可以访问 ----------------------------
## The IP address the notebook server will listen on.
##c.NotebookApp.ip = &#39;localhost&#39;
c.NotebookApp.ip = &#39;0.0.0.0&#39;

## 设置默认端口打开 -----------------------------
## The port the notebook server will listen on.
##c.NotebookApp.port = 8888
c.NotebookApp.port = 9999

## 设置服务器端不要打开网页，使用客户端在浏览器打开 -----------------------------------
## Whether to open in a browser after starting. The specific browser used is
##  platform dependent and determined by the python standard library `webbrowser`
##  module, unless it is overridden using the --browser (NotebookApp.browser)
##  configuration option.
##c.NotebookApp.open_browser = True
c.NotebookApp.open_browser = False
```



## 显示

```bash
jupyter notebook list
```



## 密码

```bash
cd ~
jupyter notebook --generate-config
jupyter-notebook password
```

## 端口

```bashf
jupyter notebook --port 9999
```

# 启动

```bash
cd ~
fuser -k 8899/tcp
nohup jupyter lab --no-browser --port=8899 &amp;
```

## 杀掉

```bash
ps aux |grep jupyter  | awk &#39;{print $2}&#39; | xargs kill -9
```



# 端口转发

在本地机器上执行

```bash
## 如果已经占用端口，执行命令
fuser -k 9001/tcp
sudo fuser -k 9001/tcp
## 启动后台服务
## 9001 是本地， 8899 是远程服务器
nohup ssh -N -L 9001:localhost:8899 lhg@192.168.1.231 -p 22&amp;
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-20-jupyterlab--%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97/  

