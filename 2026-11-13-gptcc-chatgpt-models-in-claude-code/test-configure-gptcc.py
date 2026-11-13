#!/usr/bin/env python3
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('configure', ROOT / 'configure-gptcc.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ConfigureTests(unittest.TestCase):
    def test_preserves_settings_and_converges(self):
        original = {'permissions': {'defaultMode': 'manual'},
                    'env': {'EXISTING': 'keep', 'CLAUDE_CODE_USE_BEDROCK': '1'},
                    'model': 'opus', 'hooks': {'SessionStart': [
                        {'hooks': [{'type': 'command', 'command': 'echo existing'}]}]}}
        first = module.configure(copy.deepcopy(original), Path('/usr/bin/node'), Path('/tmp/start-proxy.mjs'))
        second = module.configure(copy.deepcopy(first), Path('/usr/bin/node'), Path('/tmp/start-proxy.mjs'))
        self.assertEqual(first, second)
        self.assertEqual(first['permissions'], original['permissions'])
        self.assertEqual(first['env']['EXISTING'], 'keep')
        self.assertNotIn('CLAUDE_CODE_USE_BEDROCK', first['env'])
        self.assertEqual(first['env']['GPTCC_AUTH_TOKEN'], first['env']['ANTHROPIC_AUTH_TOKEN'])
        self.assertEqual(len(first['modelPicker']['options']), 8)
        self.assertEqual(len(first['hooks']['SessionStart']), 2)
        self.assertNotIn('model', first)
        self.assertEqual(first['modelSettings']['gpt-6.1-sol']['effortLevel'], 'medium')


if __name__ == '__main__':
    unittest.main()
