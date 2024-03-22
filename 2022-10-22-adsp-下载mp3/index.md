# ASDP 下载mp3


ADSP(Algo &#43; Data Structure = Programming) 是一个优秀的播客网站，经常邀请一些编程界的大佬的探讨技术性话题，截止目前（2022-10-20）已经录制正好100期节目了。

该网站同时还提供了音频下载，方便用户离线收听。不过对于懒人如我者（程序员福利），当然想着使用脚本来自动化下载了。话不多说，show the code。

&lt;!--more--&gt;


```python
import bs4
import re
import requests
import os
from datetime import datetime

links = []
for i in range(1,21):
    if i == 1:
        url = f&#34;https://adspthepodcast.com&#34;
    else:
        url = f&#34;https://adspthepodcast.com/blog/page{i}/&#34;
    rsp = requests.get(url)
    soup = bs4.BeautifulSoup(rsp.text, &#39;html.parser&#39;).find_all(&#39;a&#39;)
    links.extend([link.get(&#39;href&#39;) for link in soup if &#39;Episode&#39; in link.get(&#39;href&#39;)])

for k in links:
    url = f&#34;https://adspthepodcast.com/{k}&#34;
    print(f&#34;{datetime.now()} processing url ==&gt; {url}&#34;)

    rsp = requests.get(url)
    soup = bs4.BeautifulSoup(rsp.text, &#39;html.parser&#39;)
    ## 这里需要查看一下 soup 里面具体的格式
    ## 发现 section 这个地方出现了下载链接
    res = soup.find_all(name=&#39;section&#39;)[0].find(&#39;script&#39;).get(&#39;src&#39;)
    res = re.sub(r&#34;.js&#34;, r&#34;.mp3&#34;, res)

    ## 提取title
    # title = re.sub(&#39;.*(episode.*mp3).*&#39;, &#39;\\1&#39;, res)
    title = &#39;-&#39;.join(res.split(&#39;?&#39;)[0].split(&#39;/&#39;)[-1].split(&#39;-&#39;)[1:])
    filename = f&#39;/home/william/Downloads/ADSP/{title}&#39;
    if os.path.isfile(filename):
        continue

    mp3 = requests.get(res)
    with open(filename, &#39;wb&#39;) as f:
            f.write(mp3.content)
    print(f&#34;{datetime.now()} saved file ==&gt; {filename}&#34;)
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2022-10-22-adsp-%E4%B8%8B%E8%BD%BDmp3/  

