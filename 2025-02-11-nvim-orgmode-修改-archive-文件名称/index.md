# nvim orgmode 修改 archive 文件名称


修改 `orgmode` 保存 `archive` 时的文件重命名。

&lt;!--more--&gt;

# file_name vs base_name

```bash
vim ~/.config/nvim/lazy/orgmode/lua/orgmode/config/init.lua
```

在函数 `function Config:parse_archive_location(file, archive_loc)`，将其改成 `base_name.x.org`

```lua
---@return string|nil
function Config:parse_archive_location(file, archive_loc)
  if self:is_archive_file(file) then
    return nil
  end

  archive_loc = archive_loc or self.opts.org_archive_location
  -- TODO: Support archive to headline
  local parts = vim.split(archive_loc, &#39;::&#39;)
  local archive_location = vim.trim(parts[1])
  if not archive_location:find(&#39;%%s&#39;) then
    return vim.fn.fnamemodify(archive_location, &#39;:p&#39;)
  end

  local file_path = vim.fn.fnamemodify(file, &#39;:p:h&#39;)
  -- local file_name = vim.fn.fnamemodify(file, &#39;:t&#39;)

  -- use base_name.x.org to
  local base_name = vim.fn.fnamemodify(file, &#39;:t:r&#39;)
  local file_name = base_name .. &#39;.x.org&#39;
  -- utils.echo_warning(string.format(&#39;Base file name: %s&#39;, base_name))
  -- utils.echo_warning(string.format(&#39;Archive file name: %s&#39;, file_name))
  -- vim.notify(base_name, vim.log.levels.INFO)
  -- vim.notify(file_name, vim.log.levels.INFO)

  local archive_filename = string.format(archive_location, file_name)

  -- If org_archive_location is defined as relative path (example: &#34;archive/%s_archive&#34;)
  -- then we need to prepend the file path to it
  local is_full_path = fs.substitute_path(archive_filename)

  if not is_full_path then
    return string.format(&#39;%s/%s&#39;, file_path, archive_filename)
  end

  return vim.fn.fnamemodify(archive_filename, &#39;:p&#39;)
end
```

# conf 配置 archive 保存路径

```lua
local org_path = function(path)
    local org_directory = &#39;~/orgfiles&#39;
    return (&#39;%s/%s&#39;):format(org_directory, path)
end

local org_directory = {}
org_directory.root = os.getenv(&#34;HOME&#34;) .. &#34;/orgfiles/&#34;
org_directory.archive = org_directory.root .. &#34;archive/&#34;
local meeting_notes = org_directory.root .. &#34;meeting-notes/%&lt;%Y-%m-%d %A&gt;.org&#34;

return {
    &#39;nvim-orgmode/orgmode&#39;,
    dependencies = {
        { &#39;nvim-orgmode/org-bullets.nvim&#39; },
        { &#34;dhruvasagar/vim-table-mode&#34; },
        { &#39;nvim-treesitter/nvim-treesitter&#39; },
        { &#34;folke/todo-comments.nvim&#34; },
    },
    lazy = true,
    ft = { &#39;org&#39;, &#39;orgagenda&#39; },
    config = function()
        -- Setup orgmode
        require(&#39;orgmode&#39;).setup({
            -- org_archive_location = &#34;~/orgfiles/archive/%s::&#34;,
            org_archive_location = org_directory.archive .. &#34;%s::&#34;,
        })
    end
}
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-02-11-nvim-orgmode-%E4%BF%AE%E6%94%B9-archive-%E6%96%87%E4%BB%B6%E5%90%8D%E7%A7%B0/  

