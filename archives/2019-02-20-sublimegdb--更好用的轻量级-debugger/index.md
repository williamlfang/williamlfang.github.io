# SublimeGDB: 更好用的轻量级 Debugger


`SublimeGDB` 是一款可以在 `Sublime` 编辑器内运行的代码调试器，即调用系统的 `GNU Debugger` 套件。通过一定的设置，我们便可以把 `Sublime` 改造成一款轻量级的 `IDE`，从而可以直接在编辑器对源文件^[source code]进行调试，并且提供了了多个代码调试状态，比直接在终端进行调试要强大的多，也十分方便。

&lt;!--more--&gt;

# 安装

直接使用 `shif&#43;ctrl&#43;p` 调用 `install packages` 来查找 `SublimeGDB`。安装完成后，我们还需要根据个人的使用习惯，进行定制改造。

# 配置

## 布局

`Preferences -&gt; Package Settings -&gt; SublimeGDB -&gt; Settings-User`

```bash
{
    &#34;workingdir&#34;:&#34;${folder:${file}}&#34;,
    &#34;commandline&#34;:&#34;gcc -ggdb3 -std=c11 ${file} -o ${file_base_name} &amp;&amp; gdb --interpreter=mi --args ./${file_base_name}&#34;,
    // 可以直接调试 cmake 下的 bin/run 可执行文件
    //&#34;commandline&#34;:&#34;gdb --interpreter=mi --args ../bin/run&#34;,
    &#34;env&#34;: {&#34;DISPLAY&#34;: &#34;:100&#34;},
    &#34;close_views&#34;: true,

    // Define debugging window layout (window split)
    // first define column/row separators, then refer to them to define cells
    &#34;layout&#34;:
    {
        &#34;cols&#34;: [0.0, 0.5, 1.0],
        &#34;rows&#34;: [0.0, 0.65, 1.0],
        &#34;cells&#34;:
        [ // c1 r1 c2 r2
            [0, 0, 1, 1], // -&gt; (0.0, 0.0), (0.5, 0.65)
            [1, 0, 2, 1], // -&gt; (0.5, 0.0), (0.65, 1.0)
            [0, 1, 1, 2], // -&gt; (0.0, 0.65), (1.0, 0.5)
            [1, 1, 2, 2]  // -&gt; (0.5, 0.65), (1.0, 1.0)
        ]
        // 布局结构
        //
        //         | c0:0          | c1:0.5        | c2:1.0
        // r0:0.0  | ------------- | ------------- |
        // ------- | c0:r0          c1:r0
        // ------- |     =0#             =1#
        // ------- |          c1:r1            c2:r1
        // r1:0.65 | ------------- | ------------- |
        // ------  | c0:r1          c1:r1
        // ------  |     =2#             =3#
        // ------- |          c1:r2            c2:r2
        // r2:1.0  | ------------- | ------------- |
    },

    // The group used for opening files
    &#34;file_group&#34;: 0,

    &#34;console_group&#34;: 1,
    &#34;console_open&#34;: true,

    &#34;session_group&#34;: 2,
    &#34;session_open&#34;: true,

    &#34;variables_group&#34;: 2,
    &#34;variables_open&#34;: true,

    &#34;callstack_group&#34;: 3,
    &#34;callstack_open&#34;: true,

    &#34;registers_group&#34;: 3,
    &#34;registers_open&#34;: false,

    &#34;disassembly_group&#34;: 3,
    &#34;disassembly_open&#34;: true,
    // Set to &#34;intel&#34; for intel disassembly flavor. All other
    // values default to using &#34;att&#34; flavor.
    &#34;disassembly_flavor&#34;: &#34;intel&#34;,

    &#34;threads_group&#34;: 3,
    &#34;threads_open&#34;: true,

    &#34;breakpoints_group&#34;: 3,
    &#34;breakpoints_open&#34;: true,

}
```

说明：

