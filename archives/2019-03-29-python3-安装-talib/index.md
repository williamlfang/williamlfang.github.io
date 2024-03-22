# python3 安装 talib


`talib` 是一款高性能技术指标的数值运算模块，为金融建模与量化交易提供一套丰富的接口函数。由于使用了 `c&#43;&#43;` 进行编译，`talib` 能够实现快速处理机能，尤其在量化实盘中有重要的作用。

而在 `python3` 中，并不提供内置的 `talib` 模块，需要我们单独进行安装。问题是，使用常规的 `pip` 无法直接安装这个软件包。因此，本文将介绍如何通过源文件进行安装模块。

&lt;!--more--&gt;

# 下载源文件

我们可以通过查找 [`SourceForge TA-Lib`](http://prdownloads.sourceforge.net/ta-lib) 项目网站来查看多个版本文件，目前最新版本是截至到 *2007-09-20*，目前已不在处于维护状态了。

```bash
cd ~/Downloads
axel http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xvf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
```

# 配置与编译

通过相关的配置，把 `talib` 安装到 `/usr` 目录下

```bash
./configure --prefix=/usr
sudo make &amp;&amp; make install
sudo apt update
```

# 安装 `talib`

这样，我们便可以通过 `pip` 通道来安装 `talib`

```bash
pip install ta-lib
## 或者 pip install TA-lib
```

然后启动 `python3` 查看是否安装成功

```bash
Python 3.7.0 (default, Jun 28 2018, 13:15:42)
[GCC 7.2.0] :: Anaconda, Inc. on linux
Type &#34;help&#34;, &#34;copyright&#34;, &#34;credits&#34; or &#34;license&#34; for more information.
&gt;&gt;&gt; import talib
&gt;&gt;&gt; talib.__file__
&#39;/home/william/anaconda3/lib/python3.7/site-packages/talib/__init__.py&#39;
&gt;&gt;&gt;
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-03-29-python3-%E5%AE%89%E8%A3%85-talib/  

