# python3.11 无法安装 pycrypto


安装 `python3.11` 的一个软件包 `pycrypto` 时，出现一个报错，导致无法安装相关依赖包。

&lt;!--more--&gt;

![](/post/2023-07-18-python3.11-无法安装-pycrypto/pycrypto.png)

根据这篇问答[Could not build wheels for pycrypto, which is required to install pyproject.toml-based projects - ERROR](https://stackoverflow.com/questions/76318098/could-not-build-wheels-for-pycrypto-which-is-required-to-install-pyproject-toml)

&gt; Try running pip install setuptools wheel before installing requirements.txt. Some legacy projects require these packages to build wheels for pyproject.toml based projects. If that doesn&#39;t work, you might look into pycryptodome as a replacement for this dependency as mentioned in this thread.

这个看起来依然无效，然后找到文中提到的参考链接，提示有可能是 `pycrypto` 这个包年久失修，而 `python3.11` 又恰好更新了一些基础包（比如longint类型数据），从而导致安装报错。

前往链接：[Failed installing pycrypto with pip](https://stackoverflow.com/questions/50080459/failed-installing-pycrypto-with-pip/50099842#50099842)

&gt; This is a workaround rather than a solution, but it is still useful, because according to this post on the &#34;Issues&#34; section of the pycrypto official repository, it seems the package has not been maintained at all in the last years. And their recommendation is to install pycryptodome instead, since it still creates a Crypto package with the same namespace, so it is expected to work with source code based on the pycrypto libraries.

```bash
pip uninstall pycrypto
pip install pycryptodome
```

可以在 github 上看到 `pycrypto` 确实已经停止更新了：[Stop creating issues - this project is dead! #173](https://github.com/pycrypto/pycrypto/issues/173)

&gt; PyCrypto 2.x is unmaintained, obsolete, and contains security vulnerabilities.
See https://www.pycrypto.org/ for details. The following is provided for historical/reference purposes only.
&gt;
&gt; Move to a fork like pycryptodome


另外一个新项目是 [cryptography](https://github.com/pyca/cryptography)


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-07-18-python3.11-%E6%97%A0%E6%B3%95%E5%AE%89%E8%A3%85-pycrypto/  

