# vim coc 生成 compile_commands.json


`vim` 使用 `coc` 需要找到 `compile_commands.json`。

&lt;!--more--&gt;

- 第一种方法，通过命令行添加，会在 `build` 目录下面自动生成

    ```bash
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1
    ```
    默认勤快下，`compile_commands.json` 是放在 `./build` 目录，如果不想要手动复制或者 ln，可以在 `neovim` 修改

    ```lua
    return {
        &#34;neovim/nvim-lspconfig&#34;,
        enabled = true,
        lazy = true,
        event = &#34;BufReadPost&#34;,
        dependencies = {
            { &#34;folke/neoconf.nvim&#34;, cmd = &#34;Neoconf&#34;, config = false, dependencies = { &#34;nvim-lspconfig&#34; } },
            { &#34;folke/neodev.nvim&#34;, opts = {} },
            { &#34;mason.nvim&#34; },
            { &#34;williamboman/mason-lspconfig.nvim&#34; },
            { &#39;saghen/blink.cmp&#39; }, -- FIXME: this may cause inlay_hints
        },
        ---------------------------------------------------------------------------
        ---FIXME: this cause statuscol fail to show sign
        ---FIXME: this cause inlay_hints fail to show sign
        config = function(_, opts)
            local lspconfig = require(&#39;lspconfig&#39;)
            for server, config in pairs(opts.servers) do
                -- passing config.capabilities to blink.cmp merges with the capabilities in your
                -- `opts[server].capabilities, if you&#39;ve defined it
                config.capabilities = require(&#39;blink.cmp&#39;).get_lsp_capabilities(config.capabilities)
                lspconfig[server].setup(config)
            end

            --HACK: cmake with compile_commands.json
            require(&#39;lspconfig&#39;).clangd.setup{
                init_options = {
                    compilationDatabasePath = &#39;./build&#39;
                }
            }
        end
    }
    ```

- 第二种方法，通过修改 `CMakeLists.txt`

    ```cmake
    SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    IF(EXISTS &#34;${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json&#34;)
        EXECUTE_PROCESS( COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
            ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
      )
    ENDIF()
    ```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-08-25-vim-coc-%E7%94%9F%E6%88%90-compile_commands.json/  

