# Keep SSH reachable with a closed lid on Linux Mint


My Linux Mint notebook accepted SSH connections while its lid was open, but became unreachable when I shut it. The connection command was unchanged:

```bash
ssh william@127.0.0.1 -p 62223
```

The relevant setting was not in `sshd_config`. **Cinnamon was configured to suspend the notebook when the lid closed, even on AC power.** I changed just the AC lid action, leaving the battery policies alone.

&lt;!--more--&gt;

## The setup: change the destination, not the forwarding machine

In this setup, `127.0.0.1:62223` was the local entry point for reaching the notebook. A listening local port did not establish that the destination notebook was awake or that its SSH server could respond.

The initial check on the connecting machine was:

```bash
ss -ltnp &#39;sport = :62223&#39;
ssh -o BatchMode=yes -o ConnectTimeout=8 -p 62223 william@127.0.0.1
```

The port was listening, but the SSH attempt reported:

```text
Connection timed out during banner exchange
```

That meant the client had not received the SSH server&#39;s greeting in time. It was consistent with an unavailable destination behind the local forwarding endpoint, but **the timeout alone did not prove that the notebook was asleep**. Forwarding problems can produce similar symptoms.

Once the notebook was accessible again, I connected and checked the destination OS:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 -p 62223 william@127.0.0.1 \
  &#39;cat /etc/os-release&#39;
```

The relevant output was:

```text
NAME=&#34;Linux Mint&#34;
VERSION=&#34;20.1 (Ulyssa)&#34;
```

The important distinction was where the next commands ran: on the notebook, not on the machine exposing port `62223`. Hostnames are omitted from this write-up.

## Check the lid state and desktop power manager

On the notebook:

```bash
grep -H . /proc/acpi/button/lid/*/state
ps -eo comm | grep -E &#39;csd-power|gsd-power|xfce4-power|powerdevil|mate-power&#39;
```

The output included:

```text
/proc/acpi/button/lid/LID0/state:state:      open
csd-power
```

The lid was open during inspection. The `csd-power` process identified Cinnamon&#39;s power manager, which made its power settings the next place to look.

These commands are specific to systems exposing this ACPI lid path and these desktop processes. Other Linux desktops may manage lid events differently.

## Read the current policy before changing it

On the notebook:

```bash
gsettings list-recursively org.cinnamon.settings-daemon.plugins.power
```

The relevant settings were:

```text
org.cinnamon.settings-daemon.plugins.power lid-close-ac-action &#39;suspend&#39;
org.cinnamon.settings-daemon.plugins.power lid-close-battery-action &#39;suspend&#39;
org.cinnamon.settings-daemon.plugins.power critical-battery-action &#39;hibernate&#39;
org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
```

Both lid-close actions were `suspend`. The AC idle timeout was already `0`, meaning automatic idle suspend was disabled for that policy. **Idle sleep and lid-close sleep are separate settings.** Disabling one does not necessarily disable the other.

I also checked the values accepted by the lid setting:

```bash
gsettings range org.cinnamon.settings-daemon.plugins.power lid-close-ac-action
```

```text
enum
&#39;blank&#39;
&#39;suspend&#39;
&#39;shutdown&#39;
&#39;hibernate&#39;
&#39;interactive&#39;
&#39;nothing&#39;
```

The notebook was connected to AC power; its power-supply status included:

```text
/sys/class/power_supply/AC/online: 1
```

That made an AC-only change a reasonable default: keep the notebook reachable on the desk without making it stay awake on battery inside a bag.

## The fix: one per-user setting

This was the actual change, executed remotely on the notebook:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 -p 62223 william@127.0.0.1 \
  &#39;gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action &#34;nothing&#34;&#39;
```

Equivalently, from a terminal on the notebook itself:

```bash
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action &#39;nothing&#39;
```

This changes the current user&#39;s persistent Cinnamon preference. It does not edit SSH configuration, require `sudo`, or require a reboot. In this session, the remote `gsettings` command succeeded and the value read back correctly.

Run it as the user whose Cinnamon desktop session controls power management. If a remote command reports a D-Bus or dconf error, use a terminal in that user&#39;s active graphical session instead; do not switch to `sudo gsettings`, which targets the wrong user&#39;s settings.

## Verify the policy separately from the closed-lid test

On the notebook, I read back all four relevant values:

```bash
gsettings get org.cinnamon.settings-daemon.plugins.power lid-close-ac-action
gsettings get org.cinnamon.settings-daemon.plugins.power lid-close-battery-action
gsettings get org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout
gsettings get org.cinnamon.settings-daemon.plugins.power critical-battery-action
```

The actual output, in that order, was:

```text
&#39;nothing&#39;
&#39;suspend&#39;
0
&#39;hibernate&#39;
```

| Policy | Before | After |
|---|---|---|
| Lid closed on AC power | Suspend | **Do nothing** |
| Lid closed on battery | Suspend | Suspend |
| AC idle-suspend timeout | Disabled (`0`) | Unchanged |
| Critical-battery action | Hibernate | Hibernate |

This verified that the configuration change succeeded. It did **not** yet verify the complete closed-lid connection path.

The final test is physical:

1. Keep the notebook plugged into power and leave its Cinnamon session logged in.
2. Close the lid and wait long enough for the usual failure to occur.
3. From the connecting machine, open a fresh SSH connection:

```bash
ssh -o ConnectTimeout=10 william@127.0.0.1 -p 62223
```

At the time of writing, that closed-lid test had not yet been confirmed. The verified result is the updated power policy, not a measured end-to-end success with the lid shut.

## Why I did not change systemd-logind or SSH keepalives

Linux can have more than one layer handling lid events. `systemd-logind` has system-wide lid policies, while a desktop power manager can take responsibility for lid handling.

I checked:

```bash
systemd-inhibit --list --no-pager
```

The notebook had a `csd-power` inhibitor for `handle-lid-switch`. That supported changing Cinnamon&#39;s policy first rather than immediately editing `/etc/systemd/logind.conf`.

This fix is scoped to the active Cinnamon user session. If the problem persists at the login screen, after logging out, or under a different desktop, inspect the effective logind configuration and that desktop&#39;s power manager separately. I did not modify logind or disable suspend system-wide.

SSH keepalives are also not a substitute for keeping the destination awake. They can detect a dead connection or help with some idle-network timeouts; they cannot make a suspended notebook process SSH traffic. This is a different failure mode from [ordinary SSH disconnects and timeouts]({{&lt; relref &#34;2022-12-16-解决ssh经常断线，出现timeout的问题&#34; &gt;}}).

## Undo the change

To restore the notebook&#39;s original AC lid action:

```bash
gsettings set org.cinnamon.settings-daemon.plugins.power lid-close-ac-action &#39;suspend&#39;
gsettings get org.cinnamon.settings-daemon.plugins.power lid-close-ac-action
```

Keep a running notebook ventilated when its lid is shut. With this AC-only change, unplugging it restores the battery lid policy; do not expect closed-lid SSH access on battery.

## Takeaway

When SSH stops responding specifically after a laptop lid closes, check power management before changing `sshd`. In this case, the smallest change was one Cinnamon preference: **do nothing on lid close while plugged in, and preserve the existing battery protections**.


---

> 作者: william  
> URL: https://williamlfang.github.io/2026-11-14-ssh-linux-mint-lid-closed/  

