# 侯捷: C&#43;&#43; 面向对象高级编程


侯捷老师在线教学：C&#43;&#43; 面向对象高级编程的课堂笔记。
&lt;!--more--&gt;

# 介绍

## 课程目标

侯捷老师在整个课程的讲授过程中，一直都非常强调「大气的编程习惯」，即从宏观设计、全局把握，然后再从微观编写、认真调试的编程风格。这一点非常重要，尤其对于大型的软件工程，我们往往需要在大局上进行深度的思考与设计，并且在细节上注重品质，才能编写出稳健而持续运行的程序。

## 现代 C&#43;&#43;

![现代c&#43;&#43;](./现代c&#43;&#43;.png &#34;现代c&#43;&#43;&#34;)

从 `C&#43;&#43;11` 开始，人们开始认识到这个古老的编程语言似乎焕发出新的生命，既注重程序的运行效率（不妥协）、也开始关注程序猿的编程效率，提供了更多的、更加灵活的编程语言内容的特征，如 `auto`、`lambda`、`thread` 多线程等，旨在为程序猿提供更加友好的编程环境。因此，我们常常说，`C&#43;&#43;11` 是现代化的 `C&#43;&#43;` 升级版。

我原来的大学本科学习的是 `c` 编程语言，后面使用的主要也是面向过程的编程语言，如 `R`、`Matlab`。从思维方式来看，这种面向过程的编程语言，思维的逻辑性更强，要求使用者能够实现把解决问题的思路想清楚，然后安装一定的逻辑流程进行编写相应的程序处理过程。相反，对于面向对象的编程语言，如 `C&#43;&#43;`、`Java`，则是**思维的抽象性更强**，需要把具体的问题抽象成可处理的对象，然后再赋予对象一定的可操作的逻辑。

我们无法说到底是面向过程的编程语言、还是面向对象的编程语言，哪种更好。我们只能说，不同的应用场景下，不同的编程语言各有利弊。从这几年 `C&#43;&#43;` 语言的发展轨迹上看，我们更发现其不仅仅是作为一门编程语言工具使用，更是为程序员提供了一种理解计算机的思维方式，那就是从底层硬件映射抽象的对象、以编译器的思考方式来理解程序的运行方式，这样，我们能够更好的理解我们所写的程序是如何在计算机内部工作，是如何一步一步的执行我们设计的算法步骤。因此， `C&#43;&#43;11` 也成为了我目前主要的开发语言。

![c-vs-c&#43;&#43;](./c-vs-c&#43;&#43;.png &#34;c-vs-c&#43;&#43;&#34;)

# 头文件

需要提供「头文件保护」(header guard)

```c&#43;&#43;
#ifndef __CLASS_NAME__H__
#define __CLASS_NAME__H__

...

#endif // __CLASS_NAME__H__
```



# 类设计的 6 大金刚

-   构造函数
-   析构函数
-   拷贝构造
-   拷贝赋值
-   移动构造
-   移动赋值

`c&#43;&#43;` 面向对象的编程风格指两个方面的意思：

-   「object-based」：即以对象作为操作的基本单位:
    -   class with pointer member
    -   Class without pointer member
-   「object-oriented」：即有不同的类构成的层次体系:
    -   `inheritance`：表示 「is-a」
    -   `composition`：表示 「has-a」
    -   `delegation`：

![oop](./oop.png &#34;oop&#34;)

## composition

`composition` 模式下，`container` 与 `component` 的生命周期是一样的。

### 构造与析构顺序

-   构造由内向外
-   析构由外向内

![composition](./composition-1.png &#34;composition&#34;)

## delegation(pImpl)

-   Body-handle
-   pImpl：`pointer-to-implementation`

-   composition by reference

在 `delegation` 模式下，`body` 与 `handle` 的生命周期是不一样的，`handle` 是一个指针，独立于 `body` 之外。

![delegation](./delegation-1.png &#34;delegation&#34;)

## inheritance

![inheritance](./inheritance-1.png &#34;inheritance&#34;)

### 构造与析构顺序

-   构造由内向外
-   析构由外向内

![inheritance](./inheritance-2.png &#34;inheritance&#34;)

# 构造函数

## 初始化列表

`initializer-list` 先于其他构造，能够保证构造函数的实现，这尤其对于类继承，可能保证基类初始化。

```c&#43;&#43;
class Strategy
{
public:
  Strategy(std::string id):
  	strategyid(id)				// 初始化列表
    {

    }
};
```



## 构造函数放在 `private`

一般来说，我们会把各种形式的构造函数(ctor)放在 `public` 声明范围内，表示外部可以调用构造函数。但是，也一种设计模式叫做 `Singleton`，只允许通过函数调用来实现构造函数，这时，要求我们把构造函数放在 `private` 范围内。

![ctor-singleton](./ctor-singleton.png &#34;ctor-singleton&#34;)

# 析构函数

**对于动态内存分配的成员变量，需要在析构函数中进行释放**。

![dtor-string](./dtor-string.png &#34;dtor-string&#34;)

# 成员函数

## const 成员函数

![const-member-function](./const-member-function.png &#34;const-member-function&#34;)

`const` 用在类的成员函数时，表示该成员函数**调用时不会改变类成员变量的值**。从编译器的角度来看，其实是做了一次「承诺」。因此，如果是对于 `const` 类对象的实例，其实是约定了整个类不会改变成员变量，这时去调用没有添加`const`限定的成员函数时，编译器会报错，因为我们在声明类实例的时候，明明说好了不会改变，但是调用非`const`成员函数，则有可能破坏这个约定，因此编译器不会通过。

总结一下，就是：

&gt;   如果成员函数肯定不会修改成员变量的，尽量添加 `const` 限定。

## pass-by-value vs pass-by-reference

两种传递参数的方式：

-   `pass-by-value`：需要把参数压入 `heap`，即复制后传递给函数

-   `pass-by-reference`：直接传入引用，不需要额外的开销。如果需要限定不会修改参数，最好增加 `pass-by-reference-to-const`，即

    ```c&#43;&#43;
    void func(const int &amp;arg); // 传入常量引用
    ```

    可以这样理解，「传入引用相当于传入指针」，因为在底层引用是指针。

![pass-by-value-vs-pass-by-reference](./pass-by-value-vs-pass-by-reference.png &#34;pass-by-value-vs-pass-by-reference&#34;)

## return-by-value vs return-by-reference

![return-by-value-vs-return-by-reference](./return-by-value-vs-return-by-reference.png &#34;return-by-value-vs-return-by-reference&#34;)

需要注意的是，`return-by-reference` 要求变量在函数调用结束后，**不会被销毁**，是在堆栈中仍然存在的变量。

![return-by-value-vs-return-by-reference](./return-by-value-vs-return-by-reference-2.png &#34;return-by-value-vs-return-by-reference&#34;)

## friend 友元函数

对于类声明的**私有变量**，一般规定外部函数时无法获取的，所以我们需要编写`getter`函数。但是，如果把一个函数声明为这个类的`friend`，则允许直接获取类的私有变量。这样做有一定的方便性，但也是有一定的危险，毕竟我们把类私有变量封装起来的目的，就是不想让外部函数直接伸手进来操作。

![friend](./friend.png &#34;friend&#34;)

&gt;   另外，我们需要注意，相同类之间生成的实例、父类与之类之间，互为`friend`。

![friend](./friend2.png &#34;friend&#34;)

## operator overloading

在 `c&#43;&#43;` 里，有两种 `overloading`:

-   `operator overloading`
-   `function overloading`

所谓的 `overloading`，就是对原来语义的重新定义，使之能够作用于新的对象。

![operator-overloading](./operator-overloading-1.png &#34;operator-overloading&#34;)

![operator-overloading](./operator-overloading-2.png &#34;operator-overloading&#34;)



## virtual 函数

在 `c&#43;&#43;` 中，子类继承父类的函数，实际上是**继承了函数的调用权**。

![pure](./puer-1.png &#34;pure&#34;)
                                          k


## converion function

-   不需要指定返回类型，因为 `operator` 已经知道了
-   类型可以是任意的，包括 `build-in` 、`user-defined-type`


![conversion-function](./conversion-function.png &#34;conversion-function&#34;)



## explicit



## pointer-like-class

类对象可以像操作指针一样进行运算符重载。

![pointer-like-class](./pointer-like-class.png &#34;pointer-like-class&#34;)

## function-like-class

## member template

在类模板里面，成员函数也是一个模板函数。

![member-template](./member-template.png &#34;member-template&#34;)

# 内存分配与管理

![stack-heap](./stack-heap.png &#34;stack-heap&#34;)

## Stack

## Heap

## 变量的生命周期

-   全局变量
-   静态变量
-   局部变量

![global-object](./global-object.png &#34;global-object&#34;)

![static-object](./static-object.png &#34;static-object&#34;)

![heap-object](./heap-object.png &#34;heap-object&#34;)

## nekw

&gt;   先分配内存大小，然后调用构造函数

```c&#43;&#43;
void *mem = operator new( sizeof(Complex) );  // 分配内存
Complex *p = static_cast&lt;Complex*&gt;mem;        // 类型转化
p-&gt;Complex();                                 // 调用构造函数
```

在底层实现机制上，`new` 也是调用了 `malloc`。但是与当初的 `malloc` 只分配内存、不调用构造函数不同，`new` 同时还保证了类的构造函数会被调用，以进行初始化操作。

![new](./new.png &#34;new&#34;)

## delete

&gt;   先调用析构函数，然后删除内存大小

![delete](./delete.png &#34;delete&#34;)

## array: new, delete

`new` 和 `delete` 一定要配对出现

-   单个 `new` 对应单个 `delete`

-   `array new` 对应 `array-delete`，否则会出现只是析构了第一个类，而后面的对象没有完全析构，导致内存泄露。

    ````c&#43;&#43;
    auto p = new Complex[3];
    delete[] p;
    ````



![array-new-delete](./array-new-delete.png &#34;array-new-delete&#34;)

# static

静态限定只有在第一次初始化的时候进行内存分配，以后所有的类实例都可以共享这个静态变量。

```c&#43;&#43;
class A
{
public:
  static double m_data;
  static double get_data() { return m_data; }
};

double A::mdata = 10; // 变量定义，所有实例共同使用
```

调用 `static` 函数的方式有两种：

-   通过类调用：`A::get_data()`，需要指定类作用域
-   通过实例调用：`a.get_data()`

![static](./static.png &#34;static&#34;)



# 类模板

推荐写类模板的方法：

-   先按照某个特定版本的类进行设计、编写、调试
-   待以上特定版本的类完成后，使用 `template` 类型进行替代

![class-template](./class-template.png &#34;class-template&#34;)

# namespace

-   using directive

    ```c&#43;&#43;
    using namespace std;
    ```



-   using declaration

    ```c&#43;&#43;
    using std::cout;
    ```



-   using alias：

    ```c&#43;&#43;
    using hiorder =  hicloud::OrderData;
    ```



![namespace](./namespace.png &#34;namespace&#34;)

# 标准库:std



# STL



# C&#43;&#43;11 新特征



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-06-26-%E4%BE%AF%E6%8D%B7--c&#43;&#43;-%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1%E9%AB%98%E7%BA%A7%E7%BC%96%E7%A8%8B/  

