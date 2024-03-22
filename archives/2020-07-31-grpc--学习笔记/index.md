# gRPC: 学习笔记


参考链接：

- [gRPC 官方文档中文版](https://doc.oschina.net/grpc)
- https://leimao.github.io/blog/gRPC-Tutorial/

# gRPC 编译

参考官网 [quick-start](https://grpc.io/docs/languages/cpp/quickstart/)

- 需要指定版本号
- `configure` 需要进行打包配置(package)，这个需要参考

```bash
## 安装依赖包
sudo apt-get install golang
sudo apt install autoconf automake libtool shtool

## 可以使用 curl -L http://grpc.io/release 查看当前支持的版本
git clone --recurse-submodules -b v1.20.0 https://github.com/grpc/grpc
cd grpc

mkdir -p ./cmake/build
cd ./cmake/build
cmake -DgRPC_INSTALL=ON \
	  -DgRPC_BUILD_TESTS=OFF \
	  -DgRPC_PROTOBUF_PROVIDER=package \
	  -DgRPC_ZLIB_PROVIDER=package \
	  -DgRPC_CARES_PROVIDER=package \
	  -DgRPC_SSL_PROVIDER=package \
	  -DCMAKE_BUILD_TYPE=Release \
	  ../..

make -j
sudo make install
```



# 使用





---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-07-31-grpc--%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0/  

