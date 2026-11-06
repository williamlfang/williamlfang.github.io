# docker buildx: the builder had a proxy, the client didn&#39;t


My image build script started failing on its very first line, `FROM python:3.10`,
with `failed to fetch anonymous token ... TLS handshake timeout`. The odd part:
the buildx builder I use is created with a proxy for exactly this reason, and
from another shell the same build worked.

**The token request is not made by the builder. It is made by the `docker buildx`
client in your own shell, using your shell&#39;s proxy variables.** My interactive
zsh exports none, so that one request went direct and timed out. Two `export`
lines in the build script fixed it.

&lt;!--more--&gt;

## The setup

- Ubuntu, kernel 5.15, BuildKit v0.22.0 in a `docker-container` builder named
  `proxy-builder`
- The builder was created with `--driver-opt env.HTTPS_PROXY=...`, so
  `buildkitd` inside its container goes through a proxy
- `run.sh` builds `william-ubuntu-python3:v1.0` with
  `docker buildx build --builder proxy-builder --load` and pushes it to a LAN
  registry at `192.168.1.162:5000`
- Docker Hub is not reachable directly from this network

## The error

```text
 =&gt; ERROR [internal] load metadata for docker.io/library/python:3.10          10.9s
------
Dockerfile:2
--------------------
   1 |     ## error for python3.11 fatal error: longintrepr.h: No such file or directory
   2 | &gt;&gt;&gt; FROM python:3.10
--------------------
ERROR: failed to solve: failed to fetch anonymous token: Get &#34;https://auth.docker.io/token?scope=repository%3Alibrary%2Fpython%3Apull&amp;service=registry.docker.io&#34;: net/http: TLS handshake timeout
```

The step dies after about 10 seconds, which matches Go&#39;s default
`TLSHandshakeTimeout`. The TCP connection opens, but the TLS handshake never
finishes. That&#39;s what a blocked direct connection looks like here.

## Step 1: the builder&#39;s proxy works

The builder&#39;s proxy is visible in `docker buildx inspect`:

```bash
docker buildx inspect proxy-builder | grep -E &#39;Driver Options|Status&#39;
```

```text
Driver Options:        env.HTTPS_PROXY=&#34;socks5://&lt;socks-host&gt;:1080&#34; env.HTTP_PROXY=&#34;socks5://&lt;socks-host&gt;:1080&#34;
Status:                running
```

Both proxies I have reached the exact URL from the error in about a second:

```bash
for p in socks5h://&lt;socks-host&gt;:1080 http://192.168.1.82:20170; do
    curl -sS -o /dev/null -w &#39;%{http_code} %{time_total}s\n&#39; -m 15 -x &#34;$p&#34; \
        &#34;https://auth.docker.io/token?scope=repository%3Alibrary%2Fpython%3Apull&amp;service=registry.docker.io&#34;
done
```

```text
200 1.160909s
200 0.593667s
```

The `buildkitd` log in the builder container showed the same error, so I
assumed the request came from there:

```bash
docker logs --tail 15 buildx_buildkit_proxy-builder0 2&gt;&amp;1 | grep -i timeout
```

```text
level=error msg=&#34;... failed to fetch anonymous token: Get \&#34;https://auth.docker.io/token?...\&#34;: net/http: TLS handshake timeout&#34;
```

### Wrong turn: &#34;it was a blip&#34;

I ran a minimal `FROM python:3.10` build through `proxy-builder`, it passed,
and I put the failure down to a flaky SOCKS proxy. I also re-created the
builder to use the faster HTTP proxy at `192.168.1.82:20170`. The full
`run.sh` then built and pushed fine.

Then I ran `bash ./run.sh` in my normal terminal and got the exact same error.

What I had missed: the shell I tested from was not my normal shell. It
**already had `HTTPS_PROXY` exported**, and my interactive zsh doesn&#39;t. So
every test I ran passed for a reason that didn&#39;t apply to my real terminal.
Re-creating the builder did no harm, but it didn&#39;t fix anything.

## Step 2: reproduce it by removing the client&#39;s proxy

Same builder and same Dockerfile. The only change is whether the
`docker buildx` process itself sees the proxy variables:

```bash
printf &#39;FROM python:3.10\n&#39; &gt; Dockerfile

# client without proxy variables
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy -u ALL_PROXY -u all_proxy \
    docker buildx build --builder proxy-builder --no-cache --pull .

# client with proxy variables
docker buildx build --builder proxy-builder --no-cache --pull .
```

```text
#2 ERROR: failed to authorize: failed to fetch anonymous token: Get &#34;https://auth.docker.io/token?...&#34;: net/http: TLS handshake timeout
...
#4 CACHED
```

The first command fails and the second one passes. And a clean interactive zsh
confirms what my terminal actually exports:

```bash
env -i HOME=$HOME USER=$USER TERM=xterm PATH=/usr/local/bin:/usr/bin:/bin \
    zsh -i -c &#39;env | grep -i proxy || echo &#34;NO PROXY VARS&#34;&#39;
```

