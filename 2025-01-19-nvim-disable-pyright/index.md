# nvim disable pyright


While using `ruff-lsp` for Python diagnostics, I find it redundant to have `pyright` still active for all Python scripts. So I decide to **disable** it.


This is how I managed to solve it.

&lt;!--more--&gt;

# nvim-lspconfig

Firstly, we need to **explicitly** overwrite the config, telling `nimv-lspconfig` not to provide **default** for us.

```lua
return {
    &#34;neovim/nvim-lspconfig&#34;,
    opts = {
        servers = {
            -- disable pyright
            pyright = {
            mason = false,
            autostart = false,
            },
        },
    },
}
```

# uninstall pyright

Secondly, we need to **uninstall** the `pyright` module if it&#39;s installed, by running following command

```bash
npm uninstall -g pyright
```

Now, the `pyright` is totally gone.



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-19-nvim-disable-pyright/  

