# Linux c&#43;&#43; 隐藏 cin 输入


通过隐藏实现，可以很好的避免执行命令被监控到。
&lt;!--more--&gt;

## mymain

```c&#43;&#43;
#include &lt;iostream&gt;
#include &lt;string&gt;
#include &lt;termios.h&gt;
#include &lt;unistd.h&gt;

using namespace std;

int main()
{
    termios oldt;
    tcgetattr(STDIN_FILENO, &amp;oldt);
    termios newt = oldt;
    newt.c_lflag &amp;= ~ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &amp;newt);

    string passwd;
    getline(cin, passwd);

    cout &lt;&lt; passwd &lt;&lt; endl;
    return 0;
}//main
```

## myssh

```c&#43;&#43;
#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;sys/types.h&gt;
#include &lt;unistd.h&gt;
#include &lt;string&gt;
#include &lt;iostream&gt;
#include &lt;termios.h&gt;

using namespace std;

int main(void)
{
    // -------------------------------------------------------------------
    termios oldt;
    tcgetattr(STDIN_FILENO, &amp;oldt);
    termios newt = oldt;
    newt.c_lflag &amp;= ~ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &amp;newt);

    std::string passwd;
    std::cout &lt;&lt; &#34;welcome: &#34;;
    getline(cin, passwd);
    std::string answer;
	for (const auto&amp; e : {&#34;************&#34;})
		answer &#43;= e;
    if (passwd != answer)
    {
        std::cout &lt;&lt; &#34;Bye!&#34; &lt;&lt; std::endl;
        return -1;
    }
    std::cout &lt;&lt; std::endl;
    tcsetattr(STDIN_FILENO, TCSANOW, &amp;oldt);
    // -------------------------------------------------------------------

	std::string cmd = &#34;sshpass -p &#34; &#43; passwd &#43; &#34; -P22 ssh william@127.0.0.1&#34;;
    // std::cout &lt;&lt; cmd &lt;&lt; std::endl;
    system(cmd.c_str());
}

```

## mysync

```c&#43;&#43;
#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;sys/types.h&gt;
#include &lt;unistd.h&gt;
#include &lt;string&gt;
#include &lt;iostream&gt;
#include &lt;termios.h&gt;

using namespace std;
int main(int argc, char* argv[])
{
    // -------------------------------------------------------------------
    termios oldt;
    tcgetattr(STDIN_FILENO, &amp;oldt);
    termios newt = oldt;
    newt.c_lflag &amp;= ~ECHO;
    tcsetattr(STDIN_FILENO, TCSANOW, &amp;newt);

    std::string passwd;
    std::cout &lt;&lt; &#34;welcome: &#34;;
    getline(cin, passwd);
    std::string answer;
	for (const auto&amp; e : {&#34;************&#34;})
		answer &#43;= e;
    if (passwd != answer)
    {
        std::cout &lt;&lt; &#34;Bye!&#34; &lt;&lt; std::endl;
        return -1;
    }
    std::cout &lt;&lt; std::endl;
    tcsetattr(STDIN_FILENO, TCSANOW, &amp;oldt);
    // -------------------------------------------------------------------

    std::string srcpath;
    std::cout &lt;&lt; &#34;srcpath: &#34;;
    std::cin &gt;&gt; srcpath;

    std::string destpath;
    std::cout &lt;&lt; &#34;destpath: &#34;;
    std::cin &gt;&gt; destpath;
    std::cout &lt;&lt; std::endl;

    std::string cmd;

    system(cmd.c_str());
}
```





---

> 作者: william  
> URL: https://williamlfang.github.io/2021-11-20-linux-c-%E9%9A%90%E8%97%8F-cin-%E8%BE%93%E5%85%A5/  

