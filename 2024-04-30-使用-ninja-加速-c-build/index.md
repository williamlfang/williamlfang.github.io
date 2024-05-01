# 使用 ninja 加速 c&#43;&#43; build


`ninja` 和 `make` 是一样属于 **build system**，不过提供了更好的编译速度，尤其对于大型开发项目，可以节省大量的编译时间。

&lt;!--more--&gt;

## install

```bash
## centos
sudo yum install ninja-build

## ubuntu
sudo apt install ninja-build

ninja --version

1.10.0
```

## 常用命令与参数

```bash
## 使用 cmake 生成 build.ninja
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DDEFINE_DEBUG=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=./runtime

## 开始并行 build 并安装到指定路径
ninja -j10 ninstall
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-04-30-%E4%BD%BF%E7%94%A8-ninja-%E5%8A%A0%E9%80%9F-c-build/  

