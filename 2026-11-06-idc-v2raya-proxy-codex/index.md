# Use the IDC proxy from XPS and Codex


My XPS uses `lfang.idc` as a proxy gateway. v2rayA runs on the IDC host, and applications on XPS connect to the gateway over the private network. Codex needs one extra check: its shared app-server daemon keeps the environment it received when it started.

&lt;!--more--&gt;

## The network

```mermaid
flowchart LR
    app[XPS application] --&gt;|Private network| socks[&#34;SOCKS5 :1080&#34;]
    app --&gt;|Private network| http[&#34;HTTP proxy :20170&#34;]
    subgraph idc[&#34;lfang.idc — 10.32.111.107&#34;]
        socks --&gt; proxy[Proxy]
        http --&gt; proxy
        ui[&#34;v2rayA management UI :2017&#34;]
    end
    proxy --&gt; node[Selected remote node] --&gt; destination[&#34;Destination, e.g. chatgpt.com&#34;]
    browser[XPS browser] --&gt;|Private network| ui
```

The top path shows the intended route through the selected remote proxy node; responses follow the path back to XPS. Only applications configured to use one of these proxy endpoints take this route. The browser&#39;s management connection configures v2rayA and is separate from proxied traffic.

`lfang.idc` is an SSH alias for `10.32.111.107`. On November 6, 2026, both proxy endpoints reached `https://chatgpt.com/` from XPS. The host has a Docker container named `v2raya`, and also runs a separate V2Ray process. The owner of each proxy listener and the upstream path have not been verified, so check the host before changing ports or removing either process.

## Set up v2rayA on lfang.idc

The existing host runs CentOS 7 and Docker. Its `v2raya` container uses host networking, the image `ghcr.io/v2raya/v2raya:v2.5.13`, a named volume mounted at `/etc/v2raya`, and the argument `--address 10.32.111.107:2017`. Inspect the existing container before creating another one:

```bash
ssh lfang.idc
docker ps --filter name=v2raya
docker inspect v2raya --format &#39;network={{.HostConfig.NetworkMode}} restart={{.HostConfig.RestartPolicy.Name}} image={{.Config.Image}}&#39;
docker logs --tail 50 v2raya
netstat -lnt | grep -E &#39;:(2017|1080|20170) &#39;
```

For a new host with Docker installed, this starts a container with the observed image, network mode, management address, and persistent volume. Run it only if a container with that name does not already exist:

```bash
docker volume create v2raya-config
docker run -d \
  --name v2raya \
  --restart unless-stopped \
  --network host \
  -v v2raya-config:/etc/v2raya \
  ghcr.io/v2raya/v2raya:v2.5.13 \
  --address 10.32.111.107:2017
```

