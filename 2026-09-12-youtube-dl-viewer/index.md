# youtube dl viewer




&lt;!--more--&gt;

```bash
# 遇到报错,需要登录 youtube 获取 cookies

yt-dlp ERROR: [youtube] uqNEthI6Df8: Sign in to confirm you’re not a bot. Use --cookies-from-browser or --cookies for the authentication. See
https://github.com/yt-dlp/yt-dlp/wiki/FAQ#how-do-i-pass-cookies-to-yt-dlp for how to manually pass cookies. Also see
https://github.com/yt-dlp/yt-dlp/wiki/Extractors#exporting-youtube-cookies for tips on effectively exporting YouTube cookies

# 1.安装 chrome 插件: Get cookies.txt LOCALLY: https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc
# 2.打开 youtube 网站并登录, 使用以上插件下载 /youtube-dl/cookies.txt
# 3.在 &#39;Advanced Options&#39; 添加: --cookies /youtube-dl/cookies.txt
# 4.在 docker 安装 deno
rm -rf /root/.deno
apk update
apk add --no-cache deno
# 5.测试
yt-dlp -v \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  &#34;https://www.youtube.com/watch?v=DOyoYgAj-GE&#34;

# 6. 自动下载 cookies.txt
#yt-dlp \
#  --cookies-from-browser chrome \
#  --cookies /youtube-dl/cookies.txt \

#As of 2026, the better cookie-less approach for automated Docker use is to use yt-dlp&#39;s PO Token provider.
#yt-dlp&#39;s current documentation specifically recommends a PO Token provider plugin,
#particularly with the mweb client, rather than manually generating tokens.
yt-dlp \
  --extractor-args &#34;youtube:player_client=android_vr&#34; \
  &#34;https://www.youtube.com/watch?v=uqNEthI6Df8&#34;
# or
yt-dlp \
  --extractor-args &#34;youtube:player_client=web_embedded&#34; \
  &#34;https://www.youtube.com/watch?v=uqNEthI6Df8&#34;
```


# 在 Alpine Docker 中修复 yt-dlp 的 YouTube `n challenge` 与 Deno 错误

本文记录一次在 `youtube-dl-react-viewer` 的 Alpine Linux Docker 容器中，使用 `yt-dlp` 下载 YouTube 视频时遇到的完整排查过程。

## 1. 初始错误

使用 `yt-dlp` 下载 YouTube 视频时，出现：

```text
WARNING: [youtube] n challenge solving failed: Some formats may be missing.
Ensure you have a supported JavaScript runtime and challenge solver script distribution installed.

ERROR: [youtube] The page needs to be reloaded.
```

进一步使用：

```bash
yt-dlp -v \
  --cookies /youtube-dl/cookies.txt \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

可以看到类似：

```text
Optional libraries: ..., yt_dlp_ejs-0.8.0
JS runtimes: none

[youtube] [pot] PO Token Providers: none
[youtube] [jsc] JS Challenge Providers:
  bun (unavailable),
  deno (unavailable),
  node (unavailable),
  quickjs (unavailable)
```

同时日志中已经出现：

```text
[youtube] Found YouTube account cookies
```

这说明：

- `cookies.txt` 已经被正确读取；
- `yt-dlp-ejs` 已安装；
- 真正缺失的是 JavaScript runtime。

对于当前版本的 `yt-dlp`，建议使用 Deno 作为 JavaScript runtime。

---

## 2. 确认 Docker 基础系统

进入容器后：

```bash
cat /etc/os-release
```

输出：

```text
NAME=&#34;Alpine Linux&#34;
ID=alpine
VERSION_ID=3.22.2
PRETTY_NAME=&#34;Alpine Linux v3.22&#34;
```

因此该容器使用的是 Alpine Linux。

Alpine 的包管理器是：

```bash
apk
```

而不是：

```bash
apt
yum
dnf
```

所以安装软件应该使用：

```bash
apk update
apk add --no-cache PACKAGE_NAME
```

---

## 3. 不建议使用 Deno 官方安装脚本

最开始尝试：

```bash
curl -fsSL https://deno.land/install.sh | sh
```

安装得到：

```text
/root/.deno/bin/deno
```

文件虽然存在：

```bash
ls /root/.deno/bin/deno
```

但是执行：

```bash
/root/.deno/bin/deno --version
```

却出现：

```text
sh: /root/.deno/bin/deno: not found
```

这里的 `not found` 并不一定表示文件不存在。

真正的问题通常是：

- Deno 官方安装脚本下载的是 glibc/GNU Linux 二进制；
- Alpine Linux 默认使用 musl libc；
- 二进制所需要的动态加载器不存在；
- shell 最终表现为 `not found`。

可以通过：

```bash
apk add --no-cache file

file /root/.deno/bin/deno
```

进一步确认。

如果输出中包含类似：

```text
interpreter /lib64/ld-linux-x86-64.so.2
```

而 Alpine 使用：

```text
/lib/ld-musl-x86_64.so.1
```

就说明这是 glibc 与 musl 的兼容问题。

---

## 4. 正确做法：直接安装 Alpine 的 Deno

对于 Alpine，最简单可靠的方法是直接安装发行版自带的 Deno：

```bash
apk update
apk add --no-cache deno
```

然后检查：

```bash
which deno
deno --version
```

正常应该类似：

```text
/usr/bin/deno
deno 2.3.1
```

如果 `apk` 找不到 `deno`，检查：

```bash
cat /etc/apk/repositories
```

确保启用了 `community`：

```text
https://dl-cdn.alpinelinux.org/alpine/v3.22/main
https://dl-cdn.alpinelinux.org/alpine/v3.22/community
```

如果没有，可以添加：

```bash
echo &#34;https://dl-cdn.alpinelinux.org/alpine/v3.22/community&#34; &gt;&gt; /etc/apk/repositories

