# pyproject.toml 打包项目



`pyproject.toml` 是新一代的 `python` **项目打包工具**。相比于 `setup.py` 能够提供更多关于项目本身的信息。

&lt;!--more--&gt;

# 安装

```bash
tree
.
├── mydemo
│   ├── __init__.py
│   └── module.py
└── pyproject.toml
```

## pyproject.toml

```toml
[build-system]
requires = [&#34;setuptools&#34;, &#34;setuptools-scm&#34;]
build-backend = &#34;setuptools.build_meta&#34;

[project]
name = &#34;mydemo&#34;
authors = [
    {name = &#34;Example Author&#34;, email = &#34;author@example.com&#34;}
]
description = &#34;package description&#34;
version = &#34;0.0.1&#34;
readme = &#34;README.md&#34;
requires-python = &#34;&gt;=3.7&#34;
dependencies = [
    &#34;requests &gt; 2.26.0&#34;,
    &#34;pandas&#34;
]
```

## mydemo

### __init__.py

```python
from .module import *
```

### module

```python
def myadd(a: int, b: int):
    &#34;add two numbers&#34;
    print(f&#34;myadd {a=}, {b=}&#34;)
    return a &#43; b
```

## install

```bash
pip install .
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-10-pyproject.toml-%E6%89%93%E5%8C%85%E9%A1%B9%E7%9B%AE/  

