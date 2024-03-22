# docker 安装 gitbook


## docker-compose

```docker-compose
version: &#34;3&#34;
services:
  gitbook:
    hostname: gitbook
    container_name: gitbook
    image: fellah/gitbook
    pull_policy: always
    restart: always
    privileged: true
    tty: true
    volumes:
      - /data/gitbook:/srv/gitbook
      - /etc/localtime:/etc/localtime
    ports:
      - 4000:4000
    command:
      - /bin/bash
      - -c
      - |
        /bin/bash
```

&lt;!--more--&gt;

## gitbook

### SUMMARY.md

```markdown
# Summary

* [Introduction](README.md)

* [bash](bash.md)
```

### book.jon

对于整个网站的风格，可以通过 `book.json` 的配置进行渲染：
```json
{
    &#34;plugins&#34;: [
        &#34;-sharing&#34;,
        &#34;theme-comscore&#34;
    ]
}
```

### 开始部署

```bash
npm i gitbook-plugin-theme-default
npm i gitbook-plugin-theme-comscore
npm i -g gitbook-cli

gitbook init .
gitbook install
gitbook serve . &amp;

Starting server ...
Serving book on http://localhost:4000
```

### 删除 publish with gitbook

ref: https://blog.tedxiong.com/how_to_remove_Published_with_GitBook_in_GitBook.html

- 首先，在book的根目录里创建styles文件夹，然后在其中创建website.css文件，添加以下内容:

    ```css
    .gitbook-link {
        display: none !important;
    }
    ```

- 编辑book.json文件

    ```json
    {
      &#34;styles&#34;: {
          &#34;website&#34;: &#34;styles/website.css&#34;
      }
    }
    ```


---

> 作者: william  
> URL: https://williamlfang.github.io/2024-03-07-docker-%E5%AE%89%E8%A3%85-gitbook/  

