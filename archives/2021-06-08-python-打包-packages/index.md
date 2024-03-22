# python 打包 packages


# 项目结构

```bash
├── readme.md
├── wepy
│   ├── ch
│   ├── __init__.py
│   ├── __pycache__
│   ├── requirements.txt
│   ├── setup.py
│   ├── utils
│   ├── __version__.py
│   └── wechat
```
&lt;!--more--&gt;

我们的git项目叫做 `wepy`，里面的代码放在了 `wepy` 这个目录，使用以下命令安装

```bash
git clone git@192.168.1.171:lfang/wepy.git
cd wepy
~/anaconda3/bin/python3 wepy/setup.py install

from wepy.utils.test import hi
hi()
```

# setup.py

```python
# -*- coding: utf-8 -*-
# @Author: “williamlfang”
# @Date:   2021-06-08 11:11:16
# @Last Modified by:   “williamlfang”
# @Last Modified time: 2021-06-08 11:14:11
#!/usr/bin/env python
# -*- coding: utf-8 -*-

# from distutils.core import setup
import setuptools
from setuptools import setup

#with open(&#34;README.md&#34;, &#34;r&#34;) as fh:
#    long_description = fh.read()

with open(&#39;./wepy/requirements.txt&#39;) as f:
    requirements = f.read().splitlines()

setup(
    name            = &#34;wepy&#34;,
    version         = &#34;0.0.1&#34;,
    author          = &#34;william&#34;,
    author_email    = &#34;william.lian.fang@gmail.com&#34;,
    url             = &#34;git@192.168.1.171:lfang/wepy.git&#34;,
    description     = &#34;a python package for WuyaCapital&#34;,
    install_requires=requirements,
    classifiers     = [
        &#34;Programming Language :: Python :: 3&#34;,
        &#34;License :: OSI Approved :: MIT License&#34;,
        &#34;Operating System :: OS Independent&#34;
        ],
    packages        = setuptools.find_packages(),
    py_modules      = [
        &#34;wepy.wechat&#34;,
        &#34;wepy.test&#34;,
        ]
    )
```



# 安装步骤

```bash
git clone git@192.168.1.171:lfang/wepy.git
cd wepy
~/anaconda3/bin/python3 wepy/setup.py install

from wepy.utils.test import hi
hi()
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-06-08-python-%E6%89%93%E5%8C%85-packages/  

