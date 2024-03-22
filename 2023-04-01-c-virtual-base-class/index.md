# C&#43;&#43; virtual base class


在 `C&#43;&#43;` 中，由于存在多重继承的结构，往往会导致第三层继承类会拷贝顶级父类的多个成员变量，这将导致调用成员函数时，编译器不知道需要调用哪个成员，进而引发编译错误。

&lt;!--more--&gt;

# 多重继承
![](/post/2023-04-01-C&#43;&#43;-virtual-base-class/multi-class.png)

## 存在多个成员变量

```c&#43;&#43;
#include &lt;cmath&gt;
#include &lt;iostream&gt;

class A
{
public:
    A() {}

    void echo()
    {
        std::cout &lt;&lt; &#34;a:&#34; &lt;&lt; a &lt;&lt; std::endl;
    }

protected:
    int a {10};
};

class B: public A
{};

class C: public A
{};

class D: public B, public C
{};

int main()
{
    D d;
    d.echo();

    return 0;
}
```

![](/post/2023-04-01-C&#43;&#43;-virtual-base-class/error1.png)

## virtual base class

我们需要把 `class B` 和 `class C` 对于 `class A` 的继承申明为 `virtual base class`，使用对于基类 `class A` 的**成员拷贝**只有一份

```c&#43;&#43;
class A
{
public:
    A() {}

    void echo()
    {
        std::cout &lt;&lt; &#34;a:&#34; &lt;&lt; a &lt;&lt; std::endl;
    }

protected:
    int a {10};
};

class B: public virtual A
{};

class C: public virtual A
{};

class D: public B, public C
{};
```

![](/post/2023-04-01-C&#43;&#43;-virtual-base-class/ok1.png)

# Ref
1. https://www.simplilearn.com/tutorials/cpp-tutorial/virtual-base-class-in-cpp



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-01-c-virtual-base-class/  

