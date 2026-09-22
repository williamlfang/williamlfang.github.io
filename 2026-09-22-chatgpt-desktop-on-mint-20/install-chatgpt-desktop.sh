#!/usr/bin/env bash
# Install ChatGPT Desktop on Linux Mint 20.x / Ubuntu 20.04 (focal, glibc 2.31).
#
# The stock package is not installable on focal, but not because of an ABI wall:
# several of its dependencies were renamed after focal, and one optional TPM
# module drags in OpenSSL 3. This patches the control member only (the 1.4 GB
# data archive is copied through untouched), installs, and holds.
#
# Run as your normal user -- it calls sudo itself:
#     bash ~/install-chatgpt-desktop.sh
set -euo pipefail

URL="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"
SRC_DEB="${HOME}/Downloads/chatgpt_amd64.deb"

# Proxy wiring for the user-level launcher. Set PROXY="" to wire no proxy.
PROXY="http://192.168.1.82:20170"
BYPASS="<local>;localhost;127.0.0.1;::1;192.168.*;172.16.*;172.1?.*;172.2?.*;10.*"

DOWNLOAD=0 DO_AUDIT=0 DO_TEST=0 DO_DESKTOP=1 ASSUME_YES=0 KEEP=0

usage() {
  cat <<'USAGE'
Usage: install-chatgpt-desktop.sh [options]

  --source PATH   stock .deb to patch      (default: ~/Downloads/chatgpt_amd64.deb)
  --download      re-download the latest stock .deb even if one is present
  --audit         always run the full ELF glibc audit (needs ~1.5 GB of temp
                  space; otherwise it runs only when a declared libc6 bound
                  exceeds this system's glibc)
  --test          launch the extracted tree before installing anything
  --no-desktop    do not write ~/.local/bin/chatgpt-proxy or the .desktop file
  --keep          keep the work directory for inspection
  -y, --yes       do not stop at the dry-run confirmation
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --source)     SRC_DEB="$2"; shift 2 ;;
    --download)   DOWNLOAD=1; shift ;;
    --audit)      DO_AUDIT=1; shift ;;
    --test)       DO_TEST=1; shift ;;
    --no-desktop) DO_DESKTOP=0; shift ;;
    --keep)       KEEP=1; shift ;;
    -y|--yes)     ASSUME_YES=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

die() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "run as your normal user, not root -- the script sudos where it needs to."
[ "$(dpkg --print-architecture)" = "amd64" ] || die "this package is amd64 only."
for t in ar tar xz objdump od dpkg-deb apt-get apt-cache curl sudo; do
  command -v "$t" >/dev/null 2>&1 || die "missing required tool: $t"
done

WORK="$(mktemp -d "${TMPDIR:-/tmp}/chatgpt-focal.XXXXXX")"
cleanup() {
  if [ "$KEEP" -eq 1 ]; then echo "    work dir kept: $WORK"; else rm -rf "$WORK"; fi
}
trap cleanup EXIT

# Every pipeline here is written so the reader consumes all of its input: with
# 'set -o pipefail', a 'head -1' that exits early makes the writer die of SIGPIPE
# and the whole pipeline report failure, intermittently and for no real reason.
SYS_GLIBC="$(ldd --version | sed -n '1s/.*[^0-9.]\([0-9][0-9]*\.[0-9][0-9]*\).*$/\1/p')"
TREE=""          # set once the data archive has been extracted
ELF_MAX="0"
CORE_MAX="0"

# $1 >= $2, version-sorted: the higher of the two sorts last, and equal values
# make either one the tail.
vge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ]; }

# Read the ELF header directly: magic at offset 0, e_machine at offset 18. No
# pipe that a short-circuiting grep could turn into a SIGPIPE under 'pipefail',
# and bundled ARM prebuilds are skipped -- they never load on this machine.
is_elf_amd64() {
  local m
  m="$(od -An -N20 -tx1 "$1" 2>/dev/null | tr -d ' \n' || true)"
  [ "${m:0:8}" = "7f454c46" ] && [ "${m:36:4}" = "3e00" ]
}

apt_has_candidate() {
  local c
  c="$(apt-cache policy "$1" 2>/dev/null | sed -n 's/^ *Candidate: *//p' || true)"
  [ -n "$c" ] && [ "$c" != "(none)" ]
}

