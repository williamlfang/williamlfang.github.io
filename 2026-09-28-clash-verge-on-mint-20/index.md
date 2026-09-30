# Installing Clash Verge Rev on Ubuntu 20.04 / Mint 20 — and upgrading its mihomo core


[Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) is a
desktop GUI for the [mihomo](https://github.com/MetaCubeX/mihomo) proxy core
(formerly Clash Meta). It is the maintained fork of the original Clash Verge,
which was abandoned in 2023. If a tutorial tells you to use `zzzgydi/clash-verge`,
skip it.

On a modern Ubuntu, installing it takes one command. On my Mint 20.3 (focal,
glibc 2.31), the latest `.deb` would not install, and the failed attempt left apt
in a broken state. Unlike [Claude Desktop]({{&lt; relref &#34;2026-09-22-claude-desktop-on-ubuntu-20.04&#34; &gt;}})
and [ChatGPT Desktop]({{&lt; relref &#34;2026-09-22-chatgpt-desktop-on-mint-20&#34; &gt;}}),
there is no clean way to patch around it this time. The practical fix is to run
the last 1.x GUI with an up-to-date core.

&lt;!--more--&gt;

## Which version can you run?

Clash Verge Rev 2.x is built on Tauri 2 and needs two things from the OS:

| Requirement               | Ubuntu 22.04&#43; / Mint 21&#43; | Ubuntu 20.04 / Mint 20 |
|---------------------------|--------------------------|------------------------|
| glibc 2.35 or newer       | ✅                       | ❌ (2.31)              |
| `libwebkit2gtk-4.1`       | ✅                       | ❌ (only 4.0)          |

Check your system:

```bash
cat /etc/os-release | head -4       # distro and version
uname -m                            # x86_64 → amd64, aarch64 → arm64
ldd --version | head -1             # glibc version
apt-cache policy libwebkit2gtk-4.1-0 | head -3
```

On Mint 20.3:

```
ldd (Ubuntu GLIBC 2.31-0ubuntu9.18) 2.31
libwebkit2gtk-4.1-0:
  Installed: (none)
  Candidate: (none)
```

- **glibc ≥ 2.35 and a 4.1 candidate exists:** install the latest 2.x (see
  the next section).
- **Otherwise:** install **v1.7.7**, the last 1.x release.

Missing webkit 4.1 isn&#39;t the only problem. The 2.x binary itself needs newer
glibc symbols:

```bash
dpkg-deb -x Clash.Verge_2.5.6_amd64.deb v2
objdump -T v2/usr/bin/clash-verge | grep -oE &#39;GLIBC_[0-9.]&#43;&#39; | sort -uV | tail -3
```

```
GLIBC_2.33
GLIBC_2.34
GLIBC_2.35
```

glibc is the system C library, and replacing it on its own will break the OS.
The Linux releases come only as `.deb` and `.rpm`, with no AppImage or Flatpak.
So on focal the options are v1.7.7, a container (where System Proxy and TUN
mode work poorly), or building webkit2gtk-4.1 from source. I went with v1.7.7.

## Ubuntu 22.04 and newer: latest 2.x

Download `Clash.Verge_&lt;version&gt;_amd64.deb` from the
[releases page](https://github.com/clash-verge-rev/clash-verge-rev/releases)
and install it with apt so dependencies are resolved:

```bash
cd ~/Downloads
sudo apt install ./Clash.Verge_*_amd64.deb
```

Keep the `./` in front of the filename. Without it, apt searches the
repositories for a package with that name instead of installing the local file.

## Ubuntu 20.04 / Mint 20: v1.7.7

v1.7.7 uses Tauri 1, which depends on `libwebkit2gtk-4.0-37`. focal already has it.

### Clean up a failed 2.x install first

I had already tried the 2.5.6 `.deb`. After that, every apt command showed
this:

```
You might want to run &#39;apt --fix-broken install&#39; to correct these.
The following packages have unmet dependencies:
 clash-verge : Depends: libwebkit2gtk-4.1-0 but it is not installable
E: Unmet dependencies. Try &#39;apt --fix-broken install&#39; with no packages (or specify a solution).
```

This happened even when I was installing the 1.7.7 file. The message names
`clash-verge`, but it refers to the 2.x package already registered in dpkg, not
the file on the command line:

```bash
dpkg-query -W -f=&#39;${Package} ${Version} ${Status}\n&#39; clash-verge
# clash-verge 2.5.6 install ok unpacked   ← unpacked, never configured
```

The package was unpacked but can never be configured, and apt refuses to do
anything else until it&#39;s gone. Remove it:

```bash
sudo dpkg --purge clash-verge
```

`apt --fix-broken install` can&#39;t help here, because the missing dependency
doesn&#39;t exist for focal.

### Install

```bash
cd ~/Downloads
curl -fLO https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v1.7.7/clash-verge_1.7.7_amd64.deb

# confirm it wants webkit 4.0, not 4.1
dpkg-deb -f clash-verge_1.7.7_amd64.deb Depends
# openssl, libayatana-appindicator3-1, libwebkit2gtk-4.0-37, libgtk-3-0

sudo apt install ./clash-verge_1.7.7_amd64.deb
```

The arm64, armhf and i386 builds are on the same
[v1.7.7 release page](https://github.com/clash-verge-rev/clash-verge-rev/releases/tag/v1.7.7).

### Verify

```bash
dpkg-query -W -f=&#39;${Package} ${Version} ${Status}\n&#39; clash-verge
# clash-verge 1.7.7 install ok installed

for b in /usr/bin/clash-verge /usr/bin/verge-mihomo /usr/bin/verge-mihomo-alpha; do
  echo &#34;$b: $(ldd &#34;$b&#34; 2&gt;&amp;1 | grep -c &#39;not found&#39;) missing libs&#34;
done
```

```
/usr/bin/clash-verge: 0 missing libs
/usr/bin/verge-mihomo: 0 missing libs
/usr/bin/verge-mihomo-alpha: 0 missing libs
```

## First-time setup

1. Launch **Clash Verge** from the menu, or run `clash-verge &amp;`.
2. Go to **Profiles**, paste your subscription URL, click **Import**, then
   click the profile to activate it.
3. Go to **Proxies** and pick a node.
4. Go to **Settings** and turn on **System Proxy**. To route *all* traffic,
   including apps that ignore the system proxy, also turn on **TUN Mode**. It
   asks for your password so it can install a helper service.

## Upgrading the mihomo core

v1.7.7 won&#39;t get any more releases, and its bundled core is old:

```bash
verge-mihomo -v
# Mihomo Meta v1.18.7 linux amd64 with go1.22.5 Sun Jul 28 05:47:02 UTC 2024
```

Protocol support, rule features and bug fixes come from the **core**, not the
GUI. The core is a separate binary, `/usr/bin/verge-mihomo`, and mihomo&#39;s
release builds are statically linked Go programs, so the latest one runs fine
on glibc 2.31.

### Pick the right build

mihomo publishes separate amd64 builds for different x86-64 microarchitecture
levels:

```bash
grep -o -m1 -wE &#39;avx2|bmi2&#39; /proc/cpuinfo | sort -u
```

- If both `avx2` and `bmi2` are printed, use **`amd64-v3`**, which is the fastest.
- Otherwise use **`amd64-compatible`**, which runs on any amd64 CPU.

### Download and test before installing

Get the current version number from the
[mihomo releases page](https://github.com/MetaCubeX/mihomo/releases/latest).
It was v1.19.31 when I wrote this:

```bash
cd ~/Downloads
VER=v1.19.31
curl -fL -o mihomo.gz \
  https://github.com/MetaCubeX/mihomo/releases/download/$VER/mihomo-linux-amd64-v3-$VER.gz
gunzip -f mihomo.gz
chmod &#43;x mihomo
mv mihomo verge-mihomo-$VER

./verge-mihomo-$VER -v
file verge-mihomo-$VER
```

```
Mihomo Meta v1.19.31 linux amd64 with go1.26.8 Mon Sep 14 13:20:46 UTC 2026
verge-mihomo-v1.19.31: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
```

If `-v` prints a version, the binary works on this system.

### Replace the old core

```bash
# stop Clash Verge and its core
pkill -f clash-verge; pkill -f verge-mihomo

# back up the old core, install the new one
sudo cp /usr/bin/verge-mihomo /usr/bin/verge-mihomo.bak
sudo install -m 755 ~/Downloads/verge-mihomo-$VER /usr/bin/verge-mihomo

verge-mihomo -v
# Mihomo Meta v1.19.31 ...
```

Reopen Clash Verge, go to **Settings → Clash Core**, and make sure **Mihomo**
is selected, not *Mihomo Alpha*. It should show the new version.

### Caveats

- **Rollback:** `sudo mv /usr/bin/verge-mihomo.bak /usr/bin/verge-mihomo`.
- **Reinstalling the package undoes the upgrade.** Reinstalling or upgrading
  `clash-verge` restores the bundled 1.18.7 core. Run the replace step again
  afterwards.
- **Config compatibility.** A few options changed between mihomo 1.18 and
  1.19. If a profile stops loading after the upgrade, compare the error in the
  Clash Verge logs with the [mihomo docs](https://wiki.metacubex.one/), or roll
  back.
- The alpha core, `/usr/bin/verge-mihomo-alpha`, can be upgraded the same way
  using a build from mihomo&#39;s `Prerelease-Alpha` tag.

## Uninstall

```bash
sudo apt remove clash-verge        # keep config
sudo apt purge clash-verge         # also remove system-level config
rm -rf ~/.local/share/io.github.clash-verge-rev.clash-verge-rev   # profiles and user config
```

## TL;DR

| System                         | What to install                                                  |
|--------------------------------|------------------------------------------------------------------|
| Ubuntu 22.04&#43; / Mint 21&#43;       | Latest 2.x `.deb` via `sudo apt install ./file.deb`              |
| Ubuntu 20.04 / Mint 20         | **v1.7.7**, then replace `/usr/bin/verge-mihomo` with the latest mihomo |
| Half-installed 2.x on focal    | `sudo dpkg --purge clash-verge` first                            |

Standard support for focal has ended. Upgrading to Mint 21 or 22 gets you
security updates and the current Clash Verge. Until then, v1.7.7 with a current
mihomo core works fine.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-28-clash-verge-on-mint-20/  

