# nvim im select remote 在远程机器上丝滑切换输入法


`im-select.nvim` 解决了在本地机器的终端上面丝滑切换中英文输入法。但是我回到家里，需要连接到公司的远程服务器，然后再登录
我的 `tmux` 回话，即可快速返回下班前的工作状态了。这时候如果需要在 `tmux` 使用 `vim` 进行中文输入，就
无法再使用 `im-select` 的切换功能了，因为其使用使用的是本地的输入法切换，在远程环境中，无法调用。


这时候我发现一个可以让 `nvim` 远程调用本地的输入法切换命令：

- 一旦进入 `insert` 模式，就从远程发送一个命令给本地，要求切换到中文输入法
- 一旦退出 `insert` 模式（即按下 `Esc`），再从远程发送一个命令给本地，要求切换到英文，这样就可以在 `normal` 模式下使用各种按键了。

&lt;!--more--&gt;

# 自动切换中英文输入法

我安装的项目是 [`im-select-remote`](https://github.com/mkdir700/im-select-remote.nvim)。一开始按照上面的配置安装，并没有成功。后来仔细研究了一下代码，发现这里面只是调用切换会英文输入法的命令，但是没有继续切换到中文输入法。里面的代码相对简单

在代码 `~/.config/nvim/lazy/im-select-remote.nvim/lua/im-select-remote.lua`

```lua
M.IMSelectSocketEnable = function()
  vim.notify(&#34;IMSelectRemote: Socket enabled&#34;, vim.log.levels.INFO)
  vim.cmd([[
      augroup im_select_remote
        autocmd!
        autocmd BufEnter * lua require(&#34;im-select-remote&#34;).IMSelectBySocket()
        autocmd InsertLeave * lua require(&#34;im-select-remote&#34;).IMSelectBySocket()
      augroup END
    ]])
end
```

这里调用了 `config.command` 的操作，但是这个命令是一条固定的语句，

```lua
command = &#34;fcitx-remote -c&#34;
```

如果我们想要扩展，需要进行判断。于是可以修改城

```lua
-- 添加两个命令
-- command_enter： fcitx-remote -o
-- command_leave： fcitx-remote -c
local M = {}
M.config = {
  osc = {
    secret = &#34;&#34;,
  },
  socket = {
    port = 23333,
    max_retry_count = 3,
    command_enter = &#34;fcitx-remote -o&#34;,
    command_leave = &#34;fcitx-remote -c&#34;,
  },
}

--- IMSelectBySocket
-- @treturn int the exit code of the command
M.IMSelectBySocket = function(command)
  local function on_stdout() end
  local cmd = &#34;echo &#34;
    .. vim.fn.shellescape(command)
    .. &#34; | nc localhost &#34;
    .. M.config.socket.port
    .. &#34; -q 0&#34;
  vim.fn.jobstart(cmd, {
    on_stdout = on_stdout,
    on_stderr = on_stdout,
    on_exit = on_stdout,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end
-- 进入 insert 模式
M.IMSelectBySocketEnter = function()
    -- M.IMSelectBySocket(&#34;fcitx-remote -o&#34;)
    M.IMSelectBySocket(M.config.socket.command_enter)
end
-- 退出 insert，进入 normal 模式
M.IMSelectBySocketLeave = function()
    -- M.IMSelectBySocket(&#34;fcitx-remote -c&#34;)
    M.IMSelectBySocket(M.config.socket.command_leave)
end

M.IMSelectSocketEnable = function()
    if vim.bo.filetype ~= &#34;markdown&#34; then
        return
    end
    -- if M.config.ft[vim.bo.filetype] == nil then
    --     return
    -- end
    vim.notify(&#34;IMSelectRemote: Socket enabled&#34;, vim.log.levels.INFO)
    vim.cmd([[
        augroup im_select_remote
            autocmd!
            &#34; autocmd BufEnter * lua require(&#34;im-select-remote&#34;).IMSelectBySocket()
            &#34; autocmd InsertLeave * lua require(&#34;im-select-remote&#34;).IMSelectBySocket()
            &#34; autocmd InsertEnter * lua require(&#34;im-select-remote&#34;).IMSelectBySocketEnter()
            &#34; autocmd InsertLeave * lua require(&#34;im-select-remote&#34;).IMSelectBySocketLeave()
            autocmd InsertEnter *.md lua require(&#34;im-select-remote&#34;).IMSelectBySocketEnter()
            autocmd InsertLeave *.md lua require(&#34;im-select-remote&#34;).IMSelectBySocketLeave()
        augroup END
        ]])
end

-- 修改成默认关闭状态，可以通过命令打开：IMSelectSocketEnable
M.setup = function(args)
  M.config = vim.tbl_deep_extend(&#34;force&#34;, M.config, args or {})
  if check_auto_enable_socket() then
    for i = 1, M.config.socket.max_retry_count do
      local result = os.execute(&#34;nc -z localhost &#34; .. M.config.socket.port .. &#34; -q 0&#34;)
      if result == 0 then
        break
      end
      retry_count = i
      vim.cmd(&#34;sleep 50m&#34;)
    end

    if retry_count == M.config.socket.max_retry_count then
      vim.notify(&#34;IMSelectServer is not running, please start it first!&#34;, vim.log.levels.WARN)
      return
    end

    -- M.IMSelectSocketEnable()
    M.IMSelectDisable()
  end
end
```

# 完整的配置

## 安装插件

```lua
return {
    &#34;mkdir700/im-select-remote.nvim&#34;,
    lazy = true,
    event = &#39;BufRead&#39;,
    ft = {&#34;markdown&#34;},
    config = function()
        require(&#39;im-select-remote&#39;).setup({
            osc = {
                secret = &#34;&#34;,
            },
            socket = {
                port = 23333,
                max_retry_count = 3,
                -- command_enter = &#34;fcitx-remote -o&#34;,
                -- command_leave = &#34;fcitx-remote -c&#34;,
            },
        })
    end
}
```

## 修改代码

按照如上进行修改 `~/.config/nvim/lazy/im-select-remote.nvim/lua/im-select-remote.lua`

## 服务端配置

在服务端 `~/.ssh/config` 添加

```bash
Host local
    HostName localhost
    Port 23333
    User william
```

## 本地配置

在本地 `~/.ssh/config` 添加，其中 `192.168.1.82` 是服务端 ip 地址。

```bash
Host *
    ServerAliveInterval 60
    IdentitiesOnly=yes
    StrictHostKeyChecking=no
    ForwardAgent yes

Host william
    HostName 192.168.1.82
    User william
    Port 22
    # 用于端口转发
    RemoteForward 127.0.0.1:23333 127.0.0.1:23333
    ServerAliveInterval 240
```

### 启动服务接收命令

在本地执行

```bash
cd ~/.config/nvim/lazy/im-select-remote.nvim/server

bash ./im-server.sh
```

如此一来，我们就可以把服务端的命令从 `23333` 转发到本地，然后执行切换输入法的命令了。

happing hacking，完美解决中英文切换问题。



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-10-nvim-im-select-remote-%E5%9C%A8%E8%BF%9C%E7%A8%8B%E6%9C%BA%E5%99%A8%E4%B8%8A%E4%B8%9D%E6%BB%91%E5%88%87%E6%8D%A2%E8%BE%93%E5%85%A5%E6%B3%95/  

