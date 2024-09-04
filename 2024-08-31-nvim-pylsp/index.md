# nvim pylsp


通过配置 `lsp`，可以在 `nvim` 中方便地实现 `python` 的自动补全功能（基于语法语义）

&lt;!--more--&gt;

## 允许加载第三方库

通过配置 `include-system-site-packages=true`，获取第三方库信息，从而实现在代码中语法的补全功能。

```bash
## fix python auto-complete
sed -i &#34;s|.*include-system-site-packages.*|include-system-site-packages=true|g&#34; ~/.config/nvim/lazy/mason/packages/python-lsp-server/venv/pyvenv.cfg
```

## python-lsp-jsonrpc

有时我们会遇到报错信息

```
pylsp_josonrpc/endpoint.py error
```

说明需要升级 `python-lsp-jsonrpc`

```bash
python -m pip install -U python-lsp-server[all] tornado
python -m pip install -U python-lsp-jsonrpc
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-08-31-nvim-pylsp/  

