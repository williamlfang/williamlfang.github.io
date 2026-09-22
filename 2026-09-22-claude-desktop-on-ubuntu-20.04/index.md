# Installing Claude Desktop on Ubuntu 20.04 / Mint 20 (glibc 2.31)


Anthropic&#39;s official Claude Desktop `.deb` declares `libc6 (&gt;= 2.34)`, which
means Ubuntu 22.04&#43; / Mint 21&#43;. On Mint 20.3 (focal, glibc 2.31) `apt` refuses
to install it. It turns out that dependency is an overstatement, and the app
runs fine on glibc 2.31 once you know which three files actually need 2.34.

&lt;!--more--&gt;

## The error

```
The following packages have unmet dependencies:
 claude-desktop : Depends: libc6 (&gt;= 2.34) but 2.31-0ubuntu9.16 is to be installed
                  Recommends: qemu-system-x86 but it is not going to be installed
                  Recommends: ovmf but it is not going to be installed
                  Recommends: virtiofsd but it is not installable
E: Unmet dependencies.
```

Confirm what you are on:

```bash
cat /etc/os-release      # Mint 20.3 / UBUNTU_CODENAME=focal
ldd --version | head -1  # ldd (Ubuntu GLIBC 2.31-0ubuntu9.18) 2.31
```

glibc cannot be upgraded in place on focal. Every binary on the system links
against it, and PPA-hacking it will brick the machine. So that route is out.

## Why the AppImage doesn&#39;t help

There is no official AppImage — Anthropic ships only the `.deb` (apt repo, or a
direct download at `claude.com/download`). The community AppImages all
**repackage that same `.deb`**.

More importantly, **AppImage does not bundle glibc**. That is the format&#39;s core
rule: build on the oldest distro you want to support, because glibc is
backward- but not forward-compatible. An AppImage carrying these binaries hits
the identical `GLIBC_2.34 not found`.

## The trick: find out what actually needs 2.34

`dpkg-shlibdeps` computes `Depends:` by taking the **maximum** requirement
across *every* ELF file in the package. One stray binary raises the floor for
the whole thing. So check them individually:

```bash
# grab the package without installing it
curl -sSL -o cd.deb \
  &#34;https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_1.17377.1_amd64.deb&#34;

mkdir x &amp;&amp; dpkg-deb -x cd.deb x

# max GLIBC symbol version required by each ELF file
find x -type f | while read f; do
  head -c4 &#34;$f&#34; 2&gt;/dev/null | grep -q $&#39;\x7fELF&#39; || continue
  v=$(objdump -T &#34;$f&#34; 2&gt;/dev/null | grep -o &#39;GLIBC_[0-9.]*&#39; | sort -uV | tail -1)
  [ -n &#34;$v&#34; ] &amp;&amp; echo &#34;$v  $f&#34;
done | sort -V | tail
```

Result:

| Component | Max glibc | OK on 2.31? |
|---|---|---|
| `claude-desktop` (the Electron binary) | **2.25** | yes |
| bundled `.so` (libffmpeg, libGLESv2, libvulkan, …) | 2.17 | yes |
| `resources/virtiofsd` | 2.34 | no |
| `resources/chrome-native-host` | 2.34 | no |
| `@ant/claude-native/claude-native-binding.node` | 2.33/2.34 | no |

The app itself only needs **2.25**. Three auxiliary binaries drag the
declaration up to 2.34.

## Which symbols, and why it barely matters

```bash
objdump -T x/usr/lib/claude-desktop/resources/virtiofsd \
  | grep &#39;GLIBC_2.3[4-9]&#39; | awk &#39;{print $NF, $(NF-1)}&#39; | sort -u
```

```
dlsym                     GLIBC_2.34
__libc_start_main         GLIBC_2.34
pthread_create            GLIBC_2.34
pthread_join              GLIBC_2.34
pthread_key_create        GLIBC_2.34
pthread_setname_np        GLIBC_2.34
...
```

