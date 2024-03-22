# Clion 远程调试


使用 Clion 在远程服务器进行项目开发
&lt;!--more--&gt;


# 项目配置

## 同步本地代码

1. 打开 `File` -&gt; `Setting` -&gt; `Build,Execution,Deployment` -&gt; `Deployment`

2. 在右边点击 `&#43;` 进行添加远程服务

   ![setting](./setting.gif &#34;setting&#34;)

3. 根据 `Connections` 添加远程服务器账户信息

4. 切换到 `Mappings`

   - 设置本地的代码根目录Local path

   - 设置远程的代码根目录 Deployment path

5. 同步本地代码到远程服务器。由于我们的代码是放在本地机器，而需要在远程服务器进行编译、调试，因此需要把本地代码上传到服务器。点击 `Tools` -&gt; `Deployment` 进行配置。当然，最好设置成自动同步，这样一旦本地代码发生变动，就会自动同步到服务器。

   &gt; 由于自动同步只能根据单文件，因此我们需要事先把这个文件夹上传到服务器，然后才能实现自动同步功能。

   ![auto-update](./auto-update.gif &#34;auto-update&#34;)

## 远程调试

1. 现在已经把本地代码同步到服务器了，我们就可以在服务器进行编译。记得 `cmake` 指定需要 `-DCMAKE_BUILD_TYPE=Debug`来请获取调试

    ```bash
    ## 服务器端
    cd cmake-build-debug
    cmake .. -DCMAKE_BUILD_TYPE=Debug
    make
    ```

    ![build](./build.gif &#34;build&#34;)

2. 启动 `gdbserver`

    ```bash
    ## 服务器端
    ## 指定监听端口 1234
    gdbserver :1234 hello
    ```

    ![gdb](./gdbserver.gif &#34;gdb&#34;)

3. 在 `Clion` 进行调试

    - 添加 `gdbserver` 调试器
    - 启动对服务器指定端口的调试

    ![debug](./debug.gif &#34;debug&#34;)

# 参考链接

1. [使用Clion优雅的完全远程自动同步和远程调试c&#43;&#43;](https://cloud.tencent.com/developer/article/1406250)
2. [CLion 实现远程调试](https://blog.csdn.net/lihao21/article/details/87425187)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-12-04-clion-%E8%BF%9C%E7%A8%8B%E8%B0%83%E8%AF%95/  

