# Linux 查看公网IP


由于我们做程序化交易需要调用 `CTP` 的接口，需要把本地机器的 `IP` 报备给经纪商（期货公司、证券公司）。但其实我们使用的是公网 `IP` 而非固定 `IP`，因此这个也不一定在每次联网后都一样。

尽管如此，我还是把相关的命令做一下备忘。

&lt;!--more--&gt;

# 安装 `curl`

```bash
## 如果没有安装 curl
## Ubuntu
sudo apt install curl
## CentOS
sudo yum install curl
```

# 命令


## `cip.cc`

```bash
curl cip.cc
IP  : 116.24.99.235
地址  : 中国  广东  深圳
运营商 : 电信

数据二 : 广东省深圳市 | 电信

数据三 : 中国广东省深圳市 | 电信

URL : http://www.cip.cc/116.24.99.235
```


## `ipinfo.io`

可以使用 `ipinfo.io` 网站进行查询

```bash
curl ipinfo.io | more
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   159  100   159    0     0    748      0 --:--:-- --:--:-- --:--:--   764

{
  &#34;ip&#34;: &#34;116.24.99.235&#34;,
  &#34;city&#34;: &#34;Yuanlong&#34;,
  &#34;region&#34;: &#34;Guangdong&#34;,
  &#34;country&#34;: &#34;CN&#34;,
  &#34;loc&#34;: &#34;22.7699,112.9350&#34;,
  &#34;org&#34;: &#34;AS4134 CHINANET-BACKBONE&#34;
}
```


---

> 作者:   
> URL: https://williamlfang.github.io/archives/2019-02-25-linux-%E6%9F%A5%E7%9C%8B%E5%85%AC%E7%BD%91ip/  

