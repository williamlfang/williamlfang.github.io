# reasonix: D-Bus依赖



# Reasonix 启动卡死问题排查与修复

## 症状

执行 `reasonix` 命令行后终端卡死，无法正常启动。`reasonix --help` 可以正常输出，但 `reasonix doctor`、交互式会话等操作均会永久挂起。

&lt;!--more--&gt;

## 根因

### 调用链

```
reasonix 启动
  → github.com/zalando/go-keyring 初始化 (Linux: secret_service 后端)
    → 查找 D-Bus session bus ($DBUS_SESSION_BUS_ADDRESS)
      → 未设置，调用 dbus-launch 启动新的 dbus-daemon
        → dbus-daemon 激活 org.freedesktop.secrets (D-Bus activation)
          → 拉起 /usr/bin/gnome-keyring-daemon --start --foreground --components=secrets
            → gnome-keyring-daemon 初始化失败 (权限不足)
              → 陷入 /dev/urandom 读取循环，无法完成初始化
                → go-keyring 等待 Secret Service 响应
                  → reasonix 永久卡死
```

### 关键证据

1. **`DBUS_SESSION_BUS_ADDRESS` 为空**：reasonix 每次启动都需要通过 `dbus-launch` 创建新的 session bus
2. **gnome-keyring-daemon 初始化失败**：strace 捕获到 `gnome-keyring-daemon: insufficient process capabilities, unsecure memory might get used`
3. **大量孤儿 dbus-daemon 进程**：系统中存在 50&#43; 个无人管理的 `dbus-daemon` 进程，每个都是 reasonix 卡死后残留的
4. **验证**：设置 `DBUS_SESSION_BUS_ADDRESS=&#34;unix:path=/dev/null&#34;` 后 reasonix 正常工作

### strace 关键输出

```
write(2, &#34;Activating service name=&#39;org.freedesktop.secrets&#39;...&#34;, ...) = ...
write(2, &#34;gnome-keyring-daemon: insufficient process capabilities, ...&#34;) = ...
# gnome-keyring-daemon 之后持续 poll/read /dev/urandom，无法完成初始化
# reasonix 主线程在 epoll_wait 上等待 Secret Service 响应
```

## 修复方案

### 方案 1：为 reasonix 设置 alias（推荐）

在 `~/.zshrc` 中添加：

```bash
alias reasonix=&#39;DBUS_SESSION_BUS_ADDRESS=&#34;unix:path=/dev/null&#34; reasonix&#39;
```

使配置生效：

```bash
source ~/.zshrc
```

**优点**：只影响 reasonix，不影响其他依赖 D-Bus 的程序。

### 方案 2：设置全局环境变量

在 `~/.zshrc` 中添加：

```bash
export DBUS_SESSION_BUS_ADDRESS=&#34;unix:path=/dev/null&#34;
```

**缺点**：会导致所有使用 D-Bus session bus 的程序（如 `systemctl --user`、`notify-send`、部分桌面应用）的 D-Bus 通信失败。

### 方案 3：正确配置 D-Bus session

如果系统本身支持 D-Bus session bus（例如通过 systemd user session 或桌面环境），确保登录时正确设置 `DBUS_SESSION_BUS_ADDRESS`：

```bash
# 如果使用 systemd
export DBUS_SESSION_BUS_ADDRESS=&#34;unix:path=/run/user/$(id -u)/bus&#34;

# 如果已有 dbus-daemon 运行，查找其地址
# 通过 dbus-daemon 进程的 fd 找到 socket inode，再通过 /proc/net/unix 找到路径
```

但如果 `gnome-keyring-daemon` 本身在当前环境就无法正常工作（如本文档场景），方案 1 仍然是最佳选择。

## 清理孤儿进程

排查修复期间产生的大量孤儿 `dbus-daemon` 可以通过以下命令清理：

```bash
# 查看孤儿 dbus-daemon 数量
ps aux | grep &#34;dbus-daemon.*session&#34; | grep -v grep | wc -l

# 清理当前用户的所有 session dbus-daemon（会在下次登录/sudo 时重新创建需要的）
pkill -u $(whoami) -f &#34;dbus-daemon.*session&#34;
```

## 环境信息

| 项目 | 值 |
|------|-----|
| Reasonix 版本 | desktop-v1.9.1-1467-g0c2efcd5 |
| gnome-keyring 版本 | 3.28.2 |
| go-keyring 版本 | v0.2.8 |
| 系统 | Linux x86_64 (kernel 3.10.0) |
| D-Bus session address | 未设置 |

## 相关文件

- 配置：`~/.reasonix/config.toml`
- 密钥存储：`~/.reasonix/.env`
- D-Bus secrets service：`/usr/share/dbus-1/services/org.freedesktop.secrets.service`
- go-keyring 依赖：`github.com/zalando/go-keyring` (secret_service 后端)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-07-08-reasonix--d-bus%E4%BE%9D%E8%B5%96/  

