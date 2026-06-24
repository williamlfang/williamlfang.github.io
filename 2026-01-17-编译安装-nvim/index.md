# 编译安装 nvim


&lt;!--more--&gt;

```bash
git clone https://github.com/neovim/neovim
git checkout stable

# 创建构建目录
mkdir build &amp;&amp; cd build

# 配置 CMake 指定安装路径
cmake .. \
  -DCMAKE_INSTALL_PREFIX=$HOME/.local/neovim \
  -DCMAKE_PREFIX_PATH=$HOME/.local \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_JEMALLOC=ON \

# 自定义所有路径
# cmake .. \
#   -DCMAKE_INSTALL_PREFIX=$HOME/apps/neovim \
#   -DCMAKE_PREFIX_PATH=$HOME/.local \
#   -DCMAKE_BUILD_TYPE=Release \
#   -DENABLE_JEMALLOC=ON \
#   -DLIBLUV_LIBRARY=$HOME/.local/lib/libluv.so \
#   -DLIBLUV_INCLUDE_DIR=$HOME/.local/include/luajit-2.1

# 编译并安装到自定义路径
make -j$(nproc)
make install
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-01-17-%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85-nvim/  

