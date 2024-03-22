# tmux 窗口重命名:rename window


实现在 `tmux` 对窗口的重命名

&lt;!--more--&gt;


1. 使用快捷键`prefix &#43; :(shift&#43;,)`, 输入`rename-window &lt;new-name&gt;`
2. 绑定一个新的快捷键来操作：`prefix&#43;o`
    ```bash
    bind-key o command-prompt -I &#34;#W&#34; &#34;rename-window &#39;%%&#39;&#34;
    ```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-15-tmux-%E7%AA%97%E5%8F%A3%E9%87%8D%E5%91%BD%E5%90%8D-rename-window/  