Every one of those is the well-known **glibc 2.34 libpthread/libdl merge**. In
2.34 upstream folded `libpthread.so.0` and `libdl.so.2` into `libc.so.6` and
re-versioned the symbols. The *functions* all exist on 2.31 — they just live in
`libpthread`/`libdl` under older version tags. It is a symbol-versioning
artifact, not a missing feature.

## Test before installing anything

You can run the extracted tree directly. No root, no dpkg, apt untouched:

```bash
cd x/usr/lib/claude-desktop
./claude-desktop --no-sandbox --user-data-dir=/tmp/cdtest
```

It launches. The only complaint in `/tmp/cdtest/logs/main.log`:

```
[error] Failed to load Claude Native
  Error: libc.so.6: version `GLIBC_2.33&#39; not found (required by claude-native-binding.node)
```

Looking inside `app.asar`, that `require` is wrapped in a `try/catch` that sets
the module to `null` and logs — so the app degrades instead of crashing:

```js
function _a(){
  if(g9!==void 0) return g9;
  try{ g9 = require(&#34;@ant/claude-native&#34;) }
  catch(A){ g9 = null, vDt = A, D.error(&#34;Failed to load Claude Native&#34;, A) }
  ...
}
```

## Repackage the .deb with a corrected dependency

Since nothing gets recompiled, repackaging cannot lower the *real* floor — but
the real floor was never the problem. Only the declaration needs fixing:

```bash
dpkg-deb -R cd.deb build

sed -i \
 -e &#39;s/libc6 (&gt;= 2\.34)/libc6 (&gt;= 2.31)/&#39; \
 -e &#39;s/, virtiofsd//&#39; \
 -e &#39;s/^Version: .*/Version: 1.17377.1~focal1/&#39; \
 build/DEBIAN/control

dpkg-deb -Zgzip -z6 -b build claude-desktop_1.17377.1~focal1_amd64.deb
```

`virtiofsd` is dropped from `Recommends` because it is not packaged for focal at
all. `qemu-system-x86` and `ovmf` do exist there, so they can stay.

### Check the maintainer scripts first

Always read these before repackaging — a failing `postinst` leaves you with a
half-configured package:

```bash
dpkg-deb -e cd.deb ctl/DEBIAN &amp;&amp; less ctl/DEBIAN/postinst
```

This one does two things: writes Anthropic&#39;s apt keyring &#43; sources, and installs
an AppArmor profile. The AppArmor block is guarded by
`[ -f /etc/apparmor.d/abi/4.0 ]`, and focal ships AppArmor 2.13 with no
`abi/4.0`, so it is skipped. Nothing else is risky.

## Install

**Clear any pre-existing broken packages first.** `apt` refuses to do anything
while the dependency tree is broken, and it will blame *your* package for
someone else&#39;s mess. `apt-get -f install` cannot help if the broken package&#39;s
dependencies are unsatisfiable — use `dpkg` directly, which bypasses the
resolver:

```bash
sudo dpkg --remove --force-remove-reinstreq &lt;broken-package&gt;
sudo apt-get -f install
```

Then:

```bash
sudo apt install ./claude-desktop_1.17377.1~focal1_amd64.deb
sudo apt-mark hold claude-desktop
```

**The hold is not optional.** `postinst` re-registers Anthropic&#39;s apt repo, so
the next `apt upgrade` pulls the stock glibc-2.34 build and breaks everything
again. With the hold in place you re-apply the patch manually per release.

## What you lose on glibc 2.31

- **Computer use / &#34;Computer control&#34;** — needs `claude-native`
- **The Cowork local VM sandbox** — logs `yukonSilver not supported` and cleans
  up gracefully; it needs `qemu` &#43; `ovmf` &#43; `virtiofsd` anyway, and `virtiofsd`
  is not in focal
- **Claude-in-Chrome native messaging** — `chrome-native-host` won&#39;t start

Core chat, projects and MCP work normally.

## Bonus: routing it through a proxy

An Electron app launched from the desktop menu inherits **neither** your shell&#39;s
proxy variables (those live in `.zshrc`, interactive shells only) nor the GNOME
proxy setting if `org.gnome.system.proxy mode` is `&#39;none&#39;`. Check with:

```bash
gsettings get org.gnome.system.proxy mode
```

You need both the env vars (for the Claude Code CLI and SSH subprocesses the app
spawns) and Chromium&#39;s `--proxy-server` flag (for the Electron network stack) —
they are separate code paths. A wrapper is the clean way, because `;`, `&lt;` and
`&gt;` are **reserved characters in a `.desktop` `Exec=` line** and will fail
`desktop-file-validate`.

`~/.local/bin/claude-desktop-proxy`:

```bash
#!/usr/bin/env bash
PROXY=&#34;http://192.168.1.82:20170&#34;
BYPASS=&#34;&lt;local&gt;;localhost;127.0.0.1;::1;192.168.*;172.16.*;172.1?.*;172.2?.*;10.*&#34;

export HTTP_PROXY=&#34;$PROXY&#34;  HTTPS_PROXY=&#34;$PROXY&#34;
export http_proxy=&#34;$PROXY&#34;  https_proxy=&#34;$PROXY&#34;
export NO_PROXY=&#34;localhost,127.0.0.1,::1,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8&#34;
export no_proxy=&#34;$NO_PROXY&#34;

exec /usr/bin/claude-desktop \
  --proxy-server=&#34;$PROXY&#34; \
  --proxy-bypass-list=&#34;$BYPASS&#34; \
  &#34;$@&#34;
```

The bypass list matters: without it Chromium pushes your Docker bridge networks
(`172.17–172.28.*`) and LAN traffic through the proxy too.

Then shadow the packaged launcher with a user-level copy. `XDG_DATA_HOME`
(`~/.local/share`) is searched before everything in `XDG_DATA_DIRS`, so this
wins over `/usr/share/applications/` and survives reinstalls — no root needed.

`~/.local/share/applications/claude-desktop.desktop`:

```ini
[Desktop Entry]
Name=Claude
Comment=Desktop application for Claude.ai (via local proxy)
Exec=/home/william/.local/bin/claude-desktop-proxy %U
Icon=claude-desktop
Type=Application
StartupNotify=true
StartupWMClass=claude-desktop
Categories=Utility;Development;
MimeType=x-scheme-handler/claude;
Actions=NewChat;NewCode;

[Desktop Action NewChat]
Name=New chat
Exec=/home/william/.local/bin/claude-desktop-proxy claude://claude.ai/new

[Desktop Action NewCode]
Name=New Claude Code session
Exec=/home/william/.local/bin/claude-desktop-proxy claude://code/new
```

```bash
update-desktop-database ~/.local/share/applications
```

Measured difference on my machine, from `[startup-perf]` in `main.log`:

| | `did_finish_load` | `dom_ready` |
|---|---|---|
| No proxy | 1570 ms | 10227 ms |
| Via proxy | 1241 ms | **2536 ms** |

## Launching

Search **Claude** in the application menu (the entry is `Name=Claude`), or run
`claude-desktop-proxy` from a terminal. Avoid calling `claude-desktop`
directly — that skips the `--proxy-server` flag.

## Two harmless errors

```
[error] Failed to load Claude Native ... GLIBC_2.33 not found
[error] [EventLogging] POST threw: net::ERR_FAILED
```

The first is the known limitation. The second is telemetry/Sentry being blocked.
Neither affects the app.

## Takeaway

When a `.deb` refuses to install over `libc6 (&gt;= X)`, don&#39;t reach for
`--force-depends` — the binary would abort at launch and leave a broken package
behind. Audit the package with `objdump -T` first. If the high requirement comes
from optional components, and especially if the symbols are just the glibc 2.34
`libpthread`/`libdl` merge, the application itself may run perfectly well on
your older system. Extract and run it before installing anything.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-22-claude-desktop-on-ubuntu-20.04/  

