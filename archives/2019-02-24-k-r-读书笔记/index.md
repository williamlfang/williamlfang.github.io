# K&amp;R 读书笔记


“The C Programming Language” 是计算机编程的经典之作，别名 `K&amp;R`。

这是一本简短精悍的书籍，介绍了 `C` 语言的编程核心、ANSI 规范、编译原理等诸多方面的内容。现在很难想象这本不足 200 页的小书^[可以参考这个链接看看现在有哪些优秀的 C 编程数据：[The Definitive C Book Guide and List - Stack Overflow](https://stackoverflow.com/questions/562303/the-definitive-c-book-guide-and-list)]尽然能够放得下这么多的内容，可以说是提纲挈领、言简意垓。尤其是附录A部分，只是简要介绍了 `C` 的编译原理，区区几页纸张就足以为后人编写各式不同的编译器提供指引^[关于 `C` 的历史，这里有一篇 Dennis Ritchie 写的文章可供参考：[The Development of the C Language](https://www.bell-labs.com/usr/dmr/www/chist.html)]。

&lt;!--more--&gt;

# 概览

![K&amp;R: 经典之作](./c.jpg &#34;K&amp;R: 经典之作&#34;)

根据我対本书的理解，把整本书籍分成四部分

-   第一部分：简单介绍 `C`，重点在于说明为何要把 `C` 设计成如此简要。一方面，是受到当时程序运行的硬件条件限制，最早 K.Tompson 和 D.Ritchie 是在 PDP-7、PDP-11 上面实现了 Unix 操作系统，然后才决定设计一款与这个 Unix 操作系统配套的编程语言，这必然要求新语言一定要足够精简以适应操作系统対性能的极致考验；另一方面，「小而美」是当时学术领域的一个普遍认可的观念，即根据「奥卡姆」定律：如无必要，请勿增添。因此，我们现在看到，`C` 语言最核心的内容其实很少，关键词不到 30 个，基本上达到了高级编程语言能够触摸的「底层地板」，但通过一定的设计之后，由这些命令组成的程序却又有着强大的能够，既能够实现対底层硬件（指针是 `C` 语言的核心，即变量在内存的地址）的直接操控，又能提供简洁明确的逻辑范式。
    -   Chapter 0: Introduction

        -   &gt;   C is a general-purpose programming language。

            `C` 是一个通用的编程语言，既能够用于编写操作系统这类高难度的「程序」，也提供了一套开发高级程序的工具。

        -   &gt;   [page.3]
            &gt;
            &gt;   we believe strongly that the way to learn a new language is to write programs in it.

            其实编程就像一门传统的手艺活，需要不停的练习才能达到掌握，即 “learning by doing”。多敲键盘，多写代码，这是唯一无二的学习方法。
    -   Chapter 1: A Tutorial Introduction
-   第二部分：介绍 `C` 编程语言的核心。
    -   Chapter 2: Type, Operators, and Expression
    -   Chapter 3: Control Flow
    -   Chapter 4: Functions and Program Structure
    -   Chapter 5: Pointers and Arrays
    -   Chapter 6 Structures
-   第三部分：介绍标准库
    -   Chapter 7: Input and Output
    -   Chapter 8: The Unix System Interface
-   第四部分：附录：编译器
    -   Appendix A: Reference Manual
    -   Appendix B: Standard Library

# PART I：入门准备

## Chap. 1: Hello, world!

### 经典例子

经典的 `Hello, world` 就是从这里诞生的。

```c
// hello.c
// 经典 Hello, World
#include &lt;stdio.h&gt;

int main()
{
    printf(&#34;Hello, world.&#34;);
    return 0;
}
```
![Hello, world.](./chap1/hello-c.png &#34;Hello, world&#34;)

这个例子虽然看起来十分的简单，却涉及到相当多的关于该程序的知识点，因而也往往成了一门编程语言入门的「见面礼」，正如书上说的：

&gt;   [page.5]
&gt;
&gt;   This is the big hurdle; to leap over it, you have to be able to
&gt;
&gt;   -   create the program text somewhere
&gt;   -   compile it successfully
&gt;   -   load it
&gt;   -   run it
&gt;   -   and find out where you output went

![Hello, world.](./chap.1/hello.png &#34;Hello, world&#34;)

### 温度转换

```c
// f-c.c
// 摄氏温度、华氏温度之间的转换
#include &lt;stdio.h&gt;

#define BEGIN 0
#define END 300
#define STEP 20

int main()
{
    for (int i = BEGIN; i &lt;= END; i &#43;= STEP)
        printf(&#34;%3d\t%5.1f\n&#34;, i, (i-32)*5.0/9);
    return 0;
}
```
![f-c 温度转换](./chap.1/f-c.png &#34;f-c 温度转换&#34;)

### 格式化输入、输出

这里补充一下关于 `printf` 与 `scanf` 格式化的知识点：

-   我们知道，`C` 被设计的非常的简洁，核心代码量极小，甚至都不提供输入、输出这样常用的函数，因为有时候程序确实不需要这些函数也能运行，从而可以省下不必要的函数载入消耗。
-   `ANSI C` 提供了输入输出的标准库，在 `stdio.h` 中定义了函数原形，我们可以把这个标准库载入后，调用输入输出函数。
-   关于 `printf` 的说明
    -   要求参数是一个 **字符串**，而不能是单个的**字符**。前者使用双引号 `“”`，后者使用单引号 `‘’`，而且前者的后面是 `\0` 做为字符串结束标识。
    -   可以定义输出格式
        -   `%d`：简单的私进制整型
        -   `%6d`：宽度为 6 位
        -   `%06d`：宽度为 6 位，且不足 6 位时以 `0` 代替
        -   `%06.1f`：浮点数，最大宽度为 6，小数点保留 1 位，且补足 6 位时以 `0` 代替
        -   `%c`：单个字符串
        -   `%p`：指针
        -   `%o`：八进制
        -   `%x`：十六进制
-   关于 `scanf` 的说明
    -   接受输入，可以接受连续输入，中间以空格键区分，使用 `ctrl&#43;d` 标示结束输入
    -   把**输入值的指针**赋值给指定的变量，因此需要放入变量的指针，而不是变量本身，这一点往往容易出错

```c
// printf-scanf.c
// 格式化输入、输出
#include &lt;stdio.h&gt;

int main() {
    int a = 14;
    float b = 23.55656;

    printf(&#34;%d\n&#34;, a);
    printf(&#34;%12d\n&#34;,a);
    printf(&#34;%5.2f\n&#34;, b);
    printf(&#34;%o\n&#34;, a);
    printf(&#34;%x\n&#34;, a);
    printf(&#34;%p\n&#34;, &amp;a);

    printf(&#34;Enter two number\n&#34;);
    scanf(&#34;%d%f&#34;, &amp;a, &amp;b);
    printf(&#34;%d\n&#34;, a);
    printf(&#34;%f\n&#34;, b);
    return 0;
}
```
![printf-scanf 格式化输入、输出](./chap1/printf-scanf.png &#34;printf-scanf 格式化输入、输出&#34;)

### 关于 `for` 与 `while`

书中其实是分别用了 `for` 和 `while` 两种逻辑结构来対温度进制进行转换。这两类逻辑都是属于**循环结构**，一般来说，

-   对于有确定循环次数的逻辑，我们使用 `for`
-   而对于未知循环次数的逻辑，则使用 `while`

&gt;   [page.14]
&gt;
&gt;   The choice between while and for is arbitrary, based on which seems clearer. The for is usually appropriate for loops in which **the initialization and increment are single statements and logically related**, since it is more compact than while and it **keeps the loop control statements together in one place**.

### 关于预处理

`macro` 也称作**预处理指令**，是预处理器在编译前，执行的特殊命令，可以是插入头文件、定义全局常量、执行逻辑分支等。需要注意的是，预处理指令实际上不是一个 `C` 语句，因此**不能在预处理命令后面添加分号 `;`**。

-   `#include &lt;stdio.h&gt;`：就是把头文件插入到源文件，从而保证编译器能够找到声明
-   `#ifndef`、`#endif`：预处理器执行分支逻辑
-   `#define`：可以理解成定义了一个全局变量，实际上不是这样的，而是把源文件中出现的所有字符都替换为我们预定义的**变量字面值**，从而达到固定程序有关变量数值的目的，因此是**不可改变的**

### `getchar`

```c
// 获取单个字符，然后计算一共输入多少字符
#include &lt;stdio.h&gt;

int main() {
    int len = 0;

    while (getchar() != EOF)
        len &#43;= 1;
    printf(&#34;\nTotal char: %d\n&#34;, len);

    return 0;
}
```

![gechar 获取单个字符](./chap1/getchar.png &#34;gechar 获取单个字符&#34;)

### 函数封装

&gt;   [page.24]
&gt;
&gt;   With properly designed functions, it is possible to ignore *how* a job is done; knowing what is done is sufficient.

```c
// 计算 power 函数
#include &lt;stdio.h&gt;
#include &lt;string.h&gt;

int power(int base, int n);
void myprintf(char msg[]);

int main() {
    int a = 2, b = 5;
    int pow;

    // 可以保存结果
    pow = power(a, b);
    printf(&#34;%d^%d \t= %d\n&#34;, a, b, pow);
    // 可以直接调用
    printf(&#34;%d^%d \t= %d\n&#34;, 2, 10, power(2,10));

    char msg[100];
    strcpy(msg, &#34;hello, world&#34;);
    myprintf(msg);
    strcpy(msg, &#34;This is function.&#34;);
    myprintf(msg);

    return 0;
}

int power(int base, int n) {
    int res = 1;
    for (int i = 0; i &lt; n; &#43;&#43;i)
        res *= base;
    return res;
}

void myprintf(char msg[]) {
    printf(&#34;\n// -----------------------\n&#34;);
    printf(msg);
    printf(&#34;\n// -----------------------\n&#34;);
}
```

![函数封装](./chap1/function.png &#34;函数封装&#34;)



### 作用域(scope)

`C` 使用一対大括号`{}`来聚合多个命令语句块，并形成一个变量的作用域(scope)。这类变量我们称之为 `automatic`。作用域遵从「可高不可低」的原则，即

-   一个作用域内部的变量只在本作用域内有效（包含子域）
-   更高层次的作用域无法调用子域变量

&gt;   [page.31]
&gt;
&gt;   Because automatic variables come and go with function invocation, **they do not retain their values from one call to the next**, and must be explicitly get upon each entry. If they are not set, they will contain garbage.

比如

```c
// 作用域
#include &lt;stdio.h&gt;

// 全局变量
int g = 10;

int main() {
    printf(&#34;g = %d\n&#34;, g);
    --g;

    int a = 5;
    printf(&#34;a = %d\n&#34;, a);
    --a;

    printf(&#34;## 进入低级作用域 -------------------------\n&#34;);
    {
        // 可以调用更高的作用域
        printf(&#34;a = %d\n&#34;, a);
        // 全局变量始终有效
        printf(&#34;g = %d\n&#34;, g);
        --g;

        int a = 100;
        printf(&#34;a = %d\n&#34;, a);
        --a;
        // 只在这个层次的 {} 之内修改才有效
        printf(&#34;a = %d\n&#34;, a);
    }
    printf(&#34;## 返回高级作用域 -------------------------\n&#34;);
    // 不可以调用 {} 内更低的作用域
    printf(&#34;a = %d\n&#34;, a);
    // 全局变量始终有效
    printf(&#34;g = %d\n&#34;, g);

    return 0;
}
```
![Build As Project](./chap1/scope.png &#34;Build As Project&#34;)

从函数调用的角度看这个问题，每次调用一个函数，`C` 是默认使用 `pass-by-value` 把常量复制后再传入到函数主体，因此，在函数里面対参数的修改，实际上不会影响原来传递的参数值。如果想要对其进行修改，则需要 `pass-by-reference` 或则 `pass-by-pointer`。^[从内存地址的角度看，二者是同一个东西，都是变量的一种「映射」，只不过 `reference` 是别名，而 `pointer` 是内存实实在在的地址。]


### `C`编程工程项目

对于一个小型的工程项目，比如上面这个函数封装的例子，我们只需要把所有的函数原型和函数定义写在 `main` 同在的源文件，然后直接编译就可以运行了。但是对于一个大型的 `C` 程序开发项目，往往会涉及到非常多的文件关联，主函数起到的只是一个做为程序入口用于调用其他的功能模块，而这些功能模块，又都是根据各自的特征分布的各个源文件中。这在编译的时候，就需要告诉编译器各个模块之间的关联关系。这就是**头文件**的作用。

-   把所有的函数原型放在一个头文件 `myfunctions.h` 里面，指明函数的基本结构，但没有函数体

    -   由于头文件可能会在多个功能模块中被重复载入，因此需要使用预处理命令

        ```c
        #ifndef __MYFUNCTIONS__H__
        #define __MYFUNCTIONS__H__
        // ------------------------------
        函数原型声明
        // ------------------------------
        #endif
        ```

-   在 `myfunctions.c` 编写函数主体，主要需要把头文件载入，`#include “myfunctions.h”`

-   在 `main` 函数源文件中，由于需要调用函数主体，因此也需要把头文件载入，向编译器表明函数原型

-   之后便可以直接调用函数

-   编译的时候，可以使用命令，或者在 `Sublime` 里面设置

    ```bash
    &#34;cmd&#34;: [&#34;gcc -std=c11 -Wall ${file_path}/*.c -o ${file_base_name}&#34;]
    ```

    即把所有的文件都进行编译，然后自动进行链接


![Build As Project](./chap1/project.png &#34;Build As Project&#34;)





# PART II：`C` 语言核心概念

## Chap. 2: Types, Operators, and Expression

### 变量名
&gt; There are two hard things in computer science: cache invalidation and naming things.
&gt;
&gt; – Phil Karlton

以上这句经典台词常常被用来形容给变量取一个合适的名称是多么的困难，既要简短以减少输入时间，又要直观以方便阅读。

一般来说，以下几点是在 `c` 编程中需要注意的：

-   `c` 是**対大小写敏感**的编程语言，也就意味着 `x` 与 `X` 代表两个不同的变量。其实还可以进一步引申出来，绝大部分的 `c-family`，也都遵从大小写敏感的原则，如 `R`、`python`。当然，还是有很多的编程语言是不限制大小写的，比如数据库操作语言 `SQL` 。
-   `c` 要求变量名**以英文字母、下划线开头**、并可以在非开头部分**使用阿拉伯数字**。注意，这个往往是初学者容易犯错的地方：*变量名不能以数字开头*。
-   以下划线开头的变量往往有特殊的意义，一般是标准开预先定义的变量名，或则是一类全局变量名。
-   变量名应**以字见意**，**能够从字面意思推断出该变量代表的具体含义**。虽然类似 `a`、`aa`、`b` 这些名称也是合法的，但无法看出来他们各自代表什么意思，因此不利于代码阅读。另外，现在很多的 `IDE` 都有提供变量的模糊匹配功能，比如 `Sublime` 中使用 `ctrl&#43;d` 或则 `alt&#43;f3` 是可以直接找到与该名称匹配的所有变量，而如果使用 `a` 、`aa` 这类名称，则会困难很多。

### 基本数据类型

一般来说，基本数据类型的具体位长，与本地机器有关。

-   `char`： `ANSI` 支持的单个字母，并以整数表示。如 `A` 是对应 `65`。`char` 一共有 `256` 个，一般是以整数的形式表示。需要注意的是，`char` 和我们在标准库使用的 `string` 是不一样的， `char` 使用整数表示，只占用一个字节(byte，一共有 $2^8$)；而 `string` 是字符串，本质上是一个 `char array[]`，并且以 `\0` 标示结尾（虽然打印的时候看不到，这个是系统自动加上的）。因此，`A` 与 `“A”` 是两个不一样的变量，前者是一个字符，只有一个字节，而后者多了一个结尾符号 `\0`，因此占用了两个字符。

    ```c
    // char 与 string 区别
    #include &lt;stdio.h&gt;

    int main() {
        char c = &#39;A&#39;;
        printf(&#34;%d\n&#34;, c);
        printf(&#34;sizeof \&#39;A\&#39;: %ld\n&#34;, sizeof c);

        char s[] = &#34;A&#34;;
        printf(&#34;%s\n&#34;, s);
        printf(&#34;sizeof \&#34;A\&#34;: %ld\n&#34;, sizeof s);

        return 0;
    }
    ```

    ![char 与 string](./chap2/char-string.png &#34;char 与 string&#34;)

-   `short`、`int`、`long`、`long long`：整型。

-   `float`、`double`、`long double`：浮点型。尽量使用 `double` 类型，一方面是因为精度更高；另一方面，传统上认为 `float` 可以节省内存空间，但是现在对于大内存时代，已经不是问题，而且很多的内存机制会自动进行 `double` 的补齐，所以直接使用 `double` 性能是会更佳。

我们可以查看一下系统的基本数据类型长度


```c
// 查看 sizeof()
#include &lt;stdio.h&gt;

int main () {

    printf(&#34;sizeof(char) \t= %ld\n&#34;, sizeof(char));
    printf(&#34;sizeof(short) \t= %ld\n&#34;, sizeof(short));
    printf(&#34;sizeof(int) \t= %ld\n&#34;, sizeof(int));
    printf(&#34;sizeof(long) \t= %ld\n&#34;, sizeof(long));
    printf(&#34;sizeof(float) \t= %ld\n&#34;, sizeof(float));
    printf(&#34;sizeof(double) \t= %ld\n&#34;, sizeof(double));
    printf(&#34;sizeof(long double) \t= %ld\n&#34;, sizeof(long double));

    return 0;
}
```

![sizeof](./chap2/sizeof.png &#34;sizeof&#34;)


### 拓展数据类型

-   `enum`：整型，并以 `1` 递增。如果没有指定初始，则以 `0` 开始计数。
-   `structure`：结构体。
-   `pointer`：指针，即变量在内存的地址。
-   `array`

```c
#include &lt;stdio.h&gt;
#include &lt;string.h&gt;

typedef enum Market
{
    sse = 0,
    szse,
    unknown
} Market;

typedef struct Book
{
    char title[50];
    char author[50];
} Book;

int main () {
    // enum
    Market mkt = szse;
    printf(&#34;market code: %d\n&#34;, mkt);

    // structure
    Book mybook = {&#34;C Programing Learning Note&#34;, &#34;william&#34;};
    printf(&#34;%s: \&#34;%s\&#34;\n&#34;, mybook.author, mybook.title);

    // pointer to structure
    Book *pbook = &amp;mybook;
    strcpy(pbook-&gt;title, &#34;A personal remark&#34;);
    printf(&#34;%s: \&#34;%s\&#34;\n&#34;, pbook-&gt;author, pbook-&gt;title);

    // array
    int l[10] = {1,2,3};
    printf(&#34;l[0]: %d\n&#34;, l[0]);

    char s[] = &#34;This is a really long string&#34;;
    printf(&#34;%s\n&#34;, s);
    return 0;
}
```

![扩展数据类型](./chap2/ext.png &#34;扩展数据类型&#34;)

### 常量

常量，顾名思义，就是不可以更改的变量，本质上还是一个变量，只不过不能对其进行修改值，但可以在命令语句中调用。

-   字面常量（literal constant）：字符常量 `a`、`A`，字符串常量 `“a long string”`。

-   常量表达式（constant expression）：即**在编译的时候就可以确定的表达式**

    ```c
    constant int i = 10;
    // 编译的时候已经确定了 j 的值
    int j = (i&#43;100)*i;
    ```

### 类型转换

类型转换有两种实现方式：

-   显示转换，即明确写明需要转换的目标类型

-   隐式转换，系统根据一定的转换规则把原来的数据转换为目标数据，**注意原来的数据类型是不变的，改变的是取值后的数据**：

    -   一般是采用**低阶到高阶的顺序**，即占用字节少的数据类型补齐成占用字节多的数据类型，以补齐所需的内存空间

        &gt;    `char -&gt; int -&gt; float -&gt; double`
        &gt;
        &gt;   `short -&gt; long`

    -   对于溢出数据所标示数值范围的，则会根据数据类型所占用的范围进行循环，比如

        ```c
        short si = 32768 &#43; 1;
        printf(&#34;si = %d\n&#34;, si);

        // 得到 si = -32767
        ```

```c
#include &lt;stdio.h&gt;

int main () {
    int i = 65;
    double f;

    // 整数截断
    f = i / 2;
    printf(&#34;f = %d/2: %.2f\n&#34;, i, f);

    // explicit converse
    f = (double) i / 2;
    printf(&#34;f = (double) %d / 2 = %.2f\n&#34;, i, f);

    // implicit converse
    int ii = f;
    printf(&#34;ii = %f: %d\n&#34;, f, ii);

    // implicit converse
    char c = i;
    printf(&#34;i = %d --&gt; c = %c\n&#34;, i, c);

    short si = 32768 &#43; 1;
    printf(&#34;si = %d\n&#34;, si);

    return 0;
}
```

![类型转换](./chap2/converse.png &#34;类型转换&#34;)

![page.44](./chap2/p44.png &#34;page.44&#34;)

### 运算

-   函数运算优先级最高

-   变量自增、自减

-   算数运算

-   逻辑运算

-   复合运算符 `op=`，根据上面的运算优先级，`op=` 是先计算等式左边，得到值后再进行复合运算，即

    ```c
    x *= y &#43; z; // x = x*(y&#43;z);
    ```

![page.53](./chap2/p53.png &#34;page.53&#34;)

## Chap. 3: Control Flow

### `if-else`

```c
if (expression)
	statement;
else if (expression)
    statement;
else
    statement;
```

-   `expression` 为逻辑判断，结果如果是非零（`0`），则表示逻辑为真；如果是零（`0`），则代表逻辑为假

-   注意语句后面使用分号 `;` 代表该语句结束

-   `if-else` 遵从 **就近原则**，即会寻找最近的 `else` 进行配对

    ```c
    if (expression)
        if (expression)
            statement;
    else
        statement;
    ```



    虽然看起来，我们使用了缩进试图表示 `else` 是与第一个 `if` 配对，当时要记住，`c` 其实不不像 `python` 是严格使用缩进来表示代码运行逻辑的。因此，此处的运行到第二个 `if` 后，会直接与 `else` 配对，即

    ```c
    if (expression){
        if (expression) {
            statement;
        } else {
            statement;
        }
    }
    ```

    当然，如果需要表达另外一个意思，需要使用 `{}` 来划分代码块

    ```c
    if (expression) {
        if (expression)
            statement;
    } else {
        statement;
    }
    ```

### `switch`

`switch`  使用**整型变量来判断需要执行哪个命令语句**。

```c
switch (expressoin) {
    case constant-expression:
    case constant-expression:
        do-something statement;
        break;
    default:
        break;
}
```

### `for` 与 `while`

其实两者是可以互相转换的

![page.60](./chap2/p60.png &#34;page.60&#34;)

-   `while` 是先执行判断条件，如果没有符合的，则一步都不会执行下面的语句
-   为了至少执行一次，我们可以使用 `do-while`。

```c
#include &lt;stdio.h&gt;

int main() {
    int END;
    int i = 0;
    printf(&#34;## while ------------\n&#34;);
    printf(&#34;Enter a number: &#34;);
    scanf(&#34;%d&#34;, &amp;END);

    // 如果 i &lt; END 不成立，则一次都不执行
    while (i &lt; END) {
        printf(&#34;%d\n&#34;, &#43;&#43;i);
    }

    printf(&#34;\n## do while ---------\n&#34;);
    i = 0;
    printf(&#34;Enter a number: &#34;);
    scanf(&#34;%d&#34;, &amp;END);
    // 无论 i &lt; END 是否成立，都至少执行一次
    do {
        printf(&#34;%d\n&#34;, &#43;&#43;i);
    } while (i &lt; END);

    return 0;
}
```
![do-while](./chap2/do-while.png &#34;do-while&#34;)

### `break`与`continue`

可以控制循环逻辑的执行：

-   `break` 提前退出整个循环
-   `continue` 不执行本次循环，但需要继续执行省下的循环^[`R` 使用 `next`， `python` 使用 `continue`]

## Chap. 4: Functions and Program Structure

&gt;   本章的内容非常的翔实，不仅介绍了函数封装的基本知识，更是重点分析如何构建一个完整的 `c` 项目程序，从使用头文件、声明外部变量、到分离编译、函数调用等高级功能。

## Chap. 5: Pointers and Arrays

## Chap. 6: Structures

# PART III：使用标准库



# PART IV：编译原理


---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2019-02-24-k-r-%E8%AF%BB%E4%B9%A6%E7%AC%94%E8%AE%B0/  

