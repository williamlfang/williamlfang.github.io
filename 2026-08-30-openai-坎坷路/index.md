# openai 坎坷路




&lt;!--more--&gt;


1. 购买 `just my socks5(tokyo100)`
2. 安装 `xray` &#43; `xrayA`
    ```bash
    sudo sh -c &#34;$(proxychains4 wget -qO- https://github.com/v2rayA/v2rayA-installer/raw/main/installer.sh)&#34; @ --with-xray
    sudo systemctl daemon-reload
    sudo systemctl restart v2raya
    ## web gui: http://127.0.0.1:2017
    ```
3. 使用 `Proxy Omega` 区分不同的代理模式(`openai`需要全程走独立 ip)
4. 使用代理打开 `codex`,
    ```bash
    alias codex=&#39;export http_proxy=http://127.0.0.1:1086/; export https_proxy=http://127.0.0.1:1086/; /opt/homebrew/bin/codex&#39;
    ```
5. 代充值: https://www.getplus.ai/
6. 在远程机器打开 codex 的配置
    - 先在 chatgpt.com 网页打开 setting -&gt; security and login -&gt; Enable devide code authorization for Codex
    - 然后使用命令行登录 codex login --device-auth
    - 登录一次后,后续就可以使用 codex 执行了
    - 可能需要配置 `~/.codex/.env`
        ```bash
        HTTP_PROXY=&#34;http://192.168.1.82:20170&#34;
        HTTPS_PROXY=&#34;http://192.168.1.82:20170&#34;
        NO_PROXY=&#34;localhost,127.0.0.1,::1&#34;
        ```
    - 有时候可能会因为环境变量包含了 `OPENAI_API_KEY` 导致登陆使用了 api，但是这个 api key 又是不对的
        ```bash
        unset CODEX_ACCESS_TOKEN
        unset OPENAI_API_KEY
        ```
    - 或者 node 环境版本不对, node16 node18 混用等

7. `CentOS` 可以下载 `codex standalone`
    ```bash
    ## 使用 node18
    wget https://nodejs.org/dist/v18.12.0/node-v18.12.0-linux-x64.tar.xz
    ## FIXME: 确认 $PATH 只有一个版本的 node
    echo $PATH |ag node
    ## 使用独立包:https://github.com/openai/codex/releases
    wget https://github.com/openai/codex/releases/download/rust-v0.153.4/codex-x86_64-unknown-linux-musl.tar.gz
    tar -xvf codex-x86_64-unknown-linux-musl.tar.gz
    ln -sfn /home/ops/tmp/codex-x86_64-unknown-linux-musl /home/ops/.codex/packages/standalone/current/codex

    # FIXME: 需要添加到 ~/.bashrc system path, 否则 Codex Desktop 无法连接(因为需要调用启动)
    ln -s /home/ops/.codex/packages/standalone/current/codex /home/ops/local/bin/codex
    export PATH=/home/ops/local/bin:$PATH

    ## codex-cli
    codex login --device-auth

    ## codex-remote
    codex remote-control start

    ## Codex Remote ssh(PowerShell)
    ssh-keygen -t rsa -b 4096 -f &#34;$env:USERPROFILE\.ssh\id_rsa_ops&#34; -C &#34;ops-key&#34;
    Get-Content &#34;$env:USERPROFILE\.ssh\id_rsa_ops.pub&#34;
    Get-Content &#34;$env:USERPROFILE\.ssh\id_rsa_ops.pub&#34; |
        ssh ops@10.32.1.183 &#39;umask 077; mkdir -p ~/.ssh; cat &gt;&gt; ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys&#39;
    ssh -o IdentitiesOnly=yes -i &#34;$env:USERPROFILE\.ssh\id_rsa_ops&#34; ops@10.32.1.183
    ## Only copy the .pub file to the server. Keep the private key on your computer.

    ## 在 Codex  Desktop -&gt; setting -&gt; SSH -&gt; add remote
    ## 需要确保能 ssh 免密登录上去
    ```




---

> 作者: william  
> URL: https://williamlfang.github.io/2026-08-30-openai-%E5%9D%8E%E5%9D%B7%E8%B7%AF/  