extract_tree() {
  [ -n "$TREE" ] && return 0
  echo "    extracting the data archive (about 1.4 GB)"
  mkdir -p "$WORK/x"
  dpkg-deb -x "$SRC_DEB" "$WORK/x"
  TREE="$WORK/x"
}

echo "==> Step 1/8: obtaining the stock package"
if [ "$DOWNLOAD" -eq 1 ] || [ ! -f "$SRC_DEB" ]; then
  mkdir -p "$(dirname "$SRC_DEB")"
  echo "    downloading $URL"
  curl -fsSL --retry 3 -o "$SRC_DEB.part" "$URL" || die "download failed."
  mv "$SRC_DEB.part" "$SRC_DEB"
fi
[ -f "$SRC_DEB" ] || die "package not found: $SRC_DEB"
SRC_DEB="$(readlink -f "$SRC_DEB")"

SRC_VER="$(dpkg-deb -f "$SRC_DEB" Version)"
case "$SRC_VER" in
  *~focal*) die "$SRC_DEB is already patched (version $SRC_VER). Point --source at a stock package." ;;
esac
NEW_VER="${SRC_VER}~focal1"
OUT_DEB="$(dirname "$SRC_DEB")/chatgpt_${NEW_VER}_amd64.deb"
echo "    source : $SRC_DEB"
echo "    sha256 : $(sha256sum "$SRC_DEB" | cut -d' ' -f1)"
echo "    version: $SRC_VER  ->  $NEW_VER"

DEPENDS="$(dpkg-deb -f "$SRC_DEB" Depends)"
split_deps() { printf '%s\n' "$DEPENDS" | tr ',' '\n' | sed 's/^ *//; s/ *$//'; }

echo "==> Step 2/8: which declared dependencies are not installable here"
MISSING=""
while IFS= read -r ent; do
  [ -n "$ent" ] || continue
  ok=0
  # an alternatives group is satisfied if any single alternative has a candidate
  for alt in $(printf '%s' "$ent" | tr '|' '\n' | sed 's/(.*)//' | tr -d ' '); do
    [ -n "$alt" ] || continue
    if apt_has_candidate "$alt"; then ok=1; break; fi
  done
  if [ "$ok" -eq 0 ]; then
    echo "    MISSING: $ent"
    MISSING="${MISSING}${ent}"$'\n'
  fi
done < <(split_deps)
[ -n "$MISSING" ] || echo "    (none -- the stock package may install as-is)"

echo "==> Step 3/8: glibc / libstdc++ audit"
# The highest libc6 bound the package declares. dpkg-shlibdeps unions over every
# ELF in the tree, so one auxiliary binary can set the floor for the whole thing.
LIBC_MAX="$(printf '%s' "$DEPENDS" | tr ',' '\n' \
            | grep -oE 'libc6 \(>= [0-9.]+\)' | grep -oE '[0-9]+\.[0-9]+' \
            | sort -V | tail -1 || true)"
LIBC_MAX="${LIBC_MAX:-0}"
echo "    declared libc6 bound: >= $LIBC_MAX   system glibc: $SYS_GLIBC"

DROP_LIBC_OVERBOUND=0
if ! vge "$SYS_GLIBC" "$LIBC_MAX"; then
  echo "    bound exceeds this system -- auditing the real symbol versions"
  DO_AUDIT=1
fi

