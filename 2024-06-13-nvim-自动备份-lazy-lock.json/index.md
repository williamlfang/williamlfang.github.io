# nvim 自动备份 lazy lock.json


```lua
-- backup: lazy-lazy.json
local lazy_cmds = vim.api.nvim_create_augroup(&#39;lazy_cmds&#39;, {clear = true})
local root = os.getenv(&#34;HOME&#34;) .. &#34;/.config/nvim/lazy&#34;
local snapshot_dir = root .. &#39;/plugin-snapshot&#39;
os.execute(&#34;mkdir &#34; .. snapshot_dir)
local lockfile = root .. &#39;/lazy-lock.json&#39;
vim.api.nvim_create_user_command(
    &#39;BrowseSnapshots&#39;,
    &#39;edit &#39; .. snapshot_dir,
    {}
)
vim.api.nvim_create_autocmd(&#39;User&#39;, {
    group = lazy_cmds,
    pattern = &#39;LazyUpdatePre&#39;,
    desc = &#39;Backup lazy.nvim lockfile&#39;,
    callback = function(event)
        vim.fn.mkdir(snapshot_dir, &#39;p&#39;)
        local snapshot = snapshot_dir .. os.date(&#39;/%Y-%m-%dT%H:%M:%S.lazy-lock.json&#39;)
        vim.loop.fs_copyfile(lockfile, snapshot)
    end,
})
```

- `:Lazy restore`

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-06-13-nvim-%E8%87%AA%E5%8A%A8%E5%A4%87%E4%BB%BD-lazy-lock.json/  

