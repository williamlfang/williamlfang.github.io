#!/usr/bin/env bash
# Install the focal-patched Claude Desktop package on Linux Mint 20.x / Ubuntu 20.04.
# Must be run with sudo:   sudo bash ~/install-claude-desktop.sh
set -euo pipefail

DEB="/home/william/claude-desktop_1.17377.1~focal1_amd64.deb"
EXPECT_SHA="e43a316222ad74e22b68b3cf711f8684d86377cb54fd1401de8fe0bc2ad562d7"

[ "$(id -u)" -eq 0 ] || { echo "ERROR: run with sudo." >&2; exit 1; }
[ -f "$DEB" ] || { echo "ERROR: package not found: $DEB" >&2; exit 1; }

echo "==> Verifying package integrity"
echo "${EXPECT_SHA}  ${DEB}" | sha256sum -c - || { echo "ERROR: checksum mismatch." >&2; exit 1; }

echo "==> Step 1/5: removing the half-installed input-leap package"
if dpkg -l input-leap 2>/dev/null | grep -q '^.[^n ]'; then
  dpkg --remove --force-remove-reinstreq input-leap
else
  echo "    input-leap not present, skipping"
fi

echo "==> Step 2/5: previewing what 'apt-get -f install' would change"
apt-get -f install --simulate
echo
read -r -p "    Does the above look safe? Type yes to continue: " ans
[ "$ans" = "yes" ] || { echo "Aborted by user."; exit 1; }
apt-get -f install -y

echo "==> Step 3/5: installing Claude Desktop"
apt-get install -y "$DEB"

echo "==> Step 4/5: holding the package so apt cannot replace it with the glibc-2.34 build"
apt-mark hold claude-desktop

echo "==> Step 5/5: verification"
dpkg -s claude-desktop | grep -E '^(Package|Version|Status):'
apt-mark showhold | grep -q '^claude-desktop$' \
  && echo "    hold confirmed" || echo "    WARNING: hold not applied!"

cat <<'NOTE'

Done. Launch it from your application menu, or run: claude-desktop

Expected limitations on glibc 2.31 (by design, verified in testing):
  - "Computer control" / computer use is unavailable
  - The Cowork local VM sandbox is unavailable
  - Claude-in-Chrome native messaging is unavailable
Core chat, projects and MCP should work normally.

A harmless error is logged at every startup:
  [error] Failed to load Claude Native ... GLIBC_2.33 not found
The app catches this and continues.
NOTE
