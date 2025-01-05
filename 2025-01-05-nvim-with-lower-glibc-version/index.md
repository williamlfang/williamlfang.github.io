# nvim with lower glibc version


I&#39;m writting code on a rather outdated Linux CentoOS7, with `glibc` of version up to &#39;2.18&#39;. And for a meanwhile, there is no hope to upgrade it, since we&#39;ve deployed quite a lot of services, meaning updating may cause some unanticipated crashes.

I&#39;ve also learned that starting from `v0.10.0`, `neovim` would support **buildin inlay**, which definitely enhance our code reading. It&#39;s gonna to be the main reason I need to upgrade `nvim`. The sad part of this story is that, the official release of `nvim` require at lease `glibc` of version 2.29.

However, there is on repo provide **unsupported release version** of `nvim` for some legacy systems. And it only require `glibc` of version `2.17`. What a great job!

In case anyone would need this

{{&lt; link &#34;https://github.com/neovim/neovim-releases&#34; &#34;nvim with lower glibc&#34; &#34;unsupported release version&#34; true true &gt;}}


Now I&#39;m happy with it.

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-05-nvim-with-lower-glibc-version/  

