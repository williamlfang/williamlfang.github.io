# CTP 中文乱码解析


有时我们在开发类 `CTP` 接口（如 CTP、TORA）等，会遇到中文消息乱码的现象，这是由于接口采用了 `GB10830` 等编码规范，无法直接在终端使用 `UTF8` 进行解析。因此，我们需要在接收层面进行解码，同时配置系统的解码标准。

&lt;!--more--&gt;


## c&#43;&#43; 解码

```c&#43;&#43;
#pragma once
#include &lt;locale&gt;
#include &lt;codecvt&gt;
#include &lt;string&gt;

namespace snail
{

template &lt;class Facet&gt;
struct deletable_facet : Facet
{
    template &lt;class... Args&gt;
    deletable_facet(Args &amp;&amp;... args) : Facet(std::forward&lt;Args&gt;(args)...) {}
    ~deletable_facet() {}
};

inline std::wstring string2wstring(const std::string &amp;str, const std::string &amp;locale)
{
    typedef deletable_facet&lt;std::codecvt_byname&lt;wchar_t, char, std::mbstate_t&gt;&gt; F;
    static std::wstring_convert&lt;F&gt; strCnv(new F(locale));
    return strCnv.from_bytes(str);
}

inline std::string wstring2utf8string(const std::wstring &amp;str)
{
    static std::wstring_convert&lt;std::codecvt_utf8&lt;wchar_t&gt;&gt; strCnv;
    return strCnv.to_bytes(str);
}

inline std::string str2utf8(const std::string &amp;str)
{
    return wstring2utf8string(string2wstring(str, &#34;zh_CN.GB18030&#34;));
}

} // namespace snail
```

上面封装了接口 `str2utf8`，可以用来解析中文信息

```c&#43;&#43;
bool check_rsp(CTORATstpRspInfoField *pRspInfoField, const char* func_name)
{
    if (unlikely(pRspInfoField &amp;&amp; pRspInfoField-&gt;ErrorID != 0))
    {
        L_err(&#34;[tora_gw] &#34;, func_name,
              &#34;, ErrorID:&#34;, pRspInfoField-&gt;ErrorID,
              &#34;, ErrorMsg:&#34;, str2utf8(pRspInfoField-&gt;ErrorMsg));
        return false;
    }
    else
    {
        return true;
    }
}
```

## 系统设置

同时，我们还需要在系统层面进行设置

```bash
## CentOS
yum install -y kde-l10n-Chinese
localedef -c -f GB18030 -i zh_CN zh_CN.GB18030

## Ubuntu
localedef -c -f GB18030 -i zh_CN zh_CN.GB18030
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-07-06-ctp-%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81%E8%A7%A3%E6%9E%90/  

