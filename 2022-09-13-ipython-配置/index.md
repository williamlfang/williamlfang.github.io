# ipython 配置


通过配置 `ipython` 以获得更好的编辑体验。

&lt;!--more--&gt;

## prompt 设置

### 配置文件

```bash
~/anaconda3/bin/ipython profile create

[ProfileCreate] Generating default config file: &#39;/home/william/.ipython/profile_default/ipython_config.py&#39;
[ProfileCreate] Generating default config file: &#39;/home/william/.ipython/profile_default/ipython_kernel_config.py&#39;

cd ~/.ipython/profile_default/
vim ipython_config.py


## 修改颜色
## Set the color scheme (NoColor, Neutral, Linux, or LightBG).
#  Choices: any of [&#39;Neutral&#39;, &#39;NoColor&#39;, &#39;LightBG&#39;, &#39;Linux&#39;] (case-insensitive)
#  Default: &#39;Neutral&#39;
# c.InteractiveShell.colors = &#39;Neutral&#39;
c.InteractiveShell.colors = &#39;NoColor&#39;
```

或者启动的时候指定颜色方案

```bash
~/anaconda3/bin/ipython --colors=NoColor
```

或者运行时设置

```bash
[1] %colors nocolor
```

## 定制配置

在 ``~.ipython/profile_default/ipython_config.py` 添加

```bash
# ~/anaconda3/bin/ipython profile create
# vim ~/.ipython/profile_default/ipython_config.py
from IPython.terminal.prompts import Prompts, Token
import os

class MyPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):   # custom
        path = os.path.basename(os.getcwd())
        user = os.environ[&#39;USER&#39;]
        return [
            (Token.Prompt, &#39;&#39;),
            (Token.PromptNum, f&#34;{path}❯ &#34;),
            (Token.Prompt, &#39;In [&#39;),
            (Token.PromptNum, str(self.shell.execution_count)),
            (Token.Prompt, &#39;]&#39;),
            (Token.Prompt, &#39;: &#39;),
        ]

## ====================================================
c = get_config()
c.TerminalInteractiveShell.prompts_class = MyPrompt
c.InteractiveShell.colors = &#39;NoColor&#39;
c.TerminalIPythonApp.display_banner = False
## ====================================================


&#34;&#34;&#34; 如果需要运行时设置，可以使用以下命令
ip = get_ipython()
ip.prompts = MyPrompt(ip)
&#34;&#34;&#34;
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-09-13-ipython-%E9%85%8D%E7%BD%AE/  

