# c&#43;&#43; lambda to funtion pointer




&lt;!--more--&gt;

```c&#43;&#43;
// Source: https://stackoverflow.com/a/48368508/17132546
#include &lt;iostream&gt;
using namespace std;

// Entry template
//	extract the lambda&#39;s operaor() function signature
template &lt;class F, class T=F&gt;
struct lambda_traits: lambda_traits&lt;decltype(&amp;std::remove_reference&lt;F&gt;::type::operator()), F&gt;
{};

// For mutable lambda, See https://en.cppreference.com/w/cpp/language/lambda
//	mutable lambda&#39;s operator() is not const,
//	not mutable lambda&#39;s operator() is const
template &lt;typename rF, typename F, typename R, typename... Args&gt;
struct lambda_traits&lt;R(rF::*)(Args...), F&gt;: lambda_traits&lt;R(rF::*)(Args...) const, F&gt;
{};

// Workhorse
//	every lambda has an unique signature
//	=&gt; lambda_traits will be specialized for every lambda, even if their function signature are the same.
template &lt;typename rF, typename F, typename R, typename... Args&gt;
struct lambda_traits&lt;R(rF::*)(Args...) const, F&gt; {
	static auto cify(F&amp;&amp; f) {
		static rF fn = std::forward&lt;F&gt;(f);
		return [](Args... args) {
			return fn(std::forward&lt;Args&gt;(args)...);
		};
	}
};

// Wrapper, for convenience
template &lt;class F&gt;
inline auto lam2fp(F&amp;&amp; f) {
	return lambda_traits&lt;F&gt;::cify(std::forward&lt;F&gt;(f));
}

// usage
class A {
public:
    using cb_t = void(*)(int);
	A() { cout &lt;&lt; &#34;A()\n&#34;; }
	A(const A&amp; k) { cout &lt;&lt; &#34;A(const A&amp;)\n&#34;; }
	A(A&amp;&amp; k) { cout &lt;&lt; &#34;A(const A&amp;&amp;)\n&#34;; }

    void register_cb(cb_t cb)
    {
        _cb = cb;
    }

    void run()
    {
        if (_cb)
        {
            _cb(_i&#43;&#43;);
        }
    }

private:
    int _i {0};
    cb_t _cb {nullptr};
};

struct X
{
    X()
    {
        cout &lt;&lt; &#34;X::ctor&#34; &lt;&lt; endl;
    }
    int a {0};
};

int main() {
    {
        A a;
        X x;
        cout &lt;&lt; &#34;register_cb:-------------------&#34; &lt;&lt; endl;

        a.register_cb(lam2fp([&amp;x](int i)
            {
                cout &lt;&lt; &#34;i:&#34; &lt;&lt; endl;
                cout &lt;&lt; &#34;x.a:&#34; &lt;&lt; x.a &lt;&lt; endl;
            })
        );
        cout &lt;&lt; &#34;run1:&#34; &lt;&lt; endl;
        a.run();

        cout &lt;&lt; &#34;run2:&#34; &lt;&lt; endl;
        a.run();
    }

#if 0
	auto lam_left = [&amp;](A&amp; a) {};
	auto lam_copy = [](A a) {};

	// lambda: left ref    args: left ref
	auto g_left  = lam2fp(lam_left);
	// lambda: left ref    args: copy -&gt; right ref
	auto g       = lam2fp(lam_copy);
	// lambda: right ref   args: right ref
	auto g_right = lam2fp([](A&amp;&amp; a) {});

	cout &lt;&lt; &#34;----g_left----\n&#34;;
	A a;
	g_left(a);
	cout &lt;&lt; &#34;----g----\n&#34;;
	A b;
	g(b);
	cout &lt;&lt; &#34;----g_right----\n&#34;;
	g_right(A());
#endif

	return 0;
}
```

```c&#43;&#43;
// Source: https://stackoverflow.com/a/48368508/17132546
#include &lt;iostream&gt;
using namespace std;

// Entry template
//	extract the lambda&#39;s operaor() function signature
template &lt;class F, class T=F&gt;
struct lambda_traits: lambda_traits&lt;decltype(&amp;std::remove_reference&lt;F&gt;::type::operator()), F&gt;
{};

// For mutable lambda, See https://en.cppreference.com/w/cpp/language/lambda
//	mutable lambda&#39;s operator() is not const,
//	not mutable lambda&#39;s operator() is const
template &lt;typename rF, typename F, typename R, typename... Args&gt;
struct lambda_traits&lt;R(rF::*)(Args...), F&gt;: lambda_traits&lt;R(rF::*)(Args...) const, F&gt;
{};

// Workhorse
//	every lambda has an unique signature
//	=&gt; lambda_traits will be specialized for every lambda, even if their function signature are the same.
template &lt;typename rF, typename F, typename R, typename... Args&gt;
struct lambda_traits&lt;R(rF::*)(Args...) const, F&gt; {
	static auto cify(F&amp;&amp; f) {
		static rF fn = std::forward&lt;F&gt;(f);
		return [](Args... args) {
			return fn(std::forward&lt;Args&gt;(args)...);
		};
	}
};

// Wrapper, for convenience
template &lt;class F&gt;
inline auto lam2fp(F&amp;&amp; f) {
	return lambda_traits&lt;F&gt;::cify(std::forward&lt;F&gt;(f));
}

// usage
class A {
public:
    using cb_t = void(*)(int);

	A() { cout &lt;&lt; &#34;A()\n&#34;; }
	A(const A&amp; k) { cout &lt;&lt; &#34;A(const A&amp;)\n&#34;; }
	A(A&amp;&amp; k) { cout &lt;&lt; &#34;A(const A&amp;&amp;)\n&#34;; }

    void run(void(*cb)(int))
    {
        cb(_i&#43;&#43;);
    }

private:
    int _i {0};
};

struct X
{
    X()
    {
        cout &lt;&lt; &#34;X::ctor&#34; &lt;&lt; endl;
    }
    int a {0};
};

int main() {
    {
        A a;
        X x;
        cout &lt;&lt; &#34;start:-------------------&#34; &lt;&lt; endl;

        cout &lt;&lt; &#34;run1:&#34; &lt;&lt; endl;
        a.run(lam2fp([&amp;x](int i)
            {
                cout &lt;&lt; &#34;i:&#34; &lt;&lt; endl;
                cout &lt;&lt; &#34;x.a:&#34; &lt;&lt; x.a &lt;&lt; endl;
            }));

        cout &lt;&lt; &#34;run1:&#34; &lt;&lt; endl;
        a.run(lam2fp([&amp;x](int i)
            {
                cout &lt;&lt; &#34;i:&#34; &lt;&lt; endl;
                cout &lt;&lt; &#34;x.a:&#34; &lt;&lt; x.a &lt;&lt; endl;
            }));
    }

#if 0
	auto lam_left = [&amp;](A&amp; a) {};
	auto lam_copy = [](A a) {};

	// lambda: left ref    args: left ref
	auto g_left  = lam2fp(lam_left);
	// lambda: left ref    args: copy -&gt; right ref
	auto g       = lam2fp(lam_copy);
	// lambda: right ref   args: right ref
	auto g_right = lam2fp([](A&amp;&amp; a) {});

	cout &lt;&lt; &#34;----g_left----\n&#34;;
	A a;
	g_left(a);
	cout &lt;&lt; &#34;----g----\n&#34;;
	A b;
	g(b);
	cout &lt;&lt; &#34;----g_right----\n&#34;;
	g_right(A());
#endif

	return 0;
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-21-c-lambda-to-funtion-pointer/  