-   `&#34;workingdir&#34;:&#34;${folder:${file}}&#34;`：设置为在当前源文件进行调试
-   `&#34;commandline&#34;:&#34;gcc -ggdb3 -std=c11 ${file} -o ${file_base_name} &amp;&amp; gdb --interpreter=mi --args ./${file_base_name}&#34;`：需要使用的调试器参数，比例我这里使用 `gcc` 进行编译，并以 `-std=c11` 的标准。需要注意的是，由于我们编译完源文件后进行调试，因此需要添加参数 `-g` 表示生成可调式执行文件。
-   `&#34;env&#34;: {&#34;DISPLAY&#34;: &#34;:100&#34;}`：全屏显示
-   `&#34;close_views&#34;: true`：当退出调试模式后，把相关的窗口都关闭掉。
-   `&#34;layout&#34;`：用来控制页面格式，可以根据使用习惯进行定制。使用 `cells` 来标记窗口号，然后将不同的窗口放置在标记的布局里。

## 快捷键

`Preferences -&gt; Package Settings -&gt; SublimeGDB -&gt; Key Bindings-User`

```bash
// SublimeGDB ==============================================================
{
    &#34;keys&#34;: [&#34;ctrl&#43;p&#34;],
    &#34;command&#34;: &#34;gdb_toggle_breakpoint&#34;
},
{
    &#34;keys&#34;: [&#34;ctrl&#43;g&#34;],
    &#34;command&#34;: &#34;gdb_launch&#34;,
    &#34;context&#34;: [{&#34;key&#34;: &#34;gdb_running&#34;, &#34;operator&#34;: &#34;equal&#34;, &#34;operand&#34;: false}]
},
{
    &#34;keys&#34;: [&#34;ctrl&#43;g&#34;],
    &#34;command&#34;: &#34;gdb_exit&#34;,
    &#34;context&#34;: [{&#34;key&#34;: &#34;gdb_running&#34;, &#34;operator&#34;: &#34;equal&#34;, &#34;operand&#34;: true}]
},
{
    &#34;keys&#34;: [&#34;ctrl&#43;enter&#34;],
    &#34;command&#34;: &#34;gdb_continue&#34;,
    &#34;context&#34;: [{&#34;key&#34;: &#34;gdb_running&#34;, &#34;operator&#34;: &#34;equal&#34;, &#34;operand&#34;: true}]
},
{
    &#34;command&#34;: &#34;gdb_step_over&#34;,
    &#34;context&#34;:
    [
        {&#34;key&#34;: &#34;gdb_running&#34;, &#34;operator&#34;: &#34;equal&#34;, &#34;operand&#34;: true},
        {&#34;key&#34;: &#34;gdb_disassembly_view&#34;, &#34;operand&#34;: false}
    ],
    &#34;keys&#34;: [&#34;ctrl&#43;n&#34;]
},
{
    &#34;command&#34;: &#34;gdb_next_instruction&#34;,
    &#34;context&#34;:
    [
        {&#34;key&#34;: &#34;gdb_running&#34;, &#34;operator&#34;: &#34;equal&#34;, &#34;operand&#34;: true},
        {&#34;key&#34;: &#34;gdb_disassembly_view&#34;, &#34;operand&#34;: true}
    ],
    &#34;keys&#34;: [&#34;ctrl&#43;n&#34;]
},
// SublimeGDB ==============================================================
```

快捷键使用指南：

-   `ctrl&#43;n`：触发断点
-   `ctrl&#43;g`：载入 `GDB` 调试模式，其中 `context` 表示在何种情况下运行这个命令。

# 使用

![](/images/2019-02-20-SublimeGDB--更好用的轻量级-Debugger/hello.png)



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-02-20-sublimegdb--%E6%9B%B4%E5%A5%BD%E7%94%A8%E7%9A%84%E8%BD%BB%E9%87%8F%E7%BA%A7-debugger/  

