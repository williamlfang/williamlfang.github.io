# c&#43;&#43; static/lexical scope


`C&#43;&#43;` 是一个静态、强类型的编译型编程语言，变量的生命周期需要在编译器确定。这与动态语言是完全不同的。

&lt;!--more--&gt;

Scoping is generally divided into two classes:
1. Static Scoping (也称作 `lexical scope`)
2. Dynamic Scoping

&gt; Static scoping is also called lexical scoping. In this scoping, a variable always refers to its top-level environment. This is a property of the program text and is unrelated to the run-time call stack. Static scoping also makes it much easier to make a modular code as a programmer can figure out the scope just by looking at the code. In contrast, dynamic scope requires the programmer to anticipate all possible dynamic contexts.
&gt; In most programming languages including C, C&#43;&#43;, and Java, variables are always statically (or lexically) scoped i.e., binding of a variable can be determined by program text and is independent of the run-time function call stack.

```C&#43;&#43;
#include &lt;iostream&gt;
using namespace std;

int i {999};

void f()
{
    {
        int i {10};     // in function scope
        cout &lt;&lt; &#34;inside f inner scrope:&#34; &lt;&lt; i &lt;&lt; endl;
    }
    // i not in function scope, will search for it in the GLOBAL SCOPE
    // do not care who is calling it (other function stack)
    cout &lt;&lt; &#34;inside f scrope:&#34; &lt;&lt; i &lt;&lt; endl;
}

int main(int argc, char *argv[])
{
    int i {20};     // int main function scope
    cout &lt;&lt; &#34;inside main scrope:&#34; &lt;&lt; i &lt;&lt; endl;

    f();
    return 0;
}
```

编译后，运行得的的结果是

```bash
g&#43;&#43; /tmp/main.cpp -o /tmp/a.out &amp;&amp; /tmp/a.out

inside main scrope:	    20
inside f inner scrope:	10
inside f scrope:		999
```


---

> 作者: william  
> URL: https://williamlfang.github.io/lexical-scope/  