```text
GOPROXY=https://goproxy.cn,direct
```

Only `GOPROXY`. My `.zshrc` sets proxies inside a few aliases and functions
(`proxychains4 -q`, `env HTTPS_PROXY=... some-app`) but never exports one for
the whole shell.

## Why the client fetches the token

With BuildKit, registry credentials stay on the client. When the builder needs
to pull from a registry, it asks the client over the build session, and the
client&#39;s auth provider fetches the bearer token from `auth.docker.io`, anonymous
or not. The builder then uses that token to pull the layers through its own
proxy.

So a pull from Docker Hub needs **two** working network paths:

| request | made by | proxy it uses |
|---|---|---|
| `GET auth.docker.io/token` | `docker buildx` client (your shell) | your shell&#39;s `HTTPS_PROXY` |
| manifests and layers from `registry-1.docker.io` | `buildkitd` in the builder container | the builder&#39;s `env.HTTPS_PROXY` |

The error is reported by the builder, which is why I first looked there. But
it is relaying a failure from the client side. Setting
`--driver-opt env.HTTPS_PROXY` only covers the second row.

## The fix

Export the proxy in the build script, so it doesn&#39;t depend on whichever shell
runs it.

`run.sh`:

```bash
#!/bin/bash
set -e

cp /home/william/git/wepy/wepy/requirements.txt .
TAG=william-ubuntu-python3:v1.0
URL=192.168.1.162:5000

## buildx client fetches the docker.io auth token itself, so it needs the proxy too
export HTTP_PROXY=http://192.168.1.82:20170 HTTPS_PROXY=http://192.168.1.82:20170
export NO_PROXY=localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
docker buildx build --builder proxy-builder --load \
    --ssh default \
    --build-arg BUILD_DATE=&#34;$(date -u &#43;&#39;%Y-%m-%dT%H:%M&#39;)&#34; \
    -t &#34;$TAG&#34; .

docker tag &#34;$TAG&#34; &#34;$URL/$TAG&#34;
docker push &#34;$URL/$TAG&#34;
rm -rf ./requirements.txt
```

To check it, run the script from a clean zsh with no proxy set, the same way it
runs from my terminal:

```bash
env -i HOME=$HOME USER=$USER TERM=xterm PATH=/usr/local/bin:/usr/bin:/bin SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
    zsh -i -c &#39;cd ~/git/jobs/dockerfiles/ubuntu &amp;&amp; bash ./run.sh&#39;
```

```text
#2 [internal] load metadata for docker.io/library/python:3.10
...
v1.0: digest: sha256:c5c0bd0128e874fb40481547c05cc90de342f26931e558141c5fcfba92fbd358 size: 5372
```

A few details that matter:

- **The scheme has to match what the port speaks.** My SOCKS port only speaks
  SOCKS5. Pointing an `http://` proxy at it fails right away:

  ```bash
  curl -sS -o /dev/null -m 15 -x http://&lt;socks-host&gt;:1080 https://auth.docker.io/token
  ```

  ```text
  curl: (56) Proxy CONNECT aborted
  ```

  Use `socks5://&lt;socks-host&gt;:1080` for that one. The buildx client is a Go
  program and accepts `socks5://` in `HTTPS_PROXY`; I tested it and the token
  fetch went through. The `192.168.1.82:20170` port speaks HTTP, so `http://`
  is correct there.
- **`NO_PROXY` keeps LAN traffic direct.** The push goes to
  `192.168.1.162:5000`, and you don&#39;t want local addresses going through the
  proxy.
- **Put it in the script, not in `.zshrc`.** Exporting a proxy for the whole
  shell changes every other program you run. The script is the one place that
  needs it.

## Takeaways

1. **With BuildKit, a Docker Hub pull crosses two processes, and both need a
   network path.** The builder proxy covers layer downloads; the client&#39;s
   environment covers the auth token.
2. **The process that reports an error is not always the one that failed.**
   `buildkitd` logged the timeout, but the request that timed out came from
   the client.
3. **Test from the same environment the failure happens in.** My checks passed
   in a shell that already had a proxy exported. A clean `env -i ... zsh -i`
   reproduced the failure on the first try.

Related: [docker buildx]({{&lt; relref &#34;2023-06-29-docker-buildx&#34; &gt;}}),
[docker 配置在pull阶段使用 proxy]({{&lt; relref &#34;2024-07-17-docker-配置在pull阶段使用-proxy&#34; &gt;}})
(that one is the `dockerd` side, for plain `docker pull`).

## References

- [Configure BuildKit: proxy and registry settings](https://docs.docker.com/build/buildkit/configure/)
- [Docker build: use a proxy](https://docs.docker.com/engine/cli/proxy/)
- BuildKit client-side auth provider: [`session/auth/authprovider/authprovider.go`](https://github.com/moby/buildkit/blob/master/session/auth/authprovider/authprovider.go)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-10-16-docker-buildx-anonymous-token-timeout/  

