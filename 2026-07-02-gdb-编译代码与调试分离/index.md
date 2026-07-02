# gdb 编译代码与调试分离




&lt;!--more--&gt;

# Remote GDB Debugging with C&#43;&#43; — Source Code Strategies

When C&#43;&#43; code is compiled on a dev machine (A) and debugged on a target machine (B),
GDB needs to find matching source files. Here are the options, from best to worst.

## 1. Best: Use `gdbserver` (no source copy to target)

Run a thin `gdbserver` on the target; connect full GDB from the dev machine where sources live.

```bash
# On target machine (machine B):
gdbserver :1234 ./mybinary

# On dev machine (machine A) — where sources &amp; binary live:
gdb ./mybinary
(gdb) target remote target-host:1234
# GDB on machine A has full source access; machine B never needs sources.
```

**Build requirement**: the binary on both sides must match exactly (same build artifact).

## 2. Good: Compile with path remapping, then copy sources anywhere

At **compile time** on machine A, remap the absolute source paths in the DWARF debug info:

```bash
# GCC / Clang:
g&#43;&#43; -g -fdebug-prefix-map=/home/user/project=/opt/src/project ...

# Or older GCC:
g&#43;&#43; -g -fdebug-prefix-map=/home/user/project=.
```

Then on the target machine B, copy sources to the remapped path:

```bash
# On dev machine:
rsync -av ./src/ target:/opt/src/project/
```

GDB on machine B finds them automatically because DWARF now contains `/opt/src/project/...`
instead of `/home/user/project/...`.

## 3. Flexible: Use `set substitute-path` in GDB

If you already built without `-fdebug-prefix-map`, redirect at debug time:

```bash
# Copy sources anywhere on target, e.g. /tmp/src/
scp -r ./src/ target:/tmp/src/

# On target in GDB:
(gdb) set substitute-path /home/user/project /tmp/src
(gdb) list   # now shows source lines
```

Add this to `~/.gdbinit` on the target to make it permanent.

## 4. Quick: Use the `directory` command

Point GDB to the copied source tree:

```bash
scp -r ./src/ target:/tmp/src/

# In GDB on target:
(gdb) directory /tmp/src
```

This adds `/tmp/src` to the source search path. Simpler than `substitute-path` but only works
if the relative directory structure under the DWARF path matches.

## 5. Last resort: Copy sources to the exact same absolute path

```bash
# If DWARF records /home/user/project/src/main.cpp
# Then on target, put it at exactly the same path:
scp -r ./src/ target:/home/user/project/src/
```

Fragile — only works when usernames and paths are identical across machines.

## Summary

| Method | Copy sources to target? | Effort |
|---|---|---|
| `gdbserver` | **No** | Low (best) |
| `-fdebug-prefix-map` at build | Yes (to a fixed path) | Medium |
| `set substitute-path` | Yes (any path) | Low |
| `directory` | Yes (any path) | Low |
| Same absolute path | Yes (exact path) | Low (fragile) |

**Recommendation**: If you control the build, add `-fdebug-prefix-map` to your CMake/Makefile.
If you don&#39;t, use `gdbserver` — it&#39;s the cleanest workflow and avoids source-sync problems entirely.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-07-02-gdb-%E7%BC%96%E8%AF%91%E4%BB%A3%E7%A0%81%E4%B8%8E%E8%B0%83%E8%AF%95%E5%88%86%E7%A6%BB/  

