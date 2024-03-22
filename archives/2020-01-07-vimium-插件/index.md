# Vimium 插件


# 技巧

## 从地址栏返回页面（Focus）

有时会不小心点击了 Chrome 的地址栏，这时候就无法在使用 Vimium 的快捷键功能了。为了处理这个问题，网上有人给出了一个[小的技巧](https://superuser.com/questions/324266/google-chrome-mac-set-keyboard-focus-from-address-bar-back-to-page/324267#324267)，另外[有人](https://xavierchow.github.io/2016/03/07/vimium-leave-address-bar/)也介绍了其他的方法：

1. 打开 Chrome -&gt; Setting

2. 点击 Search Enigne, 然后添加一个

    ![](/images/2020-01-07-Vimium-插件/Settings - Manage search engines - Google Chrome_018.png)

3. 搜索引擎名称随便写一个，如 LeaveAddressBar

4. 快捷键设置成 `u`

5. 在 `URL` 填入 `javascript:`，这样就不会去执行，而是返回主页面

6. 然后，我们在地址栏输入 `u`，点击回车会，就会自动返回主页面了

    ![](/images/2020-01-07-Vimium-插件/u.gif)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-01-07-vimium-%E6%8F%92%E4%BB%B6/  