The host must own `10.32.111.107`. From XPS, open `http://10.32.111.107:2017`, create the management account, import the private node or subscription, select a node, and start the connection. Keep subscription links and node credentials out of the blog and shell history. Enable LAN sharing in v2rayA if other machines need to use its proxy, then configure its inbound ports and restrict access to trusted clients with the host firewall. See the [v2rayA Docker guide](https://v2raya.org/en/docs/prologue/installation/docker/) and [quick start](https://v2raya.org/en/docs/prologue/quick-start/).

The command above recreates the observed container settings, not its private node configuration or any separate V2Ray service. v2rayA documents `20170` as a default SOCKS5 port and `20171` as a default HTTP port. This IDC setup answers HTTP on `20170` and SOCKS5 on `1080`; verify the actual listeners and protocols before relying on those numbers on a rebuilt host. Exposing an unauthenticated proxy or management UI to an untrusted network lets other people use or change it.

## Use the proxy on XPS

First test the two endpoints without inheriting an existing proxy bypass list:

```bash
curl --proxy socks5h://10.32.111.107:1080 --noproxy &#39;&#39; \
  --fail --show-error --location --connect-timeout 10 --max-time 30 \
  --output /dev/null --write-out &#39;SOCKS5: HTTP %{http_code}\n&#39; https://chatgpt.com/

curl --proxy http://10.32.111.107:20170 --noproxy &#39;&#39; \
  --fail --show-error --location --connect-timeout 10 --max-time 30 \
  --output /dev/null --write-out &#39;HTTP proxy: HTTP %{http_code}\n&#39; https://chatgpt.com/
```

`socks5h` sends the destination hostname to the proxy for DNS resolution. A successful test returns HTTP 200. A timeout, a proxy error, or an unexpected response means the endpoint needs investigation before changing application settings.

For programs that use proxychains, the existing `~/.config/proxychains.idc.conf` enables `proxy_dns` and has this active entry:

```text
[ProxyList]
socks5 10.32.111.107 1080
```

The XPS `.zshrc` defines `p.idc` as a shortcut. In an interactive zsh shell, for example:

```zsh
p.idc curl --fail --show-error --location --connect-timeout 10 --max-time 30 https://www.google.com/ -o /dev/null
```

The `proxychains4` shell function clears inherited proxy variables before launching proxychains, so the command uses the configured chain. Proxychains relies on library interception and does not work for every binary. For clients with native proxy support, use their proxy option or process-scoped environment variables instead. Avoid stacking proxychains and a separate application proxy unintentionally.

## Configure Codex on XPS

The existing `.zshrc` function sets the IDC HTTP proxy for each `codex` invocation. Its current `ALL_PROXY` value uses SOCKS5 on port `20170`, but the tested SOCKS5 endpoint is port `1080`. The following replacement uses the tested protocols and keeps proxy variables scoped to Codex:

```zsh
codex() {
    local proxy=&#39;http://10.32.111.107:20170&#39;
    local socks=&#39;socks5h://10.32.111.107:1080&#39;
    local no=&#39;localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16&#39;
    env HTTP_PROXY=&#34;$proxy&#34; HTTPS_PROXY=&#34;$proxy&#34; \
        http_proxy=&#34;$proxy&#34; https_proxy=&#34;$proxy&#34; \
        ALL_PROXY=&#34;$socks&#34; all_proxy=&#34;$socks&#34; \
        NO_PROXY=&#34;$no&#34; no_proxy=&#34;$no&#34; \
        ~/.local/bin/codex &#34;$@&#34;
}
```

Replace the existing function in `~/.zshrc`, then run `source ~/.zshrc` or open a new terminal. `NO_PROXY` is intended to keep local and private addresses direct; applications differ in their support for CIDR ranges, so test any private service they must reach.

### Update the shared daemon&#39;s environment

Without `--no-daemon`, Codex can reuse a shared background server. Changing `.zshrc` does not change an already-running process. On this XPS, the shared server and its updater were found with the old `192.168.1.82:20170` HTTP proxy in their environments. Deleting saved sessions does not change that environment.

After all active Codex work has finished, run the following in a zsh shell that has loaded the function above. Stopping the shared daemon can interrupt other clients:

```zsh
codex app-server daemon stop
codex app-server daemon start
```

Check the new server&#39;s environment instead of assuming the restart picked up the new settings:

```bash
ps -eo pid,ppid,args | grep &#39;[c]odex app-server&#39;
# Replace PID with the PID of the managed app-server process.
tr &#39;\0&#39; &#39;\n&#39; &lt; /proc/PID/environ | grep -i &#39;_proxy=&#39;
```

The server&#39;s HTTP and HTTPS proxy values need to point to `10.32.111.107:20170`. If they still show the old address, inspect the updater process shown by `ps` as well. Its inherited environment can outlive the shell, so a server restart alone may not replace it. The stop/start sequence has not yet been verified against the running shared daemon on this machine.

As a temporary workaround, `codex --no-daemon` starts Codex without the shared server and uses the function&#39;s environment. This does not repair the shared daemon. To verify the final setup, start a normal Codex session and send a request after checking the daemon&#39;s environment.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-06-idc-v2raya-proxy-codex/  