if [ "$DO_AUDIT" -eq 1 ]; then
  extract_tree
  ELF_REPORT="$WORK/glibc-report.txt"
  # objdump is static analysis, so no stray LD_LIBRARY_PATH can fake a pass here.
  ( cd "$TREE" && find . -type f | sed 's|^\./||' | while read -r f; do
      is_elf_amd64 "$f" || continue
      v="$(objdump -T "$f" 2>/dev/null | grep -o 'GLIBC_[0-9.]*' | sort -uV | tail -1 || true)"
      [ -n "$v" ] && echo "${v#GLIBC_} $f" || true
    done ) | sort -V > "$ELF_REPORT"
  echo "    highest GLIBC symbol versions found:"
  tail -5 "$ELF_REPORT" | sed 's/^/      /'
  ELF_MAX="$(cut -d' ' -f1 "$ELF_REPORT" | sort -V | tail -1 || true)"
  ELF_MAX="${ELF_MAX:-0}"
  echo "    max GLIBC over $(wc -l < "$ELF_REPORT") x86-64 ELF files: $ELF_MAX"

  # The Electron binary and the libraries beside it are what has to start. Files
  # under resources/ are auxiliary: codex, the CUA agent, the native modules.
  CORE_MAX="$(awk '$2 ~ /^usr\/lib\/chatgpt\/[^\/]+$/ {print $1}' "$ELF_REPORT" \
              | sort -V | tail -1 || true)"
  CORE_MAX="${CORE_MAX:-0}"
  echo "    max GLIBC in the Electron core: $CORE_MAX"
  vge "$SYS_GLIBC" "$CORE_MAX" \
    || die "a real ABI wall: the core needs glibc $CORE_MAX, this system has $SYS_GLIBC."

  if ! vge "$SYS_GLIBC" "$ELF_MAX"; then
    echo "    these auxiliary binaries need more than glibc $SYS_GLIBC and will fail to load:"
    while read -r v f; do
      vge "$SYS_GLIBC" "$v" || echo "      $v  $f"
    done < "$ELF_REPORT"
    echo "    The app itself still starts; whatever feature each of them backs does not."
    if [ "$ASSUME_YES" -ne 1 ]; then
      read -r -p "    Continue anyway? Type yes: " ans
      [ "$ans" = "yes" ] || die "aborted by user."
    fi
  fi
  vge "$SYS_GLIBC" "$LIBC_MAX" || DROP_LIBC_OVERBOUND=1

  CXX_MAX="$(find "$TREE" -type f | while read -r f; do
      is_elf_amd64 "$f" || continue
      objdump -T "$f" 2>/dev/null | grep -o 'GLIBCXX_[0-9.]*' || true
    done | sed 's/GLIBCXX_//' | sort -V | tail -1 || true)"
  CXX_SYS="$(strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 2>/dev/null \
      | grep -o 'GLIBCXX_[0-9.]*' | sed 's/GLIBCXX_//' | sort -V | tail -1 || true)"
  if [ -n "$CXX_MAX" ] && [ -n "$CXX_SYS" ]; then
    echo "    max GLIBCXX needed: $CXX_MAX   system libstdc++6 provides: $CXX_SYS"
    vge "$CXX_SYS" "$CXX_MAX" || echo "    WARNING: the system libstdc++6 looks too old."
  fi

  echo "    ELF files that pull in OpenSSL 3 or the TPM libraries:"
  find "$TREE" -type f | while read -r f; do
    is_elf_amd64 "$f" || continue
    n="$(objdump -p "$f" 2>/dev/null | awk '/NEEDED/{print $2}' \
         | grep -E 'libssl|libcrypto|libtss2' | tr '\n' ' ' || true)"
    [ -n "$n" ] && echo "      ${f#"$TREE"/}: $n" || true
  done
else
  echo "    declared bound is satisfied; skipping the ELF sweep (--audit forces it)"
fi

echo "==> Step 4/8: smoke test"
if [ "$DO_TEST" -eq 1 ]; then
  extract_tree
  echo "    launching the extracted tree -- close the window to continue"
  ( cd "$TREE/usr/lib/chatgpt" \
    && env -u LD_LIBRARY_PATH ./ChatGPT --no-sandbox --user-data-dir="$WORK/cgtest" ) \
    || echo "    (the app exited non-zero)"
else
  echo "    skipped (--test runs the extracted tree before anything is installed)"
fi

echo "==> Step 5/8: rewriting the control member"
mkdir -p "$WORK/ctlx"
( cd "$WORK/ctlx" && ar x "$SRC_DEB" control.tar.xz && tar xf control.tar.xz && rm control.tar.xz )
[ -f "$WORK/ctlx/control" ] || die "no control file in the package."
CTL_MEMBERS="$(cd "$WORK/ctlx" && ls -1)"

# Rename map for the packages Debian/Ubuntu reshuffled after focal: the soname is
# the contract, the package name is not. All three tss2 sonames live in focal's
# libtss2-esys0. libssl3 is dropped outright -- its only consumer is the optional
# TPM-backed device-key module.
map_entry() {
  case "$1" in
    libgdk-pixbuf-2.0-0*) echo "libgdk-pixbuf2.0-0 (>= 2.36.9)" ;;
    libtss2-esys-3.0.2-0*|libtss2-mu*|libtss2-tcti-device*) echo "libtss2-esys0 (>= 2.3.1)" ;;
    *) return 1 ;;
  esac
}

NEW_DEPS=""
add_dep() {
  [ -n "$1" ] || return 0
  case ",${NEW_DEPS}," in *",$1,"*) return 0 ;; esac   # dedupe
  NEW_DEPS="${NEW_DEPS:+$NEW_DEPS,}$1"
}

