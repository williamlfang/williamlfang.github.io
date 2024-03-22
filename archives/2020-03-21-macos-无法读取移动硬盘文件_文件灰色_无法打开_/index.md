# MacOS 无法读取移动硬盘文件(文件灰色,无法打开)


![](/images/2020-03-21-MacOS-无法读取移动硬盘文件(文件灰色,无法打开)/无法打开文件.png)

解决方法如下：

-   安装 `Mounty`，然后进行挂载操作

-   找到硬盘文件所在的路径，使用命令进行提升权限

    ```bash
    sudo xattr -d -r com.apple.FinderInfo /Volumes/William/youtube/*

    ## 可以设置成段命令
    alias mount.disk=&#34;sudo xattr -d -r com.apple.FinderInfo /Volumes/William/youtube/*&#34;
    ```

之后再查看，即可打开文件了

![](/images/2020-03-21-MacOS-无法读取移动硬盘文件(文件灰色,无法打开)/可以打开文件.png)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-03-21-macos-%E6%97%A0%E6%B3%95%E8%AF%BB%E5%8F%96%E7%A7%BB%E5%8A%A8%E7%A1%AC%E7%9B%98%E6%96%87%E4%BB%B6_%E6%96%87%E4%BB%B6%E7%81%B0%E8%89%B2_%E6%97%A0%E6%B3%95%E6%89%93%E5%BC%80_/  

