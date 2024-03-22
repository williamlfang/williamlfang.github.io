# 企业微信机器人



&lt;!--more--&gt;

# 开通企业微信应用

1. 登录企业微信网站:https://work.weixin.qq.com/
2. &#39;应用管理 -&gt; (自建)创建应用&#39;, 配置相关的应用名称
3. 查看应用的 AgentID, Secret
4. 设置&#34;企业可信IP&#34;
5. &#34;接收消息&#34;(主要用于接收来自企业微信的信息,然后转发到我们自己的服务器)
6. 记住上面的 Token, EncodingAESKey, URL 暂时先不用填(先测试,后面再补充)

## 启动服务

```python
~/anaconda3/bin/python web.py -p=5000 -t=&#34;&lt;应用上面的Token&gt;&#34; -a=&#34;&lt;应用上面的EncodingAESKey&gt;&#34; -c=&#34;&lt;企业CorpID&gt;&#34;
```

可以测试一下

```bash
curl http://127.0.0.1:5000

{&#34;detail&#34;:[{&#34;loc&#34;:[&#34;query&#34;,&#34;msg_signature&#34;],&#34;msg&#34;:&#34;field required&#34;,&#34;type&#34;:&#34;value_error.missing&#34;},{&#34;loc&#34;:[&#34;query&#34;,&#34;timestamp&#34;],&#34;msg&#34;:&#34;field required&#34;,&#34;type&#34;:&#34;value_error.missing&#34;},{&#34;loc&#34;:[&#34;query&#34;,&#34;nonce&#34;],&#34;msg&#34;:&#34;field required&#34;,&#34;type&#34;:&#34;value_error.missing&#34;},{&#34;loc&#34;:[&#34;query&#34;,&#34;echostr&#34;],&#34;msg&#34;:&#34;field required&#34;,&#34;type&#34;:&#34;value_error.missing&#34;}]}
```

## 开通 nginx 外部访问

1. 在阿里云开通相关的端口 5000

2. 防火墙打开
    ```bash
    systemctl restart firewalld.service
    firewall-cmd --zone=public --add-port=5000/tcp --permanent
    systemctl stop firewalld.service
    ```

3. 修改 nginx.conf

4. 有可能是

    ```bash
    sudo vim /etc/nginx/nginx.conf

    server {
        listen 80;
        location /wechat {
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $http_host;
            proxy_pass http://127.0.0.1:5000;
        }
    }

    server {
        listen 80;
        server_name  robot.wuyacapital.com;
        location / {
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $http_host;
            proxy_pass http://127.0.0.1:4000;
        }
    }
    ```

## 企业微信回调测试

打开网页:https://open.work.weixin.qq.com/wwopen/devtool/interface/combine, &#34;建立连接 -&gt; 测试回调模式&#34;

```bash
URL: http://47.98.117.71:5000
URL: http://robot.wuyacapital.com &lt;这个没有回文也没问题&gt;
Token: &lt;Token&gt;
EncodingAESKey: &lt;EncodingAESKey&gt;
EchoStr: 123456
ToUserName: &lt;corpid&gt;
```

![](/post/2023-04-04-企业微信机器人/callback.png)

## 补充应用 URL

即把上面测试通过的 URL 填入即可

![](/post/2023-04-04-企业微信机器人/api.png)




---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-04-%E4%BC%81%E4%B8%9A%E5%BE%AE%E4%BF%A1%E6%9C%BA%E5%99%A8%E4%BA%BA/  

