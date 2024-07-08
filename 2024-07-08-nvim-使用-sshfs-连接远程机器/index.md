# nvim 使用 sshfs 连接远程机器


`nvim` 可以通过调用 `sshfs`，把远程机器上面的文件映射到本地，进而使用本地的 `nvim` 进行查看与编辑。如此一来，即使远程机器没有安装 `nvim` 或者相关插件，我们一样也能丝滑地使用 `nvim` 了。

&lt;!--more--&gt;

```lua
return {
    &#34;nosduco/remote-sshfs.nvim&#34;,
    dependencies = { &#34;nvim-telescope/telescope.nvim&#34; },
    opts = {
        -- Refer to the configuration section below
        -- or leave empty for defaults
    },
    config = function()
        require(&#39;remote-sshfs&#39;).setup{
            connections = {
                ssh_configs = { -- which ssh configs to parse for hosts list
                    vim.fn.expand &#34;$HOME&#34; .. &#34;/.ssh/config&#34;,
                    &#34;/etc/ssh/ssh_config&#34;,
                    -- &#34;/path/to/custom/ssh_config&#34;
                },
                sshfs_args = { -- arguments to pass to the sshfs command
                    &#34;-o reconnect&#34;,
                    &#34;-o auto_cache&#34;,
                    &#34;-o Ciphers=aes128-ctr&#34;,
                    &#34;-o ConnectTimeout=5&#34;,
                    &#34;-C&#34;,
                    &#34;-o cache_timeout=60&#34;,
                    &#34;-o cache=yes&#34;,
                },
            },
            mounts = {
                base_dir = vim.fn.expand &#34;$HOME&#34; .. &#34;/.sshfs/&#34;, -- base directory for mount points
                unmount_on_exit = true, -- run sshfs as foreground, will unmount on vim exit
            },
            handlers = {
                on_connect = {
                    change_dir = true, -- when connected change vim working directory to mount point
                },
                on_disconnect = {
                    clean_mount_folders = true, -- remove mount point folder on disconnect/unmount
                },
                on_edit = {}, -- not yet implemented
            },
            ui = {
                select_prompts = false, -- not yet implemented
                confirm = {
                    connect = true, -- prompt y/n when host is selected to connect to
                    change_dir = false, -- prompt y/n to change working directory on connection (only applicable if handlers.on_connect.change_dir is enabled)
                },
            },
            log = {
                enable = false, -- enable logging
                truncate = false, -- truncate logs
                types = { -- enabled log types
                    all = false,
                    util = false,
                    handler = false,
                    sshfs = false,
                },
            },
        }
    end
}
```

## 使用

可以使用以下命令进行连接

- `:RemoteSSHFSConnect lfang.r9:/home/lfang/git -p22`
- `:RemoteSSHFSDisconnect`

我们可以映射到快捷键

```lua
local opts = {
    noremap = true, -- non-recursive
    silent = true,  -- do not show message
}
vim.api.nvim_set_keymap(&#34;n&#34;, &#34;&lt;Leader&gt;rs&#34;, &#34;:RemoteSSHFSConnect lfang.r9:/home/lfang/git -p22&lt;CR&gt;&#34;, opts)
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-08-nvim-%E4%BD%BF%E7%94%A8-sshfs-%E8%BF%9E%E6%8E%A5%E8%BF%9C%E7%A8%8B%E6%9C%BA%E5%99%A8/  

