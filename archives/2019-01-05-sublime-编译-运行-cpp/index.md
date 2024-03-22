# Sublime 编译 运行 c/c&#43;&#43; 文件


在 Sublime Text 3 编辑器里实现对 C/C&#43;&#43; 文件的编译与运行。
&lt;!--more--&gt;

# 干中学

最近在学习一个 `C&#43;&#43;` 项目，需要重新把以前的课本拿起来。学习的最好方法，尤其是编程技能的学习，就是对照着教材，边学边练，即 「Learning by doing」。这是我多年以来领悟到的最好经验。

对于 `c/C&#43;&#43;` 这类**编译语言**，需要在编写完源文件(source file)后，使用编译器进行编译，生成相应的可执行文件(executable file)。因此，一个既能提供高效文本编辑环境、同时又能提供快速编译功能的「软件」，对于实现项目开发是极为关键的。

# `Sublime`编辑神器

基于使用习惯，我一般都是在 `Sublime` 进行文本的编辑，然后通过使用支持相关语言处理的配套插件，进行程序开发。这么多年来，`Sublime` 已经发展成了我得心应手的编辑器与**开发环境**。我之前有介绍过[如何配置](https://williamlfang.github.io/post/2017-10-13-我的-sublime-text-设置)，今天这篇文章则介绍如何配置 `C/C&#43;&#43;` 开发环境。

## 新建配置文件

在 &#34;Tools -&gt; Build System&#34;，点击 “New Build System”，会自动弹出一个文件，我们在这里写入相应的配置方案：

```bash
{
    &#34;cmd&#34;: [&#34;g&#43;&#43; -ggdb3 -std=c&#43;&#43;11 -Wall ${file} -o ${file_base_name}&#34;],
    &#34;file_regex&#34;: &#34;^(..[^:]*):([0-9]&#43;):?([0-9]&#43;)?:? (.*)$&#34;,
    &#34;working_dir&#34;: &#34;${file_path}&#34;,
    &#34;selector&#34;: &#34;source.c, source.c&#43;&#43;&#34;,
    &#34;shell&#34;: true,
    &#34;variants&#34;:
    [
        {
            &#34;name&#34;: &#34;Run&#34;,
            &#34;cmd&#34;: [&#34;${file_path}/${file_base_name}&#34;]
        },
        // ,
        // {
        //     &#34;name&#34;: &#34;RunInShell&#34;,
        //     &#34;cmd&#34;: [&#34;gnome-terminal -x bash -c &#39;${file_path}/${file_base_name};read&#39; &#34;]
        // }
        {
         &#34;name&#34;: &#34;Build_Project&#34;,
         &#34;cmd&#34;: [&#34;g&#43;&#43; -ggdb3 -std=c&#43;&#43;11 -Wall ${file_path}/*.cpp -o ${file_base_name}&#34;]
        }
    ]
}

```

命令后保存到默认的文件夹^[一般在`~/.config/sublime-text-3/Packages/User`]。在这里：

- 在 `cmd` 命令里设置 `gcc/g&#43;&#43;` 需要指定的参数，如 `-ggdb3`、`-std=c&#43;&#43;11`、`-Wall` 等，可以方便的我们需要的配置集合到一个命令里
- 指定运行 `shell`
- 同时，我们还指定其他的可选 `variants`，即这里使用到的 `Run` 模式，可以在源文件编译结束后，执行程序，并把结果直接输出到 `Sublime` 的 `console` 界面。
- 当然，如何需要调试带有**输入(cin)**的程序，我们也可以再添加 `RunInShell` 模式。

同样，我们也可以相应的配置 `c11` 运行环境

```bash
{
    &#34;cmd&#34;: [&#34;gcc -ggdb3 -std=c11 -Wall ${file} -o ${file_base_name}&#34;],
    // 如果是工程项目
    // &#34;cmd&#34;: [&#34;gcc -ggdb3 -std=c11 -Wall ${file_path}/*.c -o ${file_base_name}&#34;],
    &#34;file_regex&#34;: &#34;^(..[^:]*):([0-9]&#43;):?([0-9]&#43;)?:? (.*)$&#34;,
    &#34;working_dir&#34;: &#34;${file_path}&#34;,
    &#34;selector&#34;: &#34;source.c&#34;,
    &#34;shell&#34;: true,
    &#34;variants&#34;:
    [
        {
            &#34;name&#34;: &#34;Run&#34;,
            &#34;cmd&#34;: [&#34;${file_path}/${file_base_name}&#34;]
        },
        // ,
        // {
        //     &#34;name&#34;: &#34;RunInShell&#34;,
        //     &#34;cmd&#34;: [&#34;gnome-terminal -x bash -c &#39;${file_path}/${file_base_name};read&#39; &#34;]
        // }，
        {
         &#34;name&#34;: &#34;Build_Project&#34;,
         &#34;cmd&#34;: [&#34;gcc -ggdb3 -std=c11 -Wall ${file_path}/*.c -o ${file_base_name}&#34;]
        }
    ]
}
```

## 调试

我们可以在编辑一个 `C/C&#43;&#43;` 文件后，直接调用 `Ctrl&#43;B` 来编译文件，使用 `Ctrl&#43;Shift&#43;B` 选择指定的运行方式。

![build system](./Selection_027.png &#34;build system&#34;)

## 设置快捷键

在 `Sublime` 里，我们可以十分方便的根据个人偏好，设置我们常用的一些快捷键。比如，运行一个已经编译好的 `C/C&#43;&#43;` 可执行文件，我们就可以使用 `F1` 实现直接运行该文件。

```bash
{&#34;keys&#34;: [&#34;f1&#34;], &#34;command&#34;: &#34;build&#34;, &#34;args&#34;: {&#34;variant&#34;: &#34;Run&#34;}}
```

其中，参数 `Run` 就是我们在 `Build System` 里面设置的 &#39;variant&#39;。

终结一下，我现在处理 `C/C&#43;&#43;` 项目的基本流程：

- 编辑一个源文件`.cpp`
- 使用 `Ctrl&#43;B` 编译该文件
- 使用 `F1` 运行文件，直接把相应的结果显示出来。



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-01-05-sublime-%E7%BC%96%E8%AF%91-%E8%BF%90%E8%A1%8C-cpp/  