apk update
apk add --no-cache deno
```

---

## 5. 让 yt-dlp 使用 Deno

安装完成后，可以显式指定 Deno：

```bash
yt-dlp -v \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

成功后，调试输出应该从：

```text
JS runtimes: none
```

变成类似：

```text
JS runtimes: deno-2.3.1
```

同时：

```text
JS Challenge Providers: deno
```

也应该变为可用。

---

## 6. 新错误：`Failed getting cwd`

Deno 被正确识别后，又可能出现：

```text
[youtube] [jsc:deno] Solving JS challenges using deno

WARNING: [youtube] [jsc] Error solving n challenge request using &#34;deno&#34; provider:
Error running deno process (returncode: 1):

error: Failed getting cwd.

Caused by:
    No such file or directory (os error 2).
```

这是另一个独立问题。

`cwd` 是：

```text
current working directory
```

也就是当前工作目录。

典型原因是：

1. 当前 shell 位于某个目录；
2. 这个目录后来被删除；
3. shell 仍然保留原来的路径状态；
4. Deno 启动时调用 `getcwd()`；
5. 系统返回 `ENOENT`；
6. Deno 报：

```text
Failed getting cwd
```

例如，当前提示符可能仍然显示：

```text
~/.deno/bin #
```

但此前执行过：

```bash
rm -rf /root/.deno
```

那么 shell 实际上已经处于一个被删除的目录中。

---

## 7. 修复 `Failed getting cwd`

最简单的方法：

```bash
cd /
```

或者：

```bash
cd /tmp
```

或者：

```bash
cd /youtube-dl
```

然后确认：

```bash
pwd
```

例如：

```text
/
```

再测试 Deno：

```bash
deno --version
```

还可以进一步测试：

```bash
echo &#39;console.log(&#34;deno ok&#34;)&#39; | deno run -
```

正常输出：

```text
deno ok
```

---

## 8. 再次测试 yt-dlp

确认当前目录有效后，再运行：

```bash
cd /

yt-dlp -v \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

如果问题解决，应该不再出现：

```text
Failed getting cwd
```

也不应该再因为 Deno 无法运行而出现：

```text
n challenge solving failed
```

日志中应该正常看到：

```text
[youtube] [jsc:deno] Solving JS challenges using deno
```

---

## 9. 下载字幕

如果同时需要下载字幕，可以使用：

```bash
yt-dlp \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  --write-subs \
  --write-auto-subs \
  --sub-langs &#34;en.*,zh-Hans,zh-Hant&#34; \
  --sub-format vtt \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

如果只想查看有哪些字幕：

```bash
yt-dlp \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  --list-subs \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

---

## 10. youtube-dl-react-viewer 的 Override Config

在 `youtube-dl-react-viewer` 中，可以将以下参数加入 Override Config：

```text
--js-runtimes deno:/usr/bin/deno --cookies /youtube-dl/cookies.txt
```

如果同时需要字幕：

```text
--js-runtimes deno:/usr/bin/deno --cookies /youtube-dl/cookies.txt --write-subs --write-auto-subs --sub-langs &#34;en.*,zh-Hans,zh-Hant&#34; --sub-format vtt
```

---

## 11. 最终排查结论

整个问题链可以总结为：

```text
YouTube 下载失败
    ↓
cookies 已正确读取
    ↓
yt-dlp-ejs 已安装
    ↓
JS runtime 缺失
    ↓
安装 Deno
    ↓
官方 Deno glibc 二进制无法在 Alpine musl 上运行
    ↓
改用 apk 安装 Alpine 原生 Deno
    ↓
yt-dlp 正确识别 Deno
    ↓
出现 Failed getting cwd
    ↓
发现当前 shell 所在目录已经被删除
    ↓
cd 到有效目录
    ↓
Deno challenge solver 正常运行
```

---

## 12. 推荐的最终命令

对于 Alpine Docker &#43; `youtube-dl-react-viewer`，推荐：

```bash
apk update
apk add --no-cache deno

cd /

deno --version

yt-dlp -v \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

需要字幕时：

```bash
yt-dlp \
  --js-runtimes deno:/usr/bin/deno \
  --cookies /youtube-dl/cookies.txt \
  --write-subs \
  --write-auto-subs \
  --sub-langs &#34;en.*,zh-Hans,zh-Hant&#34; \
  --sub-format vtt \
  &#34;https://www.youtube.com/watch?v=VIDEO_ID&#34;
```

---

## 13. Docker 持久化建议

需要注意，在正在运行的容器中执行：

```bash
apk add --no-cache deno
```

只会修改当前容器。

如果之后重新创建容器，Deno 可能会丢失。

更可靠的方法是创建自己的 Dockerfile，例如：

```dockerfile
FROM 原来的-youtube-dl-react-viewer-image

RUN apk add --no-cache deno
```

然后重新构建：

```bash
docker build -t youtube-dl-react-viewer-with-deno .
```

这样 Deno 会成为镜像的一部分，不会因为容器重建而丢失。


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-12-youtube-dl-viewer/  

