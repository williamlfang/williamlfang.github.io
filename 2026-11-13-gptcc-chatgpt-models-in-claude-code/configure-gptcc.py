#!/usr/bin/env python3
"""Configure a Linux/macOS gptcc installation without printing credentials."""
from datetime import datetime
import json
import os
from pathlib import Path
import secrets
import shlex
import shutil

ROOT = Path(__file__).resolve().parent
MODELS = json.loads((ROOT / 'model-picker.json').read_text())


def configure(settings, node, hook):
    env = settings.setdefault('env', {})
    token = env.get('GPTCC_AUTH_TOKEN') or secrets.token_urlsafe(32)
    env.update({
        'ANTHROPIC_BASE_URL': 'http://127.0.0.1:52532',
        'ANTHROPIC_AUTH_TOKEN': token,
        'GPTCC_AUTH_TOKEN': token,
        'OPENAI_API_KEY': '',
        'NODE_USE_ENV_PROXY': '1',
        'ANTHROPIC_DEFAULT_MODEL': 'gpt-6.1-sol',
        'ANTHROPIC_CUSTOM_MODEL_OPTION': 'gpt-6.1-sol',
        'ANTHROPIC_CUSTOM_MODEL_OPTION_NAME': 'GPT-6.1 Sol',
        'ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION': 'OpenAI GPT via ChatGPT subscription',
        'ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES': 'effort,thinking,adaptive_thinking',
    })
    for key in ('CLAUDE_CODE_USE_BEDROCK', 'CLAUDE_CODE_SKIP_BEDROCK_AUTH',
                'ANTHROPIC_BEDROCK_BASE_URL'):
        env.pop(key, None)
    for slot, model, label in [('OPUS', 'gpt-6-astra', 'GPT-6 Astra'),
                               ('SONNET', 'gpt-6.1-sol', 'GPT-6.1 Sol'),
                               ('HAIKU', 'gpt-6-luna', 'GPT-6 Luna')]:
        env['ANTHROPIC_DEFAULT_' + slot + '_MODEL'] = model
        env['ANTHROPIC_DEFAULT_' + slot + '_MODEL_NAME'] = label
        env['ANTHROPIC_DEFAULT_' + slot + '_MODEL_DESCRIPTION'] = 'OpenAI GPT via ChatGPT subscription'
    settings.pop('model', None)
    settings.setdefault('modelSettings', {}).setdefault('gpt-6.1-sol', {})['effortLevel'] = 'medium'
    settings['modelPicker'] = {'replaceBuiltInOptions': True, 'options': MODELS}
    settings['disableClaudeAiConnectors'] = True
    # gptcc 2.5.3's bare-name fallback was not an installed plugin in this session.
    settings.get('enabledPlugins', {}).pop('gptcc', None)
    command = 'env -u OPENAI_API_KEY NODE_USE_ENV_PROXY=1 ' + shlex.join([str(node), str(hook)])
    startup = settings.setdefault('hooks', {}).setdefault('SessionStart', [])
    if not any(entry.get('command') == command
               for group in startup for entry in group.get('hooks', [])):
        startup.append({'hooks': [{'type': 'command', 'command': command, 'timeout': 10}]})
    return settings


if __name__ == '__main__':
    node = shutil.which('node')
    binary = shutil.which('gptcc')
    if not node or not binary:
        raise SystemExit('Install Node.js and gptcc first')
    package = Path(binary).resolve().parent.parent
    hook = package / 'plugin/hooks/start-proxy.mjs'
    if not hook.is_file():
        raise SystemExit('Cannot locate gptcc plugin/hooks/start-proxy.mjs')
    path = Path.home() / '.claude/settings.json'
    current = json.loads(path.read_text()) if path.exists() else {}
    updated = configure(current, Path(node), hook)
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        backup = path.with_name('settings.json.before-gptcc-blog-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
        shutil.copy2(path, backup)
        backup.chmod(0o600)
        print('Backup:', backup)
    temporary = path.with_name('settings.json.tmp-gptcc-blog')
    temporary.write_text(json.dumps(updated, indent=2, ensure_ascii=False) + '\n')
    temporary.chmod(0o600)
    temporary.replace(path)
    print('Saved GPT picker, Sol medium default, local gateway auth, and startup hook.')
    print('Restart the proxy with the settings environment, then restart Claude Code.')