UNRESOLVED=""
while IFS= read -r ent; do
  [ -n "$ent" ] || continue
  name="$(printf '%s' "$ent" | sed 's/|.*//; s/(.*//' | tr -d ' ')"

  # Dropped whether or not apt can satisfy it. Its only consumer is the optional
  # TPM-backed device-key module, and a candidate here may be a foreign-distro
  # OpenSSL from a long-forgotten third-party repo -- installing that into
  # /usr/lib/x86_64-linux-gnu to load one optional module is a bad trade.
  if [ "$name" = "libssl3" ]; then
    cand="$(apt-cache policy libssl3 2>/dev/null | sed -n 's/^ *Candidate: *//p' || true)"
    if [ -n "$cand" ] && [ "$cand" != "(none)" ]; then
      echo "    dropping           : $ent   (not needed; refusing candidate $cand)"
    else
      echo "    dropping           : $ent   (optional TPM module only)"
    fi
    continue
  fi

  # An overstated libc6 bound: keep only what the audit proved is really needed.
  if [ "$name" = "libc6" ]; then
    b="$(printf '%s' "$ent" | grep -oE '[0-9]+\.[0-9]+' | tail -1 || true)"
    if [ -n "$b" ] && ! vge "$SYS_GLIBC" "$b"; then
      if [ "$DROP_LIBC_OVERBOUND" -eq 1 ]; then
        echo "    dropping overstated: $ent   (audit found $ELF_MAX, core $CORE_MAX)"
        continue
      fi
      die "the libc6 bound $b is unproven; re-run with --audit."
    fi
  fi

  case $'\n'"$MISSING" in
    *$'\n'"$ent"$'\n'*)
      if repl="$(map_entry "$name")"; then
        if [ -n "$repl" ]; then
          echo "    renaming           : $ent  ->  $repl"
        else
          echo "    dropping           : $ent   (optional TPM module only)"
        fi
        add_dep "$repl"
      else
        UNRESOLVED="${UNRESOLVED}      $ent"$'\n'
        add_dep "$ent"
      fi
      continue ;;
  esac
  add_dep "$ent"
done < <(split_deps)

if [ -n "$UNRESOLVED" ]; then
  echo "    WARNING: uninstallable dependencies with no known focal equivalent:"
  printf '%s' "$UNRESOLVED"
  echo "    They were left in place, so the install below will fail. Check them with"
  echo "    'dpkg -S <soname>' and 'ldconfig -p' before dropping or remapping them."
fi

awk -v dep="$NEW_DEPS" -v ver="$NEW_VER" '
  /^Depends:/ { print "Depends: " dep; skip=1; next }
  /^Version:/ { print "Version: " ver; skip=0; next }
  /^[ \t]/    { if (skip) next }
  { skip=0; print }
' "$WORK/ctlx/control" > "$WORK/ctlx/control.new"
mv "$WORK/ctlx/control.new" "$WORK/ctlx/control"

# A .deb is just an ar archive. 'ar r' replaces one member in place and preserves
# its position, so the required debian-binary -> control.tar.xz -> data.tar.xz
# ordering survives and the 1.4 GB payload is never recompressed.
( cd "$WORK/ctlx" && tar cJf control.tar.xz --owner=0 --group=0 $CTL_MEMBERS )
cp -f "$SRC_DEB" "$OUT_DEB"
( cd "$WORK/ctlx" && ar r "$OUT_DEB" control.tar.xz )
dpkg-deb -I "$OUT_DEB" >/dev/null || die "the patched package does not parse."
echo "    wrote $OUT_DEB"

echo "==> Step 6/8: dry run"
set +e
apt-get -s install "$OUT_DEB" > "$WORK/dryrun.txt" 2>&1
DRY_RC=$?
set -e
tail -20 "$WORK/dryrun.txt"
[ "$DRY_RC" -eq 0 ] || echo "    WARNING: the dry run failed (exit $DRY_RC). Do not continue unless you know why."
echo
if [ "$ASSUME_YES" -ne 1 ]; then
  read -r -p "    Nothing removed, nothing extra pulled in? Type yes to continue: " ans
  [ "$ans" = "yes" ] || { echo "Aborted by user. The patched package is at $OUT_DEB"; exit 1; }
fi

