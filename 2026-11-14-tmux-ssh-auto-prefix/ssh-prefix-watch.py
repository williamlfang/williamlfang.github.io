#!/usr/bin/env python3
"""Watch the active remote tmux route without polling the large local server.

One read-only SSH connection emits snapshots once a second. Only route changes
set a local pane option (every set-option otherwise causes an unwanted redraw).
On direct Linux connections, match the interactive SSH TCP source port to its
remote SSH_TTY, then inspect that terminal's foreground job. This covers plain
login -> zsh -> ssh as well as a tmux relay, without using unrelated clients.
Proxy/multiplexed connections fall back to tmux-client detection. Remote terminal
tracking requires Python 3.6+ and readable /proc; local Python must be 3.7+.
A foreground SSH is a second-hop heuristic, not proof that the next host runs
tmux. Ctrl-b F12 overrides until the detected route changes.
"""
import os
import shlex
import signal
import subprocess
import sys
import time

REMOTE_WATCH = r'''
while :; do
    clients=$(tmux list-clients -F '#{prefix}|#{prefix2}|#{pane_current_command}' 2>/dev/null)
    if [ -n "$clients" ]; then
        printf '%s\n' "$clients"
    else
        tmux list-sessions -F '#{prefix}|#{prefix2}|' 2>/dev/null
    fi
    printf '%s\n' END
    sleep 1
done
'''


def route(rows):
    """Only a unanimous snapshot is safe when several clients are attached."""
    states = set()
    for row in rows:
        fields = row.split('|')
        if len(fields) != 3:
            return 0
        primary, secondary, command = fields
        if command == 'ssh-terminal':
            states.add(1)
        elif 'C-k' in (primary, secondary):
            states.add(1)
        elif 'C-j' in (primary, secondary) and command in ('ssh', 'autossh'):
            states.add(1)
        else:
            states.add(0)
    return int(states == {1})


# Linux /proc lets the observer correlate the interactive SSH connection with
# its remote login terminal, instead of inspecting unrelated tmux clients.
REMOTE_TERMINAL_WATCH = r'''
import os, subprocess, sys, time
port = sys.argv[1]
terminal = None
while True:
    if terminal is None:
        for name in os.listdir('/proc'):
            if not name.isdigit():
                continue
            try:
                raw = open('/proc/' + name + '/environ', 'rb').read()
                env = dict(item.split(b'=', 1) for item in raw.split(b'\0') if b'=' in item)
                connection = env.get(b'SSH_CONNECTION', b'').decode().split()
                tty = env.get(b'SSH_TTY', b'').decode()
                if len(connection) == 4 and connection[1] == port and tty:
                    terminal = tty
                    break
            except (OSError, ValueError):
                pass
    rows = []
    if terminal:
        commands = []
        tty_number = os.stat(terminal).st_rdev
        for name in os.listdir('/proc'):
            if not name.isdigit():
                continue
            try:
                stat = open('/proc/' + name + '/stat').read()
                end = stat.rfind(')')
                fields = stat[end + 2:].split()
                # After comm: state, ppid, pgrp, session, tty_nr, tpgid.
                if int(fields[4]) == tty_number and fields[2] == fields[5]:
                    commands.append(stat[stat.find('(') + 1:end])
            except (OSError, ValueError, IndexError):
                pass
        if any(c in ('ssh', 'autossh') for c in commands):
            rows = ['None|None|ssh-terminal']
        elif any(c.startswith('tmux') for c in commands):
            result = subprocess.run(['tmux', 'list-clients', '-F',
                '#{client_tty}|#{prefix}|#{prefix2}|#{pane_current_command}'],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            rows = [line.split('|', 1)[1] for line in result.stdout.splitlines()
                    if line.split('|', 1)[0] == terminal]
        else:
            rows = ['None|None|shell-terminal']
    print('\n'.join(rows + ['END']), flush=True)
    time.sleep(1)
'''


def interactive_source_port():
    """Find a wrapper ancestor's SSH child and its actual TCP source port.

    Exact correlation works for ordinary direct Linux/OpenSSH connections.
    ProxyJump, multiplexed connections, or hidden socket metadata fall back to
    the original tmux-only observer rather than guessing another login's tty.
    """
    for _ in range(15):
        parent = os.getppid()
        ssh_pids = set()
        for _ in range(4):
            try:
                with open(f'/proc/{parent}/task/{parent}/children') as stream:
                    children = stream.read().split()
                for pid in children:
                    with open(f'/proc/{pid}/comm') as stream:
                        if stream.read().strip() == 'ssh':
                            ssh_pids.add(pid)
                with open(f'/proc/{parent}/status') as stream:
                    parent = int(next(line.split()[1] for line in stream if line.startswith('PPid:')))
            except (OSError, StopIteration):
                break
        try:
            sockets = subprocess.check_output(['ss', '-Htnp'], text=True, stderr=subprocess.DEVNULL)
            ports = set()
            for line in sockets.splitlines():
                if any(f'pid={pid},' in line for pid in ssh_pids):
                    fields = line.split()
                    if fields[0] == 'ESTAB':
                        ports.add(fields[3].rsplit(':', 1)[1])
            if len(ports) == 1:
                return ports.pop()
        except (OSError, subprocess.CalledProcessError):
            return None
        time.sleep(0.2)
    return None


def main():
    pane, *ssh_args = sys.argv[1:]
    observer = None

    def stop(_signum, _frame):
        raise SystemExit(0)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    last = None

    def publish(value):
        nonlocal last
        if value != last:
            result = subprocess.run(
                ['tmux', 'set-option', '-p', '-t', pane, '@remote_ctrl_k', str(value)],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
            if result.returncode:
                raise SystemExit(0)  # The pane/server has gone away.
            last = value

    try:
        port = interactive_source_port()
        remote_command = 'python3 -u - ' + shlex.quote(port) if port else 'sh -s'
        remote_script = REMOTE_TERMINAL_WATCH if port else REMOTE_WATCH
        observer = subprocess.Popen(
            ['ssh', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=4',
             '-o', 'ConnectionAttempts=1', '-o', 'ClearAllForwardings=yes',
             '-o', 'PermitLocalCommand=no', '-o', 'RemoteCommand=none',
             '-o', 'RequestTTY=no', '-o', 'ControlMaster=no',
             '-o', 'ServerAliveInterval=5', '-o', 'ServerAliveCountMax=1',
             *ssh_args, remote_command],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, text=True, start_new_session=True,
        )
        observer.stdin.write(remote_script)
        observer.stdin.close()
        rows = []
        for line in observer.stdout:
            line = line.rstrip('\n')
            if line == 'END':
                publish(route(rows))
                rows = []
            else:
                rows.append(line)
        publish(0)  # Lost observer: fail local; manual override still works.
    except (OSError, BrokenPipeError):
        publish(0)
    finally:
        if observer is not None:
            try:
                os.killpg(observer.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            observer.wait()


if __name__ == '__main__':
    main()
