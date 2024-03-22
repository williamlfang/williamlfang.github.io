# catch2: 测试框架


`catch2` 是一个可扩展性非常高的测试框架。

&lt;!--more--&gt;

# 安装

# Demo

## 代码

```c&#43;&#43;
/*
* @Author: &#34;william&#34;
* @Date:   2020-10-19 17:21:32
* @Last Modified by:   &#34;william&#34;
* @Last Modified time: 2020-10-19 17:29:18
*/
#define CATCH_CONFIG_RUNNER
#include &#34;catch.hpp&#34;

int main( int argc, char *argv[])
{
    int res = Catch::Session().run( argc, argv);
    return res;

    // =========================================================================
    // Catch::Session session; // There must be exactly one instance

    // int height = 0; // Some user variable you want to be able to set

    // // Build a new parser on top of Catch&#39;s
    // using namespace Catch::clara;
    // auto cli
    //   = session.cli() // Get Catch&#39;s composite command line parser
    //   | Opt( height, &#34;height&#34; ) // bind variable to a new option, with a hint string
    //       [&#34;-g&#34;][&#34;--height&#34;]    // the option names it will respond to
    //       (&#34;how high?&#34;);        // description string for the help output

    // // Now pass the new composite back to Catch so it uses that
    // session.cli( cli );

    // // Let Catch (using Clara) parse the command line
    // int returnCode = session.applyCommandLine( argc, argv );
    // if( returnCode != 0 ) // Indicates a command line error
    //     return returnCode;
    // return session.run();
    // =========================================================================
}

int Factorial( int number ) {
    return number &lt;= 1 ? number : Factorial( number - 1 ) * number;  // fail
    // return number &lt;= 1 ? 1      : Factorial( number - 1 ) * number;  // pass
}

TEST_CASE( &#34;Factorial of 0 is 1 (fail)&#34;, &#34;[single-file]&#34; ) {
    REQUIRE( Factorial(0) == 1 );
}

TEST_CASE( &#34;Factorials of 1 and higher are computed (pass)&#34;, &#34;[single-file]&#34; ) {
    REQUIRE( Factorial(1) == 1 );
    REQUIRE( Factorial(2) == 2 );
    REQUIRE( Factorial(3) == 6 );
    REQUIRE( Factorial(10) == 3628800 );
}
```

## 编译

```bash
g&#43;&#43; -std=c&#43;&#43;11 main.cpp
```

## 运行

```bash
./a.out                                                                            [17:28:46]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
a.out is a Catch v2.13.0 host application.
Run with -? for options

-------------------------------------------------------------------------------
Factorial of 0 is 1 (fail)
-------------------------------------------------------------------------------
main.cpp:44
...............................................................................

main.cpp:45: FAILED:
  REQUIRE( Factorial(0) == 1 )
with expansion:
  0 == 1

===============================================================================
test cases: 2 | 1 passed | 1 failed
assertions: 5 | 4 passed | 1 failed
```

# 技巧



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-10-19-catch2--%E6%B5%8B%E8%AF%95%E6%A1%86%E6%9E%B6/  