echo "==> Step 7/8: installing and holding"
HOLDS="$(apt-mark showhold 2>/dev/null || true)"
case $'\n'"$HOLDS"$'\n' in
  *$'\n'chatgpt$'\n'*) echo "    releasing the existing hold first"; sudo apt-mark unhold chatgpt ;;
esac
sudo apt-get install -y "$OUT_DEB"
# postinst registers OpenAI's own apt source, so without the hold the next
# 'apt upgrade' replaces this package with the stock one and re-breaks it.
sudo apt-mark hold chatgpt
dpkg -s chatgpt | grep -E '^(Package|Version|Status):' | sed 's/^/    /'
HOLDS="$(apt-mark showhold 2>/dev/null || true)"
case $'\n'"$HOLDS"$'\n' in
  *$'\n'chatgpt$'\n'*) echo "    hold confirmed" ;;
  *) echo "    WARNING: hold not applied!" ;;
esac

echo "==> Step 8/8: user-level launcher and desktop entry"
if [ "$DO_DESKTOP" -eq 0 ]; then
  echo "    skipped (--no-desktop)"
else
  mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
  WRAP="$HOME/.local/bin/chatgpt-proxy"
  {
    echo '#!/usr/bin/env bash'
    if [ -n "$PROXY" ]; then
      printf "PROXY='%s'\n" "$(printf '%s' "$PROXY" | sed "s/'/'\\\\''/g")"
      printf "BYPASS='%s'\n" "$(printf '%s' "$BYPASS" | sed "s/'/'\\\\''/g")"
      cat <<'WRAP_PROXY'

export HTTP_PROXY="$PROXY"  HTTPS_PROXY="$PROXY"
export http_proxy="$PROXY"  https_proxy="$PROXY"
export NO_PROXY="localhost,127.0.0.1,::1,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8"
export no_proxy="$NO_PROXY"
WRAP_PROXY
    fi
    cat <<'WRAP_COMMON'

# A conda or /usr/local/gcc14 LD_LIBRARY_PATH leaking in from .zshrc makes the
# bundled native modules bind the wrong libcrypto/libstdc++. Unsetting it is what
# makes a terminal launch and a menu launch resolve libraries identically.
unset LD_LIBRARY_PATH

WRAP_COMMON
    if [ -n "$PROXY" ]; then
      cat <<'WRAP_EXEC'
exec /usr/bin/chatgpt \
  --proxy-server="$PROXY" \
  --proxy-bypass-list="$BYPASS" \
  "$@"
WRAP_EXEC
    else
      echo 'exec /usr/bin/chatgpt "$@"'
    fi
  } > "$WRAP.new"
  chmod 755 "$WRAP.new"
  if [ -f "$WRAP" ] && ! cmp -s "$WRAP" "$WRAP.new"; then
    cp -f "$WRAP" "$WRAP.bak"; echo "    previous launcher saved as $WRAP.bak"
  fi
  mv -f "$WRAP.new" "$WRAP"
  echo "    wrote $WRAP"

  # ~/.local/share is searched before /usr/share, so this shadows the packaged
  # entry, survives reinstalls, and drops its claim on x-scheme-handler/http(s)
  # -- the shipped entry registers ChatGPT as a browser candidate and as a target
  # for any 'xdg-open http://...'.
  DESK="$HOME/.local/share/applications/chatgpt.desktop"
  cat > "$DESK" <<DESKTOP_EOF
[Desktop Entry]
Name=ChatGPT
Comment=ChatGPT by OpenAI${PROXY:+ (via local proxy)}
GenericName=AI assistant
Exec=${WRAP} %U
Icon=chatgpt
Type=Application
StartupNotify=true
StartupWMClass=ChatGPT
Categories=Utility;Development;
MimeType=x-scheme-handler/codex;
DESKTOP_EOF
  echo "    wrote $DESK"
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" || true
  fi
  if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$DESK" && echo "    desktop entry validates" || true
  fi
fi

cat <<'NOTE'

Done. Launch it from your application menu, or run: ~/.local/bin/chatgpt-proxy

What does not work on focal (by design, verified in testing):
  - Remote control / device pairing. It needs
    resources/native/remote-control-device-key.node, the only file in the whole
    package that wants libcrypto.so.3 and the tss2 TPM libraries.
Codex, CUA, chat, file access and MCP all work normally.

The package is held, because postinst registers OpenAI's apt source and the next
upgrade would otherwise restore the unpatched package. Re-run this script after
each upstream release; the control-only rewrite takes about a second plus the
time to copy the file.
NOTE
