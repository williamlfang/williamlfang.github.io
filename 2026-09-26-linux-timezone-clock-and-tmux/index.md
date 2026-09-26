# Linux 时区、系统时间与 tmux 状态栏时间不一致的排查


我把 Linux 的时区设成 `Asia/Tokyo`，又手动设置了系统时间，但 tmux 右侧状态栏仍慢一个小时。例如，系统显示 `14:37 JST`，tmux 却显示 `13:37 CST`。问题不在 `timedatectl set-time`：一个早已启动的 tmux server 仍按旧时区格式化状态栏。

```bash
sudo timedatectl set-timezone Asia/Tokyo
sudo timedatectl set-ntp false
# aligned to real Asia/Shanghai time
timedatectl set-time &#34;2026-09-26 15:33:00&#34;
```

&lt;!--more--&gt;

## 时区和系统时间是两件事

系统时钟记录的是同一个时间点；时区决定它如何显示。东京是 UTC&#43;9，上海是 UTC&#43;8，因此同一个时间点在东京显示 `14:36` 时，在上海显示 `13:36`。如果只是要把系统从东京时区改为上海时区，执行：

```bash
sudo timedatectl set-timezone Asia/Shanghai
timedatectl
```

这一步不需要再运行 `set-time`。反过来，如果要保留东京时区，就设置为：

```bash
timedatectl list-timezones | grep -E &#39;^Asia/(Tokyo|Shanghai)$&#39;
sudo timedatectl set-timezone Asia/Tokyo
timedatectl
date &#39;&#43;%Y-%m-%d %H:%M:%S %Z %z&#39;
```

`timedatectl` 会显示 `Time zone`、`Local time`、`Universal time` 和时间同步状态。`date` 则方便核对当前 shell 看到的本地时间与 UTC 偏移量。东京应显示 `JST &#43;0900`。如果只是想临时查看上海时间，而不更改系统设置，可以运行：

```bash
TZ=Asia/Shanghai date &#39;&#43;%Y-%m-%d %H:%M:%S %Z %z&#39;
```

## 系统时钟确实错误时，再设置时间

优先让系统自动同步时间：

```bash
sudo timedatectl set-ntp true
timedatectl
```

如果无法使用自动同步，先关闭它，再输入**当前系统时区下**的日期和时间。例如系统时区为 `Asia/Tokyo` 时：

```bash
sudo timedatectl set-ntp false
sudo timedatectl set-time &#39;2026-09-26 14:36:00&#39;
timedatectl
```

上面的日期和时间只是示例，不能原样当作现在的时间使用。`set-time` 修改系统时钟；`set-timezone` 修改本地时间的显示规则。如果启用了时间同步服务，手动设置的时间之后可能被同步服务校正。

## 为什么 tmux 仍慢一个小时

这次排查时，系统时钟和 tmux 自己格式化的时钟分别显示：

```text
system: 2026-09-26 14:37:26 JST
tmux:   2026-09-26 13:37:26 CST
```

可以用以下命令分别检查，不必凭状态栏猜测：

```bash
timedatectl status
date &#39;&#43;system: %Y-%m-%d %H:%M:%S %Z %z&#39;
tmux display-message -p &#39;tmux: %Y-%m-%d %H:%M:%S %Z&#39;
tmux show-options -gv status-right
```

该 tmux server 在修改系统时区之前已经运行了多日，状态栏配置又直接使用 `%b%d` 和 `%H:%M:%S`。tmux 因而继续用旧时区格式化这部分内容。重复执行 `timedatectl set-time` 只会把正确的系统时钟改错。

## 不关闭 tmux 会话的临时修复

tmux 的状态栏支持 `#(command)`，可以改由新启动的 `date` 进程生成东京时间。下面的脚本只替换当前 `status-right` 里的日期和时间格式，保留其余样式，并把原值存进 tmux 的用户选项中：

```bash
python3 - &lt;&lt;&#39;PY&#39;
import subprocess

old = subprocess.check_output(
    [&#39;tmux&#39;, &#39;show-options&#39;, &#39;-gv&#39;, &#39;status-right&#39;], text=True
).rstrip(&#39;\n&#39;)

if &#39;%b%d&#39; not in old or &#39;%H:%M:%S&#39; not in old:
    raise SystemExit(&#39;This status-right does not use the expected date/time formats&#39;)

new = old.replace(&#39;%b%d&#39;, &#39;#(TZ=Asia/Tokyo date &#43;%%b%%d)&#39;)
new = new.replace(&#39;%H:%M:%S&#39;, &#39;#(TZ=Asia/Tokyo date &#43;%%H:%%M:%%S)&#39;)

subprocess.run(
    [&#39;tmux&#39;, &#39;set-option&#39;, &#39;-g&#39;, &#39;@tz_fix_original_status_right&#39;, old],
    check=True,
)
subprocess.run([&#39;tmux&#39;, &#39;set-option&#39;, &#39;-g&#39;, &#39;status-right&#39;, new], check=True)
PY
```

tmux 会先处理状态栏中的 `%`，所以传给 `date` 的格式符要写成 `%%`。这个修复立即作用于正在运行的 tmux server，不会关闭 pane 或 session。如果要恢复原状态栏配置：

```bash
tmux set-option -g status-right \
  &#34;$(tmux show-options -gv @tz_fix_original_status_right)&#34;
```

这是运行时设置；重新加载 tmux 配置后可能被原配置覆盖。之后如果重启 tmux server，它会读取当前系统时区；但 `tmux kill-server` 会终止**所有** tmux 会话及其中运行的程序，应先保存工作。

## 参考

- [systemd `timedatectl` 实现](https://github.com/systemd/systemd/blob/main/src/timedate/timedatectl.c)
- [tmux 官方入门文档：状态栏命令和 `%` 转义](https://github.com/tmux/tmux/wiki/Getting-Started)
- [tmux 手册](https://github.com/tmux/tmux/blob/master/tmux.1)


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-09-26-linux-timezone-clock-and-tmux/  

