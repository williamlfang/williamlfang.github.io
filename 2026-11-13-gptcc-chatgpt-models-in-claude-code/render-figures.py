#!/usr/bin/env python3
"""Render captured, sanitized terminal text and an explanatory request diagram."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
SANS = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BG = '#101722'
INK = '#e6edf3'
MUTED = '#98a6ba'
ACCENT = '#79dcc2'
RED = '#f77f89'


def terminal(filename, title, lines, highlights=(), size=20,
             footer='Captured terminal text, rendered for readability | 2026-11-13'):
    font = ImageFont.truetype(FONT, size)
    small = ImageFont.truetype(SANS, 17)
    line_height = size + 14
    width = max(1280, int(max(font.getlength(line) for line in lines)) + 88)
    height = 140 + len(lines) * line_height
    image = Image.new('RGB', (width, height), '#e7edf5')
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((18, 18, width-18, height-18), radius=16, fill=BG)
    draw.rounded_rectangle((18, 18, width-18, 71), radius=16, fill='#202b3c')
    for x, color in [(43, RED), (66, '#e9c46a'), (89, ACCENT)]:
        draw.ellipse((x, 37, x+12, 49), fill=color)
    draw.text((125, 32), title, font=small, fill=INK)
    for index, line in enumerate(lines):
        y = 91 + index * line_height
        if index in highlights:
            draw.rounded_rectangle((33, y-5, width-33, y+line_height-5), radius=5,
                                   outline=RED, width=2, fill='#202637')
        color = ACCENT if index in highlights else INK
        draw.text((43, y), line, font=font, fill=color)
    draw.text((43, height-47), footer, font=small, fill=MUTED)
    image.save(ROOT / filename)
    assert width >= 1280 and height > 200


picker = [
    'Select model',
    '',
    '  1. Default (recommended)  Use the default model (currently GPT-6.1-Sol)',
    '                           Set by ANTHROPIC_DEFAULT_MODEL',
    '> 2. GPT-6.1-Sol            Latest workhorse model for coding and everyday work.',
    '  3. GPT-6-Astra            Frontier intelligence for the most demanding work.',
    '  4. GPT-6.1 Terra          GPT-6.1 Terra Codex model.',
    '  5. GPT-6-Sol              Previous generation workhorse model.',
    '  6. GPT-6-Luna             Fast and affordable model for easier tasks.',
    '  7. GPT-5.6-Sol            Older generation workhorse model.',
    '  8. GPT-5.6-Terra          Older balanced model for straightforward work.',
    '  9. GPT-5.6-Luna           Older fast and efficient model.',
    '',
    '  Medium effort',
]
terminal('featured-image.png', 'Claude Code /model | v2.1.316 | gptcc 2.5.3', picker, (2, 13), 20)
terminal('statusline.png', 'Claude Code | updated status-line layout example', [
    'GPT-6.1-Sol with medium effort',
    '',
    'GPT-6.1-Sol · medium | ctx ░░░░░░░░░░ 0% | tok 115 | Codex 5h 73% ↻19:10 | 7d 11% ↻Fri 14:10',
    '',
    'auto mode on (shift+tab to cycle)',
], (2,), 23, footer='Layout example, rendered for readability | 2026-11-13')
terminal('verification.png', 'python3 verify-gptcc.py | actual verification output',
         (ROOT / 'verification.txt').read_text().splitlines(), (5,), 22)

image = Image.new('RGB', (1500, 830), '#f4f7fc')
draw = ImageDraw.Draw(image)
title = ImageFont.truetype(SANS, 35)
body = ImageFont.truetype(SANS, 23)
small = ImageFont.truetype(SANS, 19)
draw.text((55, 35), 'Two credentials, two separate connections', font=title, fill='#17263b')

def box(rect, heading, lines, color):
    draw.rounded_rectangle(rect, radius=18, fill='white', outline=color, width=3)
    x, y, _, _ = rect
    draw.text((x+23, y+20), heading, font=ImageFont.truetype(SANS, 27), fill=color)
    for n, line in enumerate(lines):
        draw.text((x+23, y+72+35*n), line, font=body, fill='#31435b')

def arrow(x1, x2, y):
    draw.line((x1, y, x2, y), fill='#4b6383', width=4)
    draw.polygon([(x2, y), (x2-14, y-9), (x2-14, y+9)], fill='#4b6383')

box((50, 220, 440, 475), 'Claude Code', ['Model picker and tools', 'GPT-6.1 Sol · medium', 'Anthropic-format messages'], '#315caa')
box((540, 220, 960, 475), 'Local gptcc proxy', ['127.0.0.1:52532', 'Checks the local token', 'Translates request + stream'], '#187d6b')
box((1060, 220, 1450, 475), 'ChatGPT / Codex', ['Checks ChatGPT OAuth', 'Runs the selected GPT', 'Returns model output'], '#7b4eb0')
arrow(447, 529, 345)
arrow(967, 1049, 345)
draw.text((63, 135), 'ANTHROPIC_AUTH_TOKEN', font=small, fill='#315caa')
draw.text((63, 164), '= local gateway credential', font=small, fill='#31435b')
draw.text((548, 135), 'GPTCC_AUTH_TOKEN', font=small, fill='#187d6b')
draw.text((548, 164), '= the same local credential', font=small, fill='#31435b')
draw.text((1069, 135), '~/.codex/auth.json', font=small, fill='#7b4eb0')
draw.text((1069, 164), '= separate ChatGPT login', font=small, fill='#31435b')
draw.rounded_rectangle((50, 540, 1450, 754), radius=18, fill='#e7edf8')
for n, line in enumerate([
    'Model routing: ANTHROPIC_BASE_URL points Claude Code at the loopback gateway.',
    'Gateway identity: the paired local tokens authenticate the client to its own proxy.',
    'Model-provider identity: gptcc uses ChatGPT OAuth for the upstream GPT request.',
    'Changing a model name alone does not change the credential Claude Code uses.',
]):
    draw.text((78, 568+n*40), line, font=body, fill='#263b58')
draw.text((55, 786), 'Explanatory diagram of the configuration verified on 2026-11-13.', font=small, fill='#5c6e84')
image.save(ROOT / 'request-flow.png')
assert all((ROOT / name).is_file() for name in ['featured-image.png', 'statusline.png', 'verification.png', 'request-flow.png'])
print('Rendered 4 figures from captured output and the verified request flow.')
