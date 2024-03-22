# Python openapi&#43;ChatGPT


使用 `python` 接口调用 `openapi chatgpt`。

&lt;!--more--&gt;

# 注册 OpenAI 账户

## 使用 LA VPN（不能用香港VPN）

## 使用 Google 账户

## 获取 SMS （Indonesia）

Ref: https://sms-activate.org/getNumber。最低充值2刀(可以使用支付宝)。
左侧选择 `OpenAI -&gt; Indonesia -&gt; 等待短信消息`， 如果不成功，可以点击右侧关闭，重新更新手机号（不收钱）。

## 获取 API-key

Ref: https://platform.openai.com/account/api-keys

## Chrome 安装插件

Ref: chrome-extension://jgjaeacdkonaoafenlfkkkmbaopkbilf/options.html


# python demo

目前版本还只能使用 `model=&#34;gpt-3.5-turbo&#34;`, 新版本 `gpt-4.0` 需要申请 waiting-list。
另外，调用接口需要梯子。

```bash
## 以下均需要使用梯子
p4 ~/anaconda3/bin/python3 -m pip install openai
p4 ipython
```

```python
import os
import openai
openai.api_key = OPEN_API_KEY
completion = openai.ChatCompletion.create(
  model=&#34;gpt-3.5-turbo&#34;,
  messages=[
    {&#34;role&#34;: &#34;user&#34;, &#34;content&#34;: &#34;show me the futures of programming.&#34;}
  ]
)

print(completion.choices[0].message.content)
```



---

> 作者: william  
> URL: https://williamlfang.github.io/2023-04-02-python-openapi-chatgpt/  

