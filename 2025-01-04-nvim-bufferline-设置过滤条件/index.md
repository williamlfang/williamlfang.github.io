# nvim bufferline 设置过滤条件


今天在写代码的时候，遇到一个有趣的事情：有时候我们只打开一个文件，但是 `bufferline` 也会显示该文件相关的操作。

&lt;!--more--&gt;

![bufferline](./bufferline.png &#34;bufferline show up for only one opened file&#34;)

## 过滤条件

其实 `bufferline` 有提供了一个 `custom_filter` 的过滤机制，允许我们通过设置一定的条件，不要显示文件。这个回调函数提供了两个参数

- `buf_number`: 当前 `buffer` 的下标
- `buf_numbers`: 包含所有 `buffer` 的一个列表信息

可以实现的过滤条件有：

- 文件类型
- 目录
- 以及我们这次讨论的基于数量的过滤

![bufferline-noshow](./bufferline-noshow.png &#34;bufferline do not show for only on opened file&#34;)

## 实现

通过对比 `buf_numbers` 的数量，返回一个布尔值

```lua
config = function()
    local bufferline = require(&#34;bufferline&#34;)
    require(&#34;bufferline&#34;).setup({
        options = {
            custom_filter = function(buf_number, buf_numbers)
                if #(buf_numbers) &lt; 2 then
                    return false
                end
                return true
            end,
        }
    })
end
```

全部的代码可以参考：

```lua
return {
    &#39;akinsho/bufferline.nvim&#39;,
    dependencies = {
        &#39;nvim-tree/nvim-web-devicons&#39;,
        &#34;famiu/bufdelete.nvim&#34;,
    },
    enabled = true,
    event = &#34;BufRead&#34;,
    config = function()
        local bufferline = require(&#34;bufferline&#34;)
        require(&#34;bufferline&#34;).setup({
            options = {
                custom_filter = function(buf_number, buf_numbers)
                    --如果是defx则隐藏
                    local finded, _ = string.find(vim.bo[buf_number].filetype, &#34;defx&#34;)
                    if finded ~= nil then
                        return false
                    end
                    -- filter out filetypes you don&#39;t want to see
                    -- if vim.bo[buf_number].filetype ~= &#34;&lt;i-dont-want-to-see-this&gt;&#34; then
                    --     return true
                    -- end
                    -- filter out by buffer name
                    -- if vim.fn.bufname(buf_number) ~= &#34;&lt;buffer-name-I-dont-want&gt;&#34; then
                    --     return true
                    -- end
                    -- filter out based on arbitrary rules
                    -- e.g. filter out vim wiki buffer from tabline in your work repo
                    -- if vim.fn.getcwd() == &#34;&lt;work-repo&gt;&#34; and vim.bo[buf_number].filetype ~= &#34;wiki&#34; then
                    --     return true
                    -- end
                    -- filter out by it&#39;s index number in list (don&#39;t show first buffer)
                    -- if buf_numbers[1] ~= buf_number then
                    --     return false
                    -- end
                    -- do not show when total buffer number is 1
                    if #(buf_numbers) &lt; 2 then
                        return false
                    end
                    return true
                end,
        })
    end,
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-04-nvim-bufferline-%E8%AE%BE%E7%BD%AE%E8%BF%87%E6%BB%A4%E6%9D%A1%E4%BB%B6/  

