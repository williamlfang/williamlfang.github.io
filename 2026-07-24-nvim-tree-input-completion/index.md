# nvim tree input completion


# nvim-tree 删除/垃圾箱确认提示中禁用 blink-cmp 自动补全

## 问题

在 nvim-tree 中执行 Remove/Trash 操作时，dressing.nvim 会弹出确认对话框（DressingInput buffer，`filetype = &#34;DressingInput&#34;`）。用户输入 `y`/`n` 时，blink-cmp 会在这个 buffer 中触发自动补全，干扰确认操作。

&lt;!--more--&gt;

## 原因

1. nvim-tree 通过 dressing.nvim 的 `vim.ui.input` 显示确认提示，dressing.nvim 创建的 buffer 的 filetype 为 `DressingInput`
2. blink-cmp 没有排除 `DressingInput`/`DressingSelect` 这些 filetype
3. blink-cmp 内部在 `config/init.lua:136` 检查 `vim.b.completion == false`，如果设置为 `false` 则跳过补全

## 解决方案

### 1. `blink-cmp.lua` — 在 `enabled` 检查中加入 DressingInput/DressingSelect

```lua
-- blink-cmp.lua
enabled = function()
    return not vim.tbl_contains({ &#34;lua&#34;, &#34;markdown&#34;, &#34;neo-tree&#34;, &#34;DressingInput&#34;, &#34;DressingSelect&#34; }, vim.bo.filetype)
        and vim.bo.buftype ~= &#34;prompt&#34;
        and vim.b.completion ~= false
end,
```

### 2. `nvim-tree.lua` — 在 config 中注册 FileType autocmd（关键）

**必须放在 nvim-tree 的 `config` 函数中，而不是 blink-cmp 的 config 中**，确保 autocmd 在首次删除之前就已注册。

```lua
-- nvim-tree.lua, config 函数中，require(&#34;nvim-tree&#34;).setup 之前
vim.api.nvim_create_autocmd(&#34;FileType&#34;, {
    group = vim.api.nvim_create_augroup(&#34;NvimTreeDressingDisable&#34;, { clear = true }),
    pattern = { &#34;DressingInput&#34;, &#34;DressingSelect&#34; },
    callback = function()
        vim.b.completion = false
    end,
})
```

## 为什么不能放在 blink-cmp 的 config 中

blink-cmp 是 lazy 加载的（`event = { &#34;InsertEnter&#34;, &#34;CmdlineEnter&#34; }`）。首次删除操作时，DressingInput 的 `InsertEnter` 事件触发 blink-cmp 加载，但此时它的 `config` 函数中的 autocmd 还来不及注册，导致第一次仍然出现补全。第二次删除时 autocmd 已存在，所以正常。

将 autocmd 放在 nvim-tree 的 config 中（nvim-tree 在打开界面时就加载），确保 autocmd 始终在 DressingInput 创建之前就已就位。


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-07-24-nvim-tree-input-completion/  

