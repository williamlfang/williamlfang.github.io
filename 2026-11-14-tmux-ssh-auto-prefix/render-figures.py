#!/usr/bin/env python3
"""Render a conceptual diagram, not terminal output. Requires Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
image = Image.new('RGB', (1200, 800), '#101827')
draw = ImageDraw.Draw(image)
white, muted = '#edf2fa', '#afbdd0'

def text(x, y, value, size=26, color=white, bold=False):
    draw.text((x, y), value, font=ImageFont.truetype(BOLD if bold else FONT, size), fill=color)

def box(rect, color):
    draw.rounded_rectangle(rect, radius=16, fill='#1d2a3d', outline=color, width=3)

def arrow(start, end, color):
    draw.line((start, end), fill=color, width=5)
    x, y = end
    if end[0] > start[0]:
        draw.polygon([(x, y), (x - 16, y - 9), (x - 16, y + 9)], fill=color)
    else:
        draw.polygon([(x, y), (x - 9, y - 16), (x + 9, y - 16)], fill=color)

text(48, 35, 'One Ctrl-k, two tmux layers', 43, bold=True)
text(48, 96, 'Conceptual routing for an interactive SSH login', 26, muted)
box((48, 166, 1152, 284), '#7188ac')
text(74, 184, 'CHECK ONCE: query running remote tmux sessions', 28, bold=True)
text(74, 232, 'All accept C-k? Set pane flag to 1. Otherwise, use 0.', 26, muted)
arrow((600, 284), (600, 328), '#7188ac')
box((48, 332, 1152, 420), '#dbb96a')
text(80, 357, 'Ctrl-k  ->  local root-table binding reads the pane flag', 28, bold=True)
arrow((295, 420), (295, 470), '#8fc9ff')
arrow((904, 420), (904, 470), '#8de1b4')
box((48, 474, 566, 635), '#8fc9ff')
text(74, 492, 'FLAG 0 / UNSET: LOCAL', 27, '#8fc9ff', True)
text(74, 543, 'Switch to the prefix table', 27)
text(74, 586, 'Next key controls local tmux', 25, muted)
box((610, 474, 1152, 635), '#8de1b4')
text(636, 492, 'FLAG 1: REMOTE', 27, '#8de1b4', True)
text(636, 543, 'Send Ctrl-k into the pane', 27)
text(636, 586, 'SSH carries it to remote tmux', 25, muted)
box((48, 670, 1152, 756), '#dbb96a')
text(78, 695, 'Always local: Ctrl-b     |     Manual toggle: Ctrl-b, then F12', 27, '#f1d899', True)
image.save(ROOT / 'featured-image.png', optimize=True)
