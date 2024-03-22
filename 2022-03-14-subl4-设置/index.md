# subl4 设置


Sublim4 更新了一些功能，需要重新制作一个破解版。

&lt;!--more--&gt;


## 破解

[Patch-Sublime-License-Message](https://github.com/4B4DB4B3/Patch-Sublime-License-Message)

```markdown
Open sublime_text.exe in any hex editor.
Search HEX-template -&gt; B2690031C9E8E0A5170084C07410488D0DFBFE68004883C428E9025517009048
Replace it to -&gt; B2690031C9909090909090909090909090909090909090909090909090909048
Save.
This is nop call function for show message. This is not hacking software!
Working on 28.05.2021

UPDATED!!!
For Linux (Tested on Arch Linux)
Search HEX-template -&gt; 50befcd82000baab10210031ffe8bd79180084c07416488b05b9ed4a00bea7ae210031ff31d231c94158ffe058
Replace it to -&gt; 909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090
Save.

Working on 10.02.2021 for Sublime Text Build 4113
```


## 禁止更新

```bash
## vim /etc/hosts

127.0.0.1 www.sublimetext.com
127.0.0.1 license.sublimehq.com
127.0.0.1 45.55.255.55
127.0.0.1 45.55.41.223
127.0.0.1 www.sublimetext.com
127.0.0.1 sublimetext.com
127.0.0.1 sublimehq.com
127.0.0.1 license.sublimehq.com
127.0.0.1 45.55.255.55
127.0.0.1 45.55.41.223
0.0.0.0 license.sublimehq.com
0.0.0.0 45.55.255.55
0.0.0.0 45.55.41.223
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-03-14-subl4-%E8%AE%BE%E7%BD%AE/  

