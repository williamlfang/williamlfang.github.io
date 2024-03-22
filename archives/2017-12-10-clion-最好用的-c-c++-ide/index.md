# CLion：最好用的 C-C&#43;&#43; IDE




`C/Cpp` 编程常常使程序员感到懊恼，一方面是编程语言本身的难度较高，另一方面，我认为也是因为没有比较好用的 `IDE`。不像 `R` 或者 `Python` 这些解释性编程语言，不需要经过编译即可运行 `REPL`(read-evaluate-print-loop)，提供实时互动的编程环境；`C/Cpp` 是一种静态的、需要经过编译的编程语言，这增加了我们查找代码错误的难度，也就是无法提供实时的纠错功能，而只能是在整个项目运行结束后才把相关的错误提示给到程序员。因此，对一款「好用IDE」的向往应该是一家有抱负的科技企业的奋斗动力。

神奇的 `JetBrain` 就是这么一家牛逼的公司，最早开发了 `CLion` 造福广大的 `C/Cpp` 程序员，后来又陆陆续续的开发了 `PyCharm` 等多款好用又好看的 `IDE`，可以说功德千秋、造福万代啊。今天我们来看看怎么在操作系统安装和使用这么好用的 `C/Cpp` IDE。

&lt;!--more--&gt;

# 安装

所谓「工欲善其事必先利其器」，我们得先把软件安装起来了才能敲代码嘛。

## 下载

`CLion` 是一款跨平台的软件，提供了 `Linux`、`Mac` 和 `Windows` 三种操作系统下的安装。当然，我平时基本不用 `Windows`，主要的开发环境都是在 `Linux/Ubuntu/CentOS`，或者偶尔会使用 `Mac` 来开发。基本的安装流程跟其他软件都差不多。

### `Linux`

#### 下载

在 `Linux` 操作系统下，下载源代码包 `*.tar.gz`，并将其解压到安装目录。


```bash
cd /home/william
wget https://download.jetbrains.8686c.com/cpp/CLion-2017.3.tar.gz

tar -zcvf CLion-2017.3.tar.gz
cd CLion-2017.3
```

#### 设置环境变量

然后再配置环境变量，把软件包添加到系统


```bash
vim ~/.bashrc

## 添加到系统路径
export PATH=/home/william/clion-2017.3/bin:${PATH}
```


#### 命令行启动

经过把 `CLion` 添加到系统环境后，我们可以直接启动


```bash
clion.sh
```

当然，也可以通过添加桌面图标的方式来启动 `CLion`。

#### 图标启动

新建立一个文件 `CLion.desktop`, 保存到 `~/.local/share/applications`，里面的内容为


```bash
[Desktop Entry]
Name=CLion
Exec=/home/william/clion-2017.3/bin/clion.sh
Icon=/home/william/clion-2017.3/bin/clion.png
Terminal=false
Type=Application
```

### `Mac` 安装

在 `Mac` 操作系统下安装其实就是一建「傻瓜式」，直接下载 `*.dmg` 然后点击安装即可，默认已经帮我们把环境路径设置好了。


## 首次使用

第一次打开 `CLion` 后，会出现一个界面询问是否需要导入偏好，。

![不需要导入偏好设置](./fig02.png &#34;不需要导入偏好设置&#34;)

接下来是激活软件，这个我们在后面的激活部分再解释，这里默认已经经过激活了。

![正在激活](./fig03.png &#34;正在激活&#34;)

可以选择一款钟意的主题，我一般是使用暗色的编程主题，这里提供了 `Darcula`。

![不需要导入偏好设置](./fig04.png &#34;不需要导入偏好设置&#34;)

设置 `C/Cpp` 的默认编译器，这里一般也不需要多做设置，等需要改变的时候再进行配置即可。

![设置编译器](./fig05.png &#34;设置编译器&#34;)

提供了可拓展的插件，可根据需要来选择安装

![选择安装插件](./fig06.png &#34;选择安装插件&#34;)

经过以上几个简单的配置步骤，我们便可以正式使用 `CLion` 了。这里提供了两种启动项目的方式

- 从已存在的项目导入
- 新建一个项目

![启动项目](./fig07.png &#34;启动项目&#34;)

如果选择新建项目，我们需要做一个简单的配置

![新项目配置](./fig08.png &#34;新项目配置&#34;)

最好，我们终于可以愉快的写代码了。



![开始欢快的敲代码](./fig09.png &#34;开始欢快的敲代码&#34;)


# 破解

我们知道，`CLion` 并非是一个免费的软件，而是收费的，且价格不菲。之前有公司同事购买过一个注册码，大约是 `$80`，相比于其提供的便利性而言，还是很值得的。

不过也有大神通过搭建服务器的方式来提供许可证共享，具体的链接可以参考 [JetBrains IDEA 系列产品通用xx方法](http://xclient.info/a/f0b9738a-36fd-8a97-a966-0d3db497092d.html?_=f93a5bdea18006637eea16701ce2163f)。

具体的操作如下：

- 打开激活窗口
- 选择 Activate new license with License server （用license server 激活）
- 在 License sever address 处填入 `http://xidea.online`
- 点击 Activate 进行认证
- done！


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2017-12-10-clion-%E6%9C%80%E5%A5%BD%E7%94%A8%E7%9A%84-c-c&#43;&#43;-ide/  

