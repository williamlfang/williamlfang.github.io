#!/usr/bin/env python3
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('quota', ROOT / 'codex-quota.py')
quota = importlib.util.module_from_spec(spec)
spec.loader.exec_module(quota)


class StatusTests(unittest.TestCase):
    def test_quota_is_not_fabricated(self):
        cached = {'limits': {'primary': {'usedPercent': 0, 'windowDurationMins': 300,
                                        'resetsAt': 2000}}, 'updated_at': 990}
        self.assertEqual(quota.display(cached, 1000)['five_hour']['used_percentage'], 0)
        self.assertFalse(quota.display(cached, 1000)['stale'])
        self.assertNotIn('five_hour', quota.display(cached, 2200))
        self.assertNotIn('five_hour', quota.display({}, 1000))
        cached['limits']['secondary'] = {'usedPercent': 12, 'windowDurationMins': 10080, 'resetsAt': 3000}
        self.assertEqual(quota.display(cached, 2200)['seven_day']['used_percentage'], 12)
        cached['updated_at'] = 1
        self.assertTrue(quota.display(cached, 1000)['stale'])
        cached['limits']['primary']['windowDurationMins'] = 60
        self.assertNotIn('five_hour', quota.display(cached, 1000))

    def test_bar_fits_and_uses_session_tokens(self):
        fixture = {'model': {'id': 'gpt-6.1-sol', 'display_name': 'GPT-6.1-Sol'},
                   'effort': {'level': 'medium'}, 'workspace': {'current_dir': '/tmp'},
                   'context_window': {'used_percentage': 12,
                                      'total_input_tokens': 24000, 'total_output_tokens': 1500}}
        with tempfile.TemporaryDirectory() as directory:
            helper = Path(directory) / '.claude/codex-quota.py'
            helper.parent.mkdir()
            data = {'stale': False,
                    'five_hour': {'used_percentage': 71, 'resets_at': 2000000000},
                    'seven_day': {'used_percentage': 12, 'resets_at': 2000500000}}
            helper.write_text('print(' + repr(json.dumps(data)) + ')\n')
            for columns in (80, 140):
                result = subprocess.run(['bash', str(ROOT / 'statusline-p10k.sh')],
                                        input=json.dumps(fixture), text=True, capture_output=True,
                                        env={**os.environ, 'HOME': directory,
                                             'COLUMNS': str(columns)}, check=True)
                plain = re.sub(r'\x1b\[[0-9;]*m', '', result.stdout).strip()
                self.assertIn('Codex 5h 71%', plain)
                self.assertIn('7d 12%', plain)
                if columns == 140:
                    self.assertIn('25500', plain)
                self.assertEqual(plain.count('↻'), 2)
                self.assertEqual(len(plain.splitlines()), 1)
                self.assertLessEqual(len(plain), columns)



if __name__ == '__main__':
    unittest.main()
