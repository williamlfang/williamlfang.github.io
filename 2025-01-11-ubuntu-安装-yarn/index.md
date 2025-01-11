# ubuntu 安装 yarn



```bash
## install nodejs
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt-get install nodejs -y

## add repo for yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo &#34;deb https://dl.yarnpkg.com/debian/ stable main&#34; | sudo tee /etc/apt/sources.list.d/yarn.list

## install yarn
apt-get update
apt-get install yarn

## now we have it
yarn --version
```

&lt;!--more--&gt;



---

> 作者: william  
> URL: https://williamlfang.github.io/2025-01-11-ubuntu-%E5%AE%89%E8%A3%85-yarn/  

