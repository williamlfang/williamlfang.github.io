# nvim 配置 markdown 实时渲染


我现在基本上都是使用nvim做笔记，大部分的时间都是写 markdown 格式的文档。因此，需要一款能够在终端实时渲染的插件。

&lt;!--more--&gt;

## glow

`glow` 是一款可以在终端渲染 markdown 文档的命令

```bash
# Debian/Ubuntu
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo &#34;deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *&#34; | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update &amp;&amp; sudo apt install glow

# Fedora/RHEL
echo &#39;[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key&#39; | sudo tee /etc/yum.repos.d/charm.repo
sudo yum install glow
```

## markdown-preview.nvim

这款插件支持在 nvim 的终端即可渲染 markdown，底层调用的是 `glow` 的渲染功能。

我这里配置了快捷键：`mp`

```lua
-- :MPToggle: toggle markdown preview open or close.
-- :MPOpen: open markdown preview window.
-- :MPClose: close markdown preview window.
-- :MPRefresh: refresh markdown preview window.
return {
    &#34;0x00-ketsu/markdown-preview.nvim&#34;,
    ft = {&#39;md&#39;, &#39;markdown&#39;, &#39;mkd&#39;, &#39;mkdn&#39;, &#39;mdwn&#39;, &#39;mdown&#39;, &#39;mdtxt&#39;, &#39;mdtext&#39;, &#39;rmd&#39;, &#39;wiki&#39;},
    cmd = { &#34;MPToggle&#34;, &#34;MPOpen&#34;, &#34;MPClose&#34;, &#34;MPRefresh&#34; },
    config = function()
        require(&#39;markdown-preview&#39;).setup {
            -- 配置快捷键:mp
            vim.keymap.set( &#34;n&#34;, &#34;mp&#34;, &#34;:MPToggle&lt;CR&gt;&#34;, { silent = true }),
            glow = {
                -- When find executable path of `glow` failed (from PATH), use this value instead
                exec_path = &#39;&#39;,
                style = &#39;&#39;, -- Path to glamour JSON style file
            },
            -- Markdown preview term
            term = {
                -- reload term when rendered markdown file changed
                reload = {
                    enable = true,
                    events = {
                        &#39;InsertLeave&#39;,
                        &#39;TextChanged&#39;
                    },
                },
                direction = &#39;vertical&#39;, -- choices: vertical / horizontal
                keys = {
                    close = {&#39;q&#39;, &#39;&lt;Esc&gt;&#39;},
                    refresh = &#39;r&#39;,
                }
            }
        }
    end
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-13-nvim-%E9%85%8D%E7%BD%AE-markdown-%E5%AE%9E%E6%97%B6%E6%B8%B2%E6%9F%93/  

