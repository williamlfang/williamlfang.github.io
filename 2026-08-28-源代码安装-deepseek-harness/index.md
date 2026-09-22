# 源代码安装 deepseek harness




&lt;!--more--&gt;

```bash
#FIXME: 需要使用 node-24
# https://nodejs.org/en/download
node --version
v24.20.0

npm install -g pnpm

git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build

# FIXME: 默认使用环境变量里的参数配置
export DEEPSEEK_API_KEY=&#34;&#34;
echo $DEEPSEEK_API_KEY

pnpm dsh web

## dsh-cli
git clone https://github.com/soolaugust/deepseek-harness-cli.git
cd deepseek-harness-cli
pnpm install
pnpm run build
pnpm dsh cli
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-08-28-%E6%BA%90%E4%BB%A3%E7%A0%81%E5%AE%89%E8%A3%85-deepseek-harness/  

