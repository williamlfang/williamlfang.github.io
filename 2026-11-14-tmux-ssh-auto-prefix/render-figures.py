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

text(48, 35, 'Ctrl-k follows the active SSH route', 42, bold=True)
text(48, 96, 'Conceptual two-hop workflow; downstream Ctrl-k is assumed', 26, muted)
box((48, 150, 1152, 260), '#7188ac')
text(74, 168, 'BACKGROUND: one SSH observer, snapshots about every 1 s', 27, bold=True)
text(74, 214, 'Match the first login terminal; watch its shell or tmux foreground job.', 25, muted)
box((48, 304, 566, 530), '#8fc9ff')
text(74, 324, 'FIRST REMOTE ONLY', 28, '#8fc9ff', True)
text(74, 374, 'Foreground: shell / editor', 26)
text(74, 420, 'Ctrl-k -> LOCAL tmux', 28, bold=True)
text(74, 470, 'Plain zsh or a Ctrl-j tmux', 25, muted)
box((610, 304, 1152, 530), '#8de1b4')
text(636, 324, 'SECOND SSH ACTIVE', 28, '#8de1b4', True)
text(636, 374, 'Foreground: ssh / autossh', 26)
text(636, 420, 'Ctrl-b -> LOCAL tmux', 28, bold=True)
text(636, 470, 'Ctrl-k -> second remote tmux', 25, '#8de1b4', True)
text(470, 556, 'Start second SSH', 23, muted)
arrow((400, 598), (800, 598), '#8de1b4')
text(466, 620, 'Exit: Ctrl-k local again', 23, muted)
box((48, 686, 1152, 764), '#dbb96a')
text(76, 709, 'Ctrl-j: relay tmux, if attached  |  Ctrl-b: local  |  Ctrl-b F12: override', 24, '#f1d899', True)
image.save(ROOT / 'featured-image.png', optimize=True)
