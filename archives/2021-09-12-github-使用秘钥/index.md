# github 使用秘钥


错误提示如下：

```bash
git push origin master

Alias tip: gp origin master
Username for &#39;https://github.com&#39;: williamlfang
Password for &#39;https://williamlfang@github.com&#39;:
remote: Support for password authentication was removed on August 13, 2021. Please use a personal access token instead.
remote: Please see https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/ for more information.
fatal: Authentication failed for &#39;https://github.com/williamlfang/blog.git/&#39;
```

参考：[How to fix the GitHub Support for password authentication error](https://reactgo.com/github-password-authentication-removed/)

- To fix the error, follow the below steps:
  1. Open GitHub.com, click on your profile picture, then click on settings.
  2. Now, scroll to the bottom of a page and click on the Developer settings tab.
  3. Now, click on Personal access tokens and generate a new token by giving the name and expiration date, etc.
  4. Once you successfully generated the Personal access token copy it.
  5. Now, open the Git repository where you got the error and remove the current origin by running the following command.

```bash
git remote remove origin

git remote add origin https://&lt;Token&gt;@github.com/williamlfang/blog.git

git push --set-upstream origin master
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-09-12-github-%E4%BD%BF%E7%94%A8%E7%A7%98%E9%92%A5/  

