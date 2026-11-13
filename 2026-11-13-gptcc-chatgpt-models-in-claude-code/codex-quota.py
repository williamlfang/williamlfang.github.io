#!/usr/bin/env python3
"""Read Codex's five-hour quota without blocking Claude's status bar."""
import fcntl
import json
import os
from pathlib import Path
import selectors
import subprocess
import sys
import time

CACHE = Path(os.environ.get('XDG_CACHE_HOME', Path.home() / '.cache')) / 'claude-codex-status' / 'quota.json'


def read_cache():
    try:
        cached = json.loads(CACHE.read_text())
        return cached if isinstance(cached, dict) else {}
    except (OSError, ValueError):
        return {}


def fetch_limits():
    env = dict(os.environ)
    env.pop('OPENAI_API_KEY', None)
    process = subprocess.Popen(['codex', 'app-server'], stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, env=env)
    def send(message):
        process.stdin.write((json.dumps(message) + '\n').encode())
        process.stdin.flush()
    try:
        send({'id': 1, 'method': 'initialize', 'params': {
            'clientInfo': {'name': 'claude_statusline', 'version': '1.0'}}})
        deadline = time.monotonic() + 12
        buffer = b''
        with selectors.DefaultSelector() as selector:
            selector.register(process.stdout, selectors.EVENT_READ)
            while time.monotonic() < deadline:
                if not selector.select(timeout=0.5):
                    continue
                chunk = os.read(process.stdout.fileno(), 65536)
                if not chunk:
                    raise RuntimeError('Codex app-server exited')
                buffer += chunk
                while b'\n' in buffer:
                    line, buffer = buffer.split(b'\n', 1)
                    message = json.loads(line)
                    if message.get('id') not in (1, 2):
                        continue
                    if 'error' in message:
                        raise RuntimeError('Codex quota unavailable')
                    if message['id'] == 1:
                        send({'method': 'initialized'})
                        send({'id': 2, 'method': 'account/rateLimits/read'})
                    else:
                        result = message['result']
                        return (result.get('rateLimitsByLimitId') or {}).get('codex') or result.get('rateLimits') or {}
        raise TimeoutError('Codex quota timed out')
    finally:
        process.terminate()
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def refresh():
    CACHE.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    with CACHE.with_suffix('.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        cached = read_cache()
        now = time.time()
        if now - cached.get('checked_at', 0) < 60:
            return
        try:
            limits = fetch_limits()
            cached = {'limits': limits, 'updated_at': now}
        except (OSError, ValueError, RuntimeError, TimeoutError):
            pass
        cached['checked_at'] = now
        temporary = CACHE.with_suffix('.tmp')
        temporary.write_text(json.dumps(cached) + '\n')
        temporary.chmod(0o600)
        temporary.replace(CACHE)


def display(cached, now):
    limits = cached.get('limits') or {}
    result = {'stale': now - cached.get('updated_at', 0) > 120}
    for source, target, minutes in [('primary', 'five_hour', 300),
                                    ('secondary', 'seven_day', 10080)]:
        window = limits.get(source) or {}
        if (window.get('windowDurationMins') == minutes
                and now < window.get('resetsAt', 0)
                and isinstance(window.get('usedPercent'), (int, float))):
            result[target] = {'used_percentage': window['usedPercent'],
                              'resets_at': window['resetsAt']}
    return result



if __name__ == '__main__':
    if sys.argv[1:] == ['--refresh']:
        refresh()
    else:
        cached = read_cache()
        if time.time() - cached.get('checked_at', 0) >= 60:
            subprocess.Popen([sys.executable, str(Path(__file__).resolve()), '--refresh'],
                             stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL, start_new_session=True)
        print(json.dumps(display(cached, time.time())))
