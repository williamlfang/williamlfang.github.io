# jupyterlab: 新一代的数据分析套件


jupyterlab 是対 ipython notebook 的全新改良版，提供了一个基于网页的功能套件，集成了多种数据分析工具，如 python、R、Julia 的内核。

&lt;!--more--&gt;

# 安装

## `conda` 安装

`JupyterLab` 的 `Github` 网页提供了相关的安装指引，只需根据操作系统的具体情况选择可行的安装方案即可。一般推荐使用 `conda` 的安装方式：

```bash
conda install -c conda-forge jupyterlab
```

这会自动安装依赖的软件包。安装完成后，可以查看当前的版本号

```bash
python -c &#34;import jupyterlab; print(jupyterlab.__version__)&#34;
```

## 启动

可以使用 `jupyter lab` 来启动程序。注意中间是有空格的，一般我会用短命令 `jupyterlab` 来覆盖，操作起来更符合直觉

```bash
jupyterlab=&#39;jupyter lab&#39;
```

![jupyter 启动界面](/images/2019-02-14-jupyterlab--新一代的数据分析套件/jupyterlab_start.png)

## 更新版本

我们可以更新到最新版本，或则指定安装特定版本的 `notebok`

```bash
conda search notebook
Loading channels: done
# Name                       Version           Build  Channel
notebook                       4.0.1          py27_0  pkgs/free
notebook                       4.0.1          py27_0  anaconda/pkgs/free
........
notebook                       5.7.4          py27_0  pkgs/main
notebook                       5.7.4          py36_0  pkgs/main
notebook                       5.7.4          py37_0  pkgs/main

conda instal notebook=5.7.4

conda install notebook=5.7.4
Collecting package metadata: done
Solving environment: done

## Package Plan ##

  environment location: /home/william/anaconda2

  added / updated specs:
    - notebook=5.7.4


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    notebook-5.7.4             |           py27_0         7.2 MB
    ------------------------------------------------------------
                                           Total:         7.2 MB

The following packages will be UPDATED:

  notebook                          5.7.0-py27_0 --&gt; 5.7.4-py27_0


Proceed ([y]/n)? y


Downloading and Extracting Packages
notebook-5.7.4       | 7.2 MB    | ######################### | 100%
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
```

## `Jupyter notebook` 命令

`JupyterLab` 使用的是 `Jupyter Notebook` 的内核。因此，我们需要使用 `Jupyter Notebook` 命令来操作

```bash
# 查看版本
jupyter notebook --version
5.7.4

# 显示当前运行的端口
jupyter notebook list
Currently running servers:
http://localhost:8888/?token=73a7e8191164930a966136da7aee9db9eab3d918392117e9 :: /home/william/

# 停止指定端口
jupyter notebook stop 8888
Shutting down server on port 8888 ...

# 如果无法关闭
# 夜可以使用系统的命令来强制关闭
fuser -k 8888/tcp
```

# 配置

## 主题设置



## 快捷键设置

# 示例



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-02-14-jupyterlab--%E6%96%B0%E4%B8%80%E4%BB%A3%E7%9A%84%E6%95%B0%E6%8D%AE%E5%88%86%E6%9E%90%E5%A5%97%E4%BB%B6/  

