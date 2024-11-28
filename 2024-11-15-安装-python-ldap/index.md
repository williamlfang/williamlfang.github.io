# 安装 python ldap


## 问题

安装 `python-ldap` 失败，报错如下：

```bash
~/miniconda3/bin/python -m pip install python-ldap
                                                                                                                                            [Nov15 17:37:32]
Looking in indexes: https://mirrors.cloud.tencent.com/pypi/simple
Collecting python-ldap
  Using cached https://mirrors.cloud.tencent.com/pypi/packages/fd/8b/1eeb4025dc1d3ac2f16678f38dec9ebdde6271c74955b72db5ce7a4dbfbd/python-ldap-3.4.4.tar.gz (377 kB)
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Collecting pyasn1&gt;=0.3.7
  Using cached https://mirrors.cloud.tencent.com/pypi/packages/c8/f1/d6a797abb14f6283c0ddff96bbdd46937f64122b8c925cab503dd37f8214/pyasn1-0.6.1-py3-none-any.whl (83 kB)
Collecting pyasn1-modules&gt;=0.1.5
  Using cached https://mirrors.cloud.tencent.com/pypi/packages/77/89/bc88a6711935ba795a679ea6ebee07e128050d6382eaa35a0a47c8032bdc/pyasn1_modules-0.4.1-py3-none-any.whl (181 kB)
Building wheels for collected packages: python-ldap
  Building wheel for python-ldap (pyproject.toml) ... error
  error: subprocess-exited-with-error

  × Building wheel for python-ldap (pyproject.toml) did not run successfully.
  │ exit code: 1
  ╰─&gt; [83 lines of output]
      /tmp/ycm.lfang/pip-build-env-e1c2lubs/overlay/lib/python3.11/site-packages/setuptools/_distutils/dist.py:261: UserWarning: Unknown distribution option: &#39;test_suite&#39;
        warnings.warn(msg)
      running bdist_wheel
      running build
      running build_py
      creating build/lib.linux-x86_64-cpython-311
      copying Lib/slapdtest/__init__.py -&gt; build/lib.linux-x86_64-cpython-311/slapdtest
      ...................................................................................
      copying Lib/slapdtest/_slapdtest.py -&gt; build/lib.linux-x86_64-cpython-311/slapdtest
      running egg_info
      writing Lib/python_ldap.egg-info/PKG-INFO
      writing dependency_links to Lib/python_ldap.egg-info/dependency_links.txt
      writing requirements to Lib/python_ldap.egg-info/requires.txt
      writing top-level names to Lib/python_ldap.egg-info/top_level.txt
      reading manifest file &#39;Lib/python_ldap.egg-info/SOURCES.txt&#39;
      reading manifest template &#39;MANIFEST.in&#39;
      no previously-included directories found matching &#39;Doc/.build&#39;
      adding license file &#39;LICENCE&#39;
      writing manifest file &#39;Lib/python_ldap.egg-info/SOURCES.txt&#39;
      creating build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/README -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/ca.conf -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/ca.pem -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/client.conf -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/client.key -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/client.pem -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/gencerts.sh -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/gennssdb.sh -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/server.conf -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/server.key -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      copying Lib/slapdtest/certs/server.pem -&gt; build/lib.linux-x86_64-cpython-311/slapdtest/certs
      running build_ext
      building &#39;_ldap&#39; extension
      creating build/temp.linux-x86_64-cpython-311/Modules
      gcc -pthread -B /home/lfang/miniconda3/compiler_compat -DNDEBUG -fwrapv -O2 -Wall -fPIC -O2 -isystem /home/lfang/miniconda3/include -fPIC -O2 -isystem /home/lfang/miniconda3/include -fPIC -DHAVE_SASL -DHAVE_TLS -DLDAPMODULE_VERSION=3.4.4 &#34;-DLDAPMODULE_AUTHOR=python-ldap project&#34; &#34;-DLDAPMODULE_LICENSE=Python style&#34; -IModules -I/home/lfang/miniconda3/include/python3.11 -c Modules/LDAPObject.c -o build/temp.linux-x86_64-cpython-311/Modules/LDAPObject.o
      In file included from Modules/LDAPObject.c:3:0:
      Modules/common.h:15:18: fatal error: lber.h: No such file or directory
       #include &lt;lber.h&gt;
                        ^
      compilation terminated.
      error: command &#39;/shared/trading/lib/gcc/bin/gcc&#39; failed with exit code 1
      [end of output]

  note: This error originates from a subprocess, and is likely not a problem with pip.
  ERROR: Failed building wheel for python-ldap
Failed to build python-ldap
ERROR: Could not build wheels for python-ldap, which is required to install pyproject.toml-based projects
```

## 解决

### 安装 ldap 相关依赖包

```bash
yum install openldap-devel python-devel
```

### 安装 python-ldap

```bash
~/miniconda3/bin/python -m pip install python-ldap
                                                                                                                                            [Nov15 17:39:07]
Looking in indexes: https://mirrors.cloud.tencent.com/pypi/simple
Collecting python-ldap
  Using cached https://mirrors.cloud.tencent.com/pypi/packages/fd/8b/1eeb4025dc1d3ac2f16678f38dec9ebdde6271c74955b72db5ce7a4dbfbd/python-ldap-3.4.4.tar.gz (​‌​
377 kB)
  Installing build dependencies ... done
  Getting requirements to build wheel ... done
  Preparing metadata (pyproject.toml) ... done
Collecting pyasn1&gt;=0.3.7
  Using cached https://mirrors.cloud.tencent.com/pypi/packages/c8/f1/d6a797abb14f6283c0ddff96bbdd46937f64122b8c925cab503dd37f8214/pyasn1-0.6.1-py3-none-any.​‌​
whl (83 kB)
Collecting pyasn1-modules&gt;=0.1.5
  Using cached https://mirrors.cloud.tencent.com/pypi/packages/77/89/bc88a6711935ba795a679ea6ebee07e128050d6382eaa35a0a47c8032bdc/pyasn1_modules-0.4.1-py3-n​‌​
one-any.whl (181 kB)
Building wheels for collected packages: python-ldap
  Building wheel for python-ldap (pyproject.toml) ... done
  Created wheel for python-ldap: filename=python_ldap-3.4.4-cp311-cp311-linux_x86_64.whl size=286532 sha256=24023d98304c16abd74cebc2da6264630dc5514eb86ce72b​‌​
f45eb9c700f9ab3b
  Stored in directory: /home/lfang/.cache/pip/wheels/e1/1e/2b/95497b4a8f153525aa61c184a47e2fbf35ed9bba349a9c3b08
Successfully built python-ldap
Installing collected packages: pyasn1, pyasn1-modules, python-ldap
Successfully installed pyasn1-0.6.1 pyasn1-modules-0.4.1 python-ldap-3.4.4
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-11-15-%E5%AE%89%E8%A3%85-python-ldap/  

