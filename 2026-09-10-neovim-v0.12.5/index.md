# neovim v0.12.5




&lt;!--more--&gt;

git clone --depth 1 --branch stable https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=&#34;$HOME/.local&#34;

Then you preserved that installed binary and made it the default:

mv ~/.local/bin/nvim ~/.local/bin/nvim.v0.12.5
ln -sfn ~/.local/bin/nvim.v0.12.5 ~/.local/bin/nvim

export PATH=&#34;$HOME/.local/bin:$PATH&#34;
nvim --version

Your historical install reported as v0.12.5.
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-10-neovim-v0.12.5/  

