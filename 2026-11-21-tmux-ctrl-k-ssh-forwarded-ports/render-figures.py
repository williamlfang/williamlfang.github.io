#!/usr/bin/env python3
"""Render the three post figures with Pillow and DejaVu fonts."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent
WIDTH = 960
BG = '#0f172a'
PANEL = '#1e293b'
STROKE = '#475569'
WHITE = '#f8fafc'
MUTED = '#cbd5e1'
BLUE = '#7dd3fc'
GREEN = '#86efac'
RED = '#fda4af'


def font(size, face=''):
    return ImageFont.truetype(f'DejaVuSans{face}.ttf', size)


def canvas(height, kicker, title):
    image = Image.new('RGB', (WIDTH, height), BG)
    draw = ImageDraw.Draw(image)
    draw.text((42, 28), kicker, font=font(24, '-Bold'), fill=BLUE)
    draw.text((42, 70), title, font=font(42, '-Bold'), fill=WHITE)
    return image, draw


def box(draw, x, y, w, h, title, detail, accent=BLUE):
    draw.rounded_rectangle((x, y, x+w, y+h), radius=16, fill=PANEL,
                           outline=STROKE, width=2)
    draw.text((x+17, y+12), title, font=font(28, '-Bold'), fill=accent)
    draw.text((x+17, y+53), detail, font=font(24), fill=WHITE)


def arrow(draw, start, end, y):
    draw.line((start, y, end-5, y), fill=MUTED, width=4)
    draw.polygon([(end, y), (end-12, y-8), (end-12, y+8)], fill=MUTED)


def port_evidence():
    image, draw = canvas(560, 'OBSERVED  /  LOOPBACK SSH', 'One login, two source ports')
    mono = font(34, 'Mono')
    for y, heading, row, port in (
        (147, 'LOCAL CLIENT  /  ss', '127.0.0.1:51956  127.0.0.1:62222', '51956'),
        (316, 'REMOTE SHELL  /  SSH_CONNECTION', '127.0.0.1 34500 127.0.0.1 22', '34500'),
    ):
        draw.rounded_rectangle((42, y, 918, y+141), radius=16, fill=PANEL)
        draw.text((64, y+19), heading, font=font(23, '-Bold'), fill=MUTED)
        x, ty = 64, y+72
        draw.text((x, ty), row, font=mono, fill=WHITE)
        l = x + draw.textlength(row[:row.index(port)], font=mono)
        r = l + draw.textlength(port, font=mono)
        draw.rounded_rectangle((l-5, ty-3, r+5, ty+44), radius=6, outline=RED, width=3)
    draw.text((42, 496), 'The detector looked for 51956, but sshd saw 34500.', font=font(27), fill=MUTED)
    image.save(OUT/'featured-image.png', optimize=True)


def login_routes():
    image, draw = canvas(578, 'ILLUSTRATION  /  LOGIN ROUTES', 'Two ways to reach remote tmux')
    draw.text((42, 150), 'DIRECT', font=font(25, '-Bold'), fill=GREEN)
    box(draw, 42, 194, 242, 100, 'Local tmux', 'zsh starts SSH')
    box(draw, 334, 194, 257, 100, 'Known forward', '62222 or 62223')
    box(draw, 641, 194, 277, 100, 'Remote tmux', 'Ctrl-k', GREEN)
    arrow(draw, 293, 325, 244)
    arrow(draw, 600, 632, 244)
    draw.text((42, 315), 'Set forwarding when the login starts.', font=font(26), fill=MUTED)
    draw.text((42, 383), 'TWO HOPS', font=font(25, '-Bold'), fill=GREEN)
    box(draw, 42, 426, 242, 100, 'Local tmux', 'SSH to relay')
    box(draw, 334, 426, 257, 100, 'Relay shell', 'Start next SSH')
    box(draw, 641, 426, 277, 100, 'Remote tmux', 'Ctrl-k', GREEN)
    arrow(draw, 293, 325, 476)
    arrow(draw, 600, 632, 476)
    draw.text((42, 539), 'Watch for the second SSH to start or stop.', font=font(26), fill=MUTED)
    image.save(OUT/'login-routes.png', optimize=True)


def routing_states():
    image, draw = canvas(614, 'ILLUSTRATION  /  PANE FLAG', 'Who gets Ctrl-k?')
    draw.text((42, 150), 'DIRECT  /  FLAG SET BY LOGIN HELPER', font=font(24, '-Bold'), fill=MUTED)
    box(draw, 42, 195, 242, 100, 'Before login', 'Local tmux')
    box(draw, 334, 195, 257, 100, 'Known login', 'Forward (1)', GREEN)
    box(draw, 641, 195, 277, 100, 'After logout', 'Restore prior flag')
    arrow(draw, 293, 325, 245)
    arrow(draw, 600, 632, 245)
    draw.text((42, 353), 'TWO HOPS  /  FLAG TRACKS THE RELAY', font=font(24, '-Bold'), fill=MUTED)
    box(draw, 42, 398, 242, 100, 'Relay shell', 'Local (0)')
    box(draw, 334, 398, 257, 100, 'Second SSH', 'Forward (1)', GREEN)
    box(draw, 641, 398, 277, 100, 'Back at relay', 'Local (0)')
    arrow(draw, 293, 325, 448)
    arrow(draw, 600, 632, 448)
    draw.text((42, 544), 'Ctrl-b controls local tmux in every state.', font=font(26), fill=WHITE)
    image.save(OUT/'routing-states.png', optimize=True)


if __name__ == '__main__':
    port_evidence()
    login_routes()
    routing_states()
