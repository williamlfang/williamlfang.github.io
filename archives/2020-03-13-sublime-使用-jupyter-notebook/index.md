# Sublime 使用 Jupyter Notebook




# 安装



## 安装 pyzmq

```bash
## 需要安装 pyzmq
pc /usr/bin/python3.6 -m pip install pyzmqc
```

## 安装 Helium

在 `Sublime` 中打开 `Shift&#43;Ctrl&#43;P`，然后输入 `Helium` 进行安装



# 打开 Jupyter

先在命令行打开

```bash
jupyterlab
```

然后使用命令进行查询连接信息

```bash
## 在 Jupyter 里面执行 magic 方法
%connect_info

{
  &#34;shell_port&#34;: 51835,
  &#34;iopub_port&#34;: 43591,
  &#34;stdin_port&#34;: 37817,
  &#34;control_port&#34;: 39041,
  &#34;hb_port&#34;: 50915,
  &#34;ip&#34;: &#34;127.0.0.1&#34;,
  &#34;key&#34;: &#34;f4739d3c-a1e6462527617877ebf90e25&#34;,
  &#34;transport&#34;: &#34;tcp&#34;,
  &#34;signature_scheme&#34;: &#34;hmac-sha256&#34;,
  &#34;kernel_name&#34;: &#34;&#34;
}

Paste the above JSON into a file, and connect with:
    $&gt; jupyter &lt;app&gt; --existing &lt;file&gt;
or, if you are local, you can connect with just:
    $&gt; jupyter &lt;app&gt; --existing kernel-7826a41d-5ed1-4014-b421-a9205a712668.json
or even just:
    $&gt; jupyter &lt;app&gt; --existing
if this is the most recent Jupyter kernel you have started.
```

# 连接 Helium

- 在 Sublime 打开，`Hermes: connect kernel`，然后输入以上的连接信息
- 打开命令 `Hermes: Execute Block` 执行命令

![](/images/2020-03-13-Sublime-使用-Jupyter-Notebook/helium.png)

# 快捷键



# 连接远程服务器



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-03-13-sublime-%E4%BD%BF%E7%94%A8-jupyter-notebook/  

