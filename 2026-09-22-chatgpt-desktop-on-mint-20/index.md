# Installing ChatGPT Desktop on Mint 20 / Ubuntu 20.04 — when the blocker isn&#39;t glibc


OpenAI shipped an official ChatGPT Desktop for Linux in August 2026 (preview),
supporting Ubuntu 24.04/26.04, Debian 13, Fedora 43/44 and Arch. Mint 20.3
(focal, glibc 2.31) is nowhere on that list, so I expected a rerun of the
[Claude Desktop surgery]({{&lt; relref &#34;2026-09-22-claude-desktop-on-ubuntu-20.04&#34; &gt;}}).

It wasn&#39;t. The glibc floor was fine all along — the package is blocked by three
**library renames** and one optional TPM module. The fix is smaller, and the
audit is worth showing because the conclusion is the opposite of last time.

&lt;!--more--&gt;

## Start by reading the control file

Before extracting a single byte, look at what the package actually claims:

```bash
curl -sSL -o chatgpt_amd64.deb \
  &#34;https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb&#34;

dpkg-deb -I chatgpt_amd64.deb
```

The interesting line:

```
Depends: ..., libc6 (&gt;= 2.30), ..., libssl3 (&gt;= 3.0.0), libstdc&#43;&#43;6 (&gt;= 9),
 libtss2-esys-3.0.2-0 (&gt;= 2.3.1), libtss2-mu0 (&gt;= 3.0.1) | libtss2-mu-4.0.1-0t64 (&gt;= 3.0.1),
 libtss2-tcti-device0 (&gt;= 3.0.1), ...
```

`libc6 (&gt;= 2.30)`. **2.30.** Focal has 2.31.

That single number changes the whole shape of the problem. Last time
`dpkg-shlibdeps` had computed `&gt;= 2.34` and the entire exercise was proving the
declaration was an overstatement. Here the declaration is honest and already
satisfied. Whatever is breaking, it isn&#39;t libc.

## Verify it anyway

Trusting a `Depends:` line is how you end up with a half-configured package. Same
audit as last time — max GLIBC symbol version across every ELF file:

```bash
mkdir x &amp;&amp; dpkg-deb -x chatgpt_amd64.deb x

find x -type f | while read f; do
  head -c4 &#34;$f&#34; 2&gt;/dev/null | grep -q $&#39;\x7fELF&#39; || continue
  v=$(objdump -T &#34;$f&#34; 2&gt;/dev/null | grep -o &#39;GLIBC_[0-9.]*&#39; | sort -uV | tail -1)
  [ -n &#34;$v&#34; ] &amp;&amp; echo &#34;$v  $f&#34;
done | sort -V | tail
```

45 ELF files. The top of the list:

| Component | Max glibc | OK on 2.31? |
|---|---|---|
| `sky_linux_x64` (the CUA agent binary) | **2.30** | yes |
| `resources/cua_node/bin/node` | 2.28 | yes |
| `ChatGPT` (the Electron binary) | 2.25 | yes |
| `libvk_swiftshader.so`, `browser_crashpad_handler` | 2.17 | yes |
| `libEGL.so`, `libGLESv2.so`, `libvulkan.so.1` | 2.16 | yes |

Nothing above 2.30. Max `GLIBCXX` is 3.4.26, and focal&#39;s `libstdc&#43;&#43;6` is at
13.1.0 (GLIBCXX 3.4.31) here, so C&#43;&#43; is clear too.

A handful of files report no GLIBC symbols at all — `resources/codex`,
`resources/rg`, `tectonic` — those are statically linked Rust binaries. They
don&#39;t care what your libc is.

## So what *is* blocking it?

```bash
apt-get -s install ./chatgpt_amd64.deb
```

```
chatgpt : Depends: libgdk-pixbuf-2.0-0 (&gt;= 2.36.9) but it is not installable
```

apt reports these one at a time, which is tedious. Check all of them at once:

```bash
for p in $(dpkg-deb -f chatgpt_amd64.deb Depends | tr &#39;,&#39; &#39;\n&#39; \
           | sed &#39;s/|.*//; s/(.*)//&#39; | tr -d &#39; &#39;); do
  apt-cache policy &#34;$p&#34; 2&gt;/dev/null | grep -q &#39;Candidate:&#39; || echo &#34;MISSING: $p&#34;
done
```

Three tss2 packages, plus `libgdk-pixbuf-2.0-0`, plus `libssl3`. And here is the
thing worth internalising:

| Declared | Reality on focal |
|---|---|
| `libgdk-pixbuf-2.0-0` | renamed upstream; focal ships `libgdk-pixbuf2.0-0` |
| `libtss2-esys-3.0.2-0` | soname `libtss2-esys.so.0` is in `libtss2-esys0` |
| `libtss2-mu0` | soname `libtss2-mu.so.0` — **also** in `libtss2-esys0` |
| `libtss2-tcti-device0` | soname `libtss2-tcti-device.so.0` — **also** in `libtss2-esys0` |
| `libssl3 (&gt;= 3.0.0)` | genuinely absent; focal has OpenSSL 1.1 |

Four of the five are pure packaging archaeology. Debian split `libtss2-esys0`
into per-soname packages after focal, and renamed gdk-pixbuf&#39;s runtime package.
The *files* have been sitting on the system the whole time:

```bash
$ dpkg -S libtss2 | sort -u
libtss2-esys0: /usr/lib/x86_64-linux-gnu/libtss2-esys.so.0
libtss2-esys0: /usr/lib/x86_64-linux-gnu/libtss2-mu.so.0
libtss2-esys0: /usr/lib/x86_64-linux-gnu/libtss2-tcti-device.so.0
...
```

## The one real missing library

`libssl3` is the only genuine absence. Find out who wants it:

```bash
find x -type f | while read f; do
  head -c4 &#34;$f&#34; 2&gt;/dev/null | grep -q $&#39;\x7fELF&#39; || continue
  n=$(objdump -p &#34;$f&#34; 2&gt;/dev/null | awk &#39;/NEEDED/{print $2}&#39; \
      | grep -E &#39;libssl|libcrypto|libtss2&#39;)
  [ -n &#34;$n&#34; ] &amp;&amp; echo &#34;=== $f&#34; &amp;&amp; echo &#34;$n&#34;
done
```

Exactly one hit, out of 45:

```
=== x/usr/lib/chatgpt/resources/native/remote-control-device-key.node
libtss2-esys.so.0
libtss2-mu.so.0
libtss2-tcti-device.so.0
libcrypto.so.3
```

One optional native module — the TPM-backed device key used for remote-control
pairing — is the sole consumer of `libcrypto.so.3` *and* of all three tss2 libs.
Different mechanism from last time, identical moral: **`dpkg-shlibdeps` takes the
union over every ELF in the tree**, so one auxiliary binary sets the floor for a
1.4 GB package.

Note it needs `libcrypto.so.3`, not `libssl.so.3`. The declared `libssl3`
dependency is the package that happens to ship both.

## Don&#39;t be tempted by a stray libssl3

`apt-cache policy libssl3` surprised me:

```
libssl3:
  Candidate: 3.2.4-0deepin1
```

A Deepin-built OpenSSL 3, from a `deepin-wine` repo I&#39;d added years ago and
forgotten. It would probably have satisfied the dependency. Installing a
foreign-distro OpenSSL into `/usr/lib/x86_64-linux-gnu` to make one optional
telemetry-adjacent module load is a terrible trade — and `[trusted=yes]` on that
repo means no signature check either. Drop the dependency instead.

## Test before installing anything

Run the extracted tree directly. No root, no dpkg, apt untouched:

```bash
cd x/usr/lib/chatgpt
env -u LD_LIBRARY_PATH ./ChatGPT --no-sandbox --user-data-dir=/tmp/cgtest
```

It launches, renders, reaches `chatgpt.com` and mounts the renderer in ~3.6 s.
No `GLIBC_` errors, no missing-symbol aborts. The TPM module simply never gets
required at startup.

### Why `env -u LD_LIBRARY_PATH` matters

That flag isn&#39;t decoration. My `.zshrc` exports a long `LD_LIBRARY_PATH`
covering `/usr/local/gcc14/lib64`, `~/miniconda3/lib` and more. With it set:

```bash
$ ldd resources/native/remote-control-device-key.node
libcrypto.so.3 =&gt; /home/william/miniconda3/lib/libcrypto.so.3
libstdc&#43;&#43;.so.6 =&gt; /usr/local/gcc14/lib64/libstdc&#43;&#43;.so.6
```

Conda&#39;s OpenSSL 3 &#34;satisfies&#34; the missing library, and gcc14&#39;s libstdc&#43;&#43; shadows
the system one. That is a *fake pass*: an app launched from the Cinnamon menu
inherits none of it, because `.zshrc` only runs for interactive shells. Audit
in the same environment the app will actually run in, or you will conclude
something works and then watch it fail from the menu.

## Patch the control file only

Last time I used `dpkg-deb -R` / `dpkg-deb -b`, which rebuilds the data archive.
Here the payload is 399 MB compressed and 1.4 GB installed — recompressing it to
change five lines of text is pointless. A `.deb` is just an `ar` archive of three
members, so replace the control member in place and leave `data.tar.xz` alone:

```bash
mkdir ctlx &amp;&amp; cd ctlx
ar x ../chatgpt_amd64.deb control.tar.xz
tar xf control.tar.xz &amp;&amp; rm control.tar.xz

sed -i \
 -e &#39;s/, libssl3 (&gt;= 3\.0\.0)//&#39; \
 -e &#39;s/libtss2-esys-3\.0\.2-0 (&gt;= 2\.3\.1)/libtss2-esys0 (&gt;= 2.3.1)/&#39; \
 -e &#39;s/, libtss2-mu0 (&gt;= 3\.0\.1) | libtss2-mu-4\.0\.1-0t64 (&gt;= 3\.0\.1)//&#39; \
 -e &#39;s/, libtss2-tcti-device0 (&gt;= 3\.0\.1)//&#39; \
 -e &#39;s/libgdk-pixbuf-2\.0-0 (&gt;= 2\.36\.9)/libgdk-pixbuf2.0-0 (&gt;= 2.36.9)/&#39; \
 -e &#39;s/^Version: .*/Version: 26.915.31945~focal1/&#39; \
 control

tar cJf control.tar.xz --owner=0 --group=0 \
  control conffiles postinst postrm prerm md5sums

cp ../chatgpt_amd64.deb ../chatgpt_26.915.31945~focal1_amd64.deb
ar r ../chatgpt_26.915.31945~focal1_amd64.deb control.tar.xz
```

`ar r` replaces a member while preserving its position, so the required
`debian-binary` → `control.tar.xz` → `data.tar.xz` ordering survives. The whole
repack takes about a second instead of several minutes.

The three tss2 entries collapse onto the same package, so dedupe the result —
apt tolerates a repeated dependency, but it looks like a mistake:

```bash
dpkg-deb -f ../chatgpt_26.915.31945~focal1_amd64.deb Depends | tr &#39;,&#39; &#39;\n&#39; | grep tss2
```

Always dry-run before committing:

```bash
apt-get -s install ./chatgpt_26.915.31945~focal1_amd64.deb
# 0 upgraded, 1 newly installed, 0 to remove
```

No pulled-in extras, no held packages. That&#39;s the signal you want.

## Check the maintainer scripts

```bash
dpkg-deb -e chatgpt_amd64.deb ctl &amp;&amp; less ctl/postinst
```

Two jobs: install OpenAI&#39;s signing key &#43; a deb822 `.sources` file, and handle
AppArmor. The AppArmor branch is the one to read:

```sh
if test -f /etc/apparmor.d/abi/4.0; then
  ... apparmor_parser -r -W -T /etc/apparmor.d/chatgpt
elif command -v apparmor_parser &gt;/dev/null 2&gt;&amp;1 &amp;&amp; ...; then
  mkdir -p /etc/apparmor.d/disable
  ln -s &#34;.././chatgpt&#34; &#34;/etc/apparmor.d/disable/chatgpt&#34;
fi
```

Focal ships AppArmor 2.13 with no `abi/4.0`, so it takes the `elif` and
*disables* the profile by symlink rather than trying to load a 4.0-syntax profile
that would fail. Well-behaved. Nothing here bites on focal.

## Install and hold

```bash
sudo apt install ./chatgpt_26.915.31945~focal1_amd64.deb
sudo apt-mark hold chatgpt
```

**The hold is not optional**, for the same reason as last time: `postinst`
registers

```
URIs: https://persistent.oaistatic.com/codex-app-prod/linux/deb
Suites: stable
```

so the next `apt upgrade` happily replaces your patched package with the stock
one and re-breaks the dependency tree. With the hold you re-apply the patch per
release — which takes about thirty seconds now that it&#39;s a control-only rewrite.

## The .desktop wants to be your browser

Read the shipped entry before you let it register:

```ini
Exec=chatgpt %U
MimeType=x-scheme-handler/codex;x-scheme-handler/http;x-scheme-handler/https;text/csv;...
```

It claims `x-scheme-handler/http` and `https` — which makes ChatGPT a candidate
default browser in Cinnamon&#39;s preferred-application list, and a target for any
`xdg-open http://...` call. Maybe you want that. I didn&#39;t.

Since `XDG_DATA_HOME` (`~/.local/share`) is searched before `XDG_DATA_DIRS`, a
user-level copy shadows the packaged one, survives reinstalls, and needs no root
— the same trick as last time, now doing double duty: proxy wiring *and*
trimming the MIME claims.

`~/.local/bin/chatgpt-proxy`:

```bash
#!/usr/bin/env bash
PROXY=&#34;http://192.168.1.82:20170&#34;
BYPASS=&#34;&lt;local&gt;;localhost;127.0.0.1;::1;192.168.*;172.16.*;172.1?.*;172.2?.*;10.*&#34;

export HTTP_PROXY=&#34;$PROXY&#34;  HTTPS_PROXY=&#34;$PROXY&#34;
export http_proxy=&#34;$PROXY&#34;  https_proxy=&#34;$PROXY&#34;
export NO_PROXY=&#34;localhost,127.0.0.1,::1,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8&#34;
export no_proxy=&#34;$NO_PROXY&#34;

# conda / gcc14 paths leaking from .zshrc bind the wrong libcrypto &#43; libstdc&#43;&#43;
unset LD_LIBRARY_PATH

exec /usr/bin/chatgpt \
  --proxy-server=&#34;$PROXY&#34; \
  --proxy-bypass-list=&#34;$BYPASS&#34; \
  &#34;$@&#34;
```

The `unset` is the new part, and it&#39;s the important one. It guarantees a menu
launch and a terminal launch resolve libraries identically — otherwise the app
binds conda&#39;s OpenSSL from your shell and the system&#39;s from the menu, and you get
bugs that &#34;only happen sometimes&#34;.

`~/.local/share/applications/chatgpt.desktop`:

```ini
[Desktop Entry]
Name=ChatGPT
Comment=ChatGPT by OpenAI (via local proxy)
GenericName=AI assistant
Exec=/home/william/.local/bin/chatgpt-proxy %U
Icon=chatgpt
Type=Application
StartupNotify=true
StartupWMClass=Chatgpt
Categories=Utility;Development;
MimeType=x-scheme-handler/codex;
```

```bash
update-desktop-database ~/.local/share/applications
desktop-file-validate ~/.local/share/applications/chatgpt.desktop
```

Get `StartupWMClass` from the running app rather than guessing it — I first wrote
`ChatGPT` and the taskbar showed an unmatched generic icon:

```bash
$ xprop WM_CLASS   # then click the window
WM_CLASS(STRING) = &#34;chatgpt (/home/william/.config/Codex)&#34;, &#34;Chatgpt&#34;
```

The second member of the pair is what `StartupWMClass` has to match: `Chatgpt`.

A terminal `chatgpt` still reaches `/usr/bin/chatgpt` and bypasses all of this,
so shadow it too — `~/.local/bin` comes first on my `PATH`:

```bash
ln -sfn ~/.local/bin/chatgpt-proxy ~/.local/bin/chatgpt
```

Note `/usr/bin/chatgpt` is itself a symlink to `../lib/chatgpt/codex-launcher`,
a two-line shell script that resolves its own path and execs `ChatGPT`. Pointing
the wrapper at `/usr/bin/chatgpt` is fine and survives updates.

## What you lose

- **Remote control / device pairing** — needs `remote-control-device-key.node`,
  which needs `libcrypto.so.3`

That&#39;s it. Codex, CUA, chat, file access and MCP all work. Considerably better
than the Claude Desktop outcome, where computer-use, the Cowork VM and Chrome
native messaging all fell over.

## Troubleshooting: it opens, but it isn&#39;t connected

This is the failure I actually hit, and the wrapper was innocent. One command
settles it — the app talks to the proxy or it doesn&#39;t:

```bash
ss -tnp | grep ChatGPT | grep -c 20170
```

A healthy session shows a dozen or more established connections to the proxy
port. Zero — or no matching process at all — means something upstream of the
proxy went wrong. Three candidates, in the order they cost me time:

### 1. `$http_proxy` is not a proxy setting

```bash
$ gsettings get org.gnome.system.proxy mode
&#39;none&#39;
```

Chromium on Cinnamon reads its proxy configuration from GSettings, not from the
environment. Every `HTTP_PROXY` export in my `.zshrc` is invisible to it. Without
an explicit `--proxy-server` the app goes direct, and direct is blocked — so the
env exports in the wrapper are there for the bundled Node/`codex` child
processes, and the `--proxy-server` flag is what actually moves the Electron
traffic. Both are load-bearing, for different consumers.

If you would rather fix it once for every Electron app on the machine:

```bash
gsettings set org.gnome.system.proxy mode &#39;manual&#39;
gsettings set org.gnome.system.proxy.http  host &#39;192.168.1.82&#39;
gsettings set org.gnome.system.proxy.http  port 20170
gsettings set org.gnome.system.proxy.https host &#39;192.168.1.82&#39;
gsettings set org.gnome.system.proxy.https port 20170
```

### 2. `chatgpt` was not the app I thought it was

```bash
$ type chatgpt
chatgpt is a shell function from /home/william/.zshrc
```

The function predated the official package and pointed at
`/snap/bin/chatgpt-desktop-client` — an unrelated third-party snap (v1.1.1) I had
installed back when there was no Linux build. Typing `chatgpt` in a terminal
launched *that*, with its own empty session, and of course it wasn&#39;t connected.
The official app was never involved.

Check `type`/`command -v` before drawing any conclusion about &#34;the app&#34;. A name
that has been on your `PATH` for a year is not evidence about a package you
installed this morning.

### 3. A stale instance swallows your flags

Electron enforces single-instance through `~/.config/Codex/SingletonLock`. If a
proxy-less instance is already running, launching the wrapper just focuses the
existing window and discards its arguments entirely. Check before testing:

```bash
pgrep -af &#39;lib/chatgpt/ChatGPT --proxy-server&#39;
```

### A trap I didn&#39;t fall into, but nearly

My `.zshrc` also had a helper that &#34;added&#34; the proxy on top of the wrapper:

```bash
chatgpt.app() {
    ~/.local/bin/chatgpt-proxy --proxy-server=&#34;socks5://192.168.1.82:20170&#34;
}
```

The wrapper already passes `--proxy-server=http://...`, so the process gets the
switch twice, and **Chromium keeps the last occurrence of a command-line switch,
not the first.** Proved by appending a deliberately dead
`--proxy-server=socks5://127.0.0.1:9`, which produced **0** sockets to the proxy
— the working flag had been thrown away.

Here it happened to be harmless: 20170 is a mixed port that answers HTTP proxy
*and* SOCKS5, so the override landed on the same working endpoint.

```bash
$ curl -so /dev/null -w &#39;%{http_code}\n&#39; --socks5-hostname 192.168.1.82:20170 https://chatgpt.com
403
$ curl -so /dev/null -w &#39;%{http_code}\n&#39; -x http://192.168.1.82:20170 https://chatgpt.com
403
```

(403 from Cloudflare to a bare `curl` still means the request got there.) Change
that port to an HTTP-only proxy and the same line breaks the app with no
diagnostic beyond &#34;not connected&#34;. Don&#39;t layer proxy flags — set them in one
place, which here is the wrapper.

### A red herring in the log

This line shows up in a perfectly healthy session:

```
remote_connections.connection_state_changed hostId=durable state=disconnected
```

That is the remote-control pairing that needs `remote-control-device-key.node`
— the one thing we knowingly gave up. `hostId=local` reaching `state=connected`,
and `[chatgpt-account-lookup] ... result=succeeded`, are the lines that tell you
the network is fine.

## Takeaway

Last time the lesson was *don&#39;t trust an inflated `libc6` bound — audit it*.
This time the bound was accurate and the lesson is the mirror image: **an
uninstallable `.deb` on an old release is usually not an ABI problem at all.**

Before assuming your glibc is too old, ask which of these you actually have:

1. **A renamed package.** Debian/Ubuntu reshuffle runtime package names between
   releases (`libgdk-pixbuf-2.0-0`, the tss2 split, the `t64` transition). The
   soname is the contract; the package name is not. Check with
   `dpkg -S` and `ldconfig -p` before believing anything is missing.
2. **One optional component setting the floor.** `dpkg-shlibdeps` unions over
   every ELF file. Find the outlier with `objdump -p | grep NEEDED`.
3. **An actual ABI wall.** Rare, and `objdump -T` will prove it in one command.

And run your audit with a clean environment. A stray `LD_LIBRARY_PATH` will
cheerfully tell you everything resolves, right up until you launch from the
application menu.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-22-chatgpt-desktop-on-mint-20/  

