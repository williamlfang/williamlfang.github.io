# Linux 修改密码报错：BAD PASSWORD: The password contains the user name in some form


修改 `Linux` 用户密码过于简单，出现如下报错

```bash
BAD PASSWORD: The password contains the user name in some form
```

这个是一种保护，当然也可以绕过这层限制

```bash
echo &#34;test:abtest123&#34; | chpasswd
```

其中
- `test` 是用户名
- `abtest123` 从简单密码


&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2024-10-31-linux-%E4%BF%AE%E6%94%B9%E5%AF%86%E7%A0%81%E6%8A%A5%E9%94%99-bad-password--the-password-contains-the-user-name-in-some-form/  

