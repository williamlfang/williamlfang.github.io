# Evans: gRPC 交互式测试工具


# 安装

到[项目主页](https://github.com/ktr0731/evans)，找到[发布地址](https://github.com/ktr0731/evans/releases)，然后下载相应操作系统下的可执行文件。

```bash
cd /tmp
wget https://github.com/ktr0731/evans/releases/download/0.9.0/evans_linux_amd64.tar.gz
tar -xvf evans_linux_amd64.tar.gz

## 复制到系统路径
sudo mv evans /usr/local/bin
```
&lt;!--more--&gt;

# 使用

```bash
evans --host 127.0.0.1 --port 50051 helloworld.proto

  ______
 |  ____|
 | |__    __   __   __ _   _ __    ___
 |  __|   \ \ / /  / _. | | &#39;_ \  / __|
 | |____   \ V /  | (_| | | | | | \__ \
 |______|   \_/    \__,_| |_| |_| |___/

 more expressive universal gRPC client

helloworld.Greeter@127.0.0.1:50051&gt;


helloworld.Greeter@127.0.0.1:50051&gt; show package
&#43;------------&#43;
|  PACKAGE   |
&#43;------------&#43;
| helloworld |
&#43;------------&#43;

helloworld.Greeter@127.0.0.1:50051&gt; package helloworld

helloworld@127.0.0.1:50051&gt; show service
&#43;---------&#43;----------&#43;--------------&#43;---------------&#43;
| SERVICE |   RPC    | REQUEST TYPE | RESPONSE TYPE |
&#43;---------&#43;----------&#43;--------------&#43;---------------&#43;
| Greeter | SayHello | HelloRequest | HelloReply    |
&#43;---------&#43;----------&#43;--------------&#43;---------------&#43;

helloworld@127.0.0.1:50051&gt; show message
&#43;--------------&#43;
|   MESSAGE    |
&#43;--------------&#43;
| HelloReply   |
| HelloRequest |
&#43;--------------&#43;

```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-08-27-evans--grpc-%E4%BA%A4%E4%BA%92%E5%BC%8F%E6%B5%8B%E8%AF%95%E5%B7%A5%E5%85%B7/  

