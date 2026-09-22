# opencode.nvim 窗口调整




&lt;!--more--&gt;

# opencode.nvim 窗口宽度修复

## 问题

`opencode.nvim` 配置了 `window_width = 0.40`（右边窗口占页面 40%），但实际打开后右边窗口始终占据 50% 宽度。

## 根因分析

### 根因 1：split 模式下未应用 `window_width`

`opencode.nvim` 的 `window_width` 配置只在 float 模式下生效。当 `position = &#39;right&#39;`（split 模式）时，创建窗口的 `create_split_windows` 函数只执行了 `botright vsplit`，没有设置宽度，导致 Neovim 默认将窗口均分为 50%。

**相关文件：** `lazy/opencode.nvim/lua/opencode/ui/ui.lua`，`create_split_windows` 函数

### 根因 2：filetype 设置时序导致 `windows.nvim` 冲突

`windows.nvim` 的 `autowidth` 功能在 `BufWinEnter` 事件触发时会检查窗口 buffer 的 filetype 是否在 ignore 列表中。但 opencode 的 output buffer 的 filetype（`opencode_output`）是在 buffer **挂到窗口之后**才设置的：

1. `create_split_windows` 调用 `nvim_win_set_buf` → 触发 `BufWinEnter`
2. `windows.nvim` 检查 filetype → 此时还是空的 → 不匹配 ignore 列表
3. `windows.nvim` 执行 `autowidth` 把窗口均分回 50%
4. opencode 之后才设置 filetype（太晚了）

**相关文件：** `lazy/opencode.nvim/lua/opencode/ui/output_window.lua`，`create_buf` 函数

## 修复方法

### 修改 1：`lazy/opencode.nvim/lua/opencode/ui/ui.lua`

在 `create_split_windows` 函数中，创建垂直 split 后，根据 `config.ui.window_width` 计算并设置输出窗口宽度。

```diff
  vim.api.nvim_win_set_buf(input_win, windows.input_buf)
  vim.api.nvim_win_set_buf(output_win, windows.output_buf)
&#43;
&#43; -- Apply configured window_width for vertical splits (default vsplit is 50/50)
&#43; if windows.position == &#39;right&#39; or windows.position == &#39;left&#39; then
&#43;   local target_cols = math.floor(vim.o.columns * (config.ui.window_width or 0.40))
&#43;   pcall(vim.api.nvim_win_set_width, output_win, target_cols)
&#43; end
&#43;
  return { input_win = input_win, output_win = output_win }
```

### 修改 2：`lazy/opencode.nvim/lua/opencode/ui/output_window.lua`

在 `create_buf` 函数中，buffer 创建后立即设置 filetype，确保在 buffer 挂到窗口之前 filetype 已就位。

```diff
 function M.create_buf()
   local output_buf = vim.api.nvim_create_buf(false, true)

&#43;  vim.api.nvim_set_option_value(&#39;filetype&#39;, config.ui.output.filetype or &#39;opencode_output&#39;, { buf = output_buf })
   vim.api.nvim_buf_set_var(output_buf, &#39;opencode_folds&#39;, build_fold_state({}))
```

## 相关插件版本

- opencode.nvim：`sudo-tee/opencode.nvim`
- windows.nvim：`anuvyklack/windows.nvim`（`autowidth.enable = true`）

## 注意

这些修改位于 lazy 安装的插件源码中（`lazy/opencode.nvim/`），如果重新安装或更新 opencode.nvim，需要重新应用这些 patch。


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-07-22-opencode.nvim-%E7%AA%97%E5%8F%A3%E8%B0%83%E6%95%B4/  

