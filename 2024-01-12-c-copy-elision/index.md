# c&#43;&#43; copy elision


`C&#43;&#43;` 提供了小对象的 `RVO`（返回值优化），实现了在函数返回中调用构造函数的功能。

&lt;!--more--&gt;

```c&#43;&#43;
#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;vector&gt;

class BigObject {
public:
    BigObject() : person_names_(std::vector&lt;std::string&gt;(1000000)) {
        std::cout &lt;&lt; &#34;constructor. &#34; &lt;&lt; person_names_.size() &lt;&lt; std::endl;
    }
    ~BigObject() {
        std::cout &lt;&lt; &#34;destructor. &#34; &lt;&lt; std::endl;
    }
    BigObject(const BigObject&amp; other) {
        person_names_ = other.person_names_;
        std::cout &lt;&lt; &#34;copy constructor. &#34; &lt;&lt; person_names_.size() &lt;&lt; std::endl;
    }

private:
    std::vector&lt;std::string&gt; person_names_;
};

BigObject Foo() {
    BigObject local_obj;
    return local_obj;
    // return std::move(local_obj);
}

int n {0};

struct C
{
    explicit C(int) {}
    C(const C&amp;) { &#43;&#43;n; }
    int x {1};
};

int main() {
    {
        BigObject obj = Foo();
    }
    //-----Foo()
    //       : BigObject local_obj  -&gt; ctor &#43; copy ctor
    //       : return local_obj     -&gt; dtor
    //BigObject obj
    //       :                      -&gt; copy ctor
    //                              -&gt; dtor
    //       :                      -&gt; dtor

    C c1(42);
    // copy ctor is equivalent to direct-ctor
    C c2 = C(42);
    std::cout &lt;&lt; &#34;n:&#34; &lt;&lt; n &lt;&lt; std::endl;
    return 0;
}

/*
g&#43;&#43; -g -fno-elide-constructors -Wall -std=c&#43;&#43;11 main.cpp
main.cpp: In function ‘int main()’:
main.cpp:49:7: warning: variable ‘c2’ set but not used [-Wunused-but-set-variable]
   49 |     C c2 = C(42);
      |       ^~

./a.out
constructor. 1000000
copy constructor. 1000000
destructor.
copy constructor. 1000000
destructor.
destructor.
n:1
*/

/*
g&#43;&#43; -g main.cpp
./a.out

constructor. 1000000
destructor.
n:0
*/
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-01-12-c-copy-elision/  

