#!/usr/bin/env python3
"""Verify the local gptcc bridge and a real Claude Code tool round trip."""
import json
from pathlib import Path
import subprocess
import tempfile
import urllib.error
import urllib.request

settings = json.loads((Path.home() / '.claude/settings.json').read_text())
base = settings['env']['ANTHROPIC_BASE_URL'].rstrip('/')
assert base == 'http://127.0.0.1:52532', 'This check targets the default local gptcc port'
opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
with opener.open(base + '/health', timeout=3) as response:
    health = json.load(response)
assert health['proxy'] == 'gptcc'
assert health['features']['authRequired'] is True
assert health['features']['apiKeyFallback'] is False
print('PASS: local gateway requires authentication; API-key fallback is disabled.', flush=True)
request = urllib.request.Request(base + '/v1/messages', data=b'{}',
                                 headers={'Content-Type': 'application/json'})
try:
    opener.open(request, timeout=3)
    raise AssertionError('Unauthenticated request was accepted')
except urllib.error.HTTPError as error:
    assert error.code == 401, error.code
print('PASS: unauthenticated model request returns HTTP 401.', flush=True)
with tempfile.TemporaryDirectory(prefix='gptcc-verify-') as directory:
    target = Path(directory) / 'token.txt'
    target.write_text('gptcc tool test passed\n')
    result = subprocess.run([
        'claude', '-p', '--tools', 'Read', '--allowedTools', 'Read',
        '--strict-mcp-config', '--no-session-persistence', '--output-format', 'json',
        '--max-turns', '4',
        f'Use the Read tool to read {target}. Reply with exactly the file contents.'
    ], cwd=directory, capture_output=True, text=True, timeout=65)
    data = json.loads(result.stdout)
    assert result.returncode == 0 and not data.get('is_error'), data.get('result')
    assert data['result'].strip() == 'gptcc tool test passed', data['result']
    assert data['num_turns'] >= 2, 'Expected a tool round trip'
    assert 'gpt-6.1-sol' in data.get('modelUsage', {}), data.get('modelUsage')
    assert 'claude.ai connectors are disabled because' not in result.stderr
    print('Model: GPT-6.1 Sol')
    print('Reply:', data['result'].strip())
    print('Turns:', data['num_turns'])
    print('PASS: full Claude Code session, Read tool, and connector-banner check.')
