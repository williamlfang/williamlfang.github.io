#!/bin/sh
#
# Renders the whole status line -- left and right side -- as ONE #() job.
#
# Every #() in the status line is a fork of the tmux server, and a fork of a
# big server is slow. Measured on 2026-10-02 (tmux 3.5a, 25 days up, ~900 MB
# resident + ~600 MB in swap): each fork spent 28-37 ms in the kernel, and the
# server handles no input while it forks. status-left.sh and status-right.sh
# ran back to back every second for every attached client, so keystrokes
# stalled for 60-120 ms several times a second. One job per client halves the
# forks and removes the back-to-back pair. Details: ~/ai/tmux-lag-fix-2.md
#
# How one job feeds both sides: status-left holds this job and status-right is
# empty. #[...] style tags in job output are honoured, including align=, so
# the #[align=right range=right] below sends the rest of the output to the
# right edge, where status-right used to draw. It has to be status-left: with
# the window list left-justified (nord-tmux sets status-justify left), text
# placed after the list stays glued to the list, even with align=left.
#
# Formats such as #S or %H:%M are NOT expanded in job output, so the session
# name comes in as an argument.
#
# $1: 1 to show the quote, else 0. tmux evaluates @quote_cond outside the job
#     and picks the argument: inside a #() command strftime is not applied, so
#     the %H%M in @quote_cond only works out there.
# $2: session name (#{q:session_name})
# $3: ascii for clients with inconsistent Unicode glyph widths
# $4: client width (compact metrics below 100 columns)

dir="$HOME/.cache/tmux-status"

render_status() {
# ------------------------------------------------------------- left side
if [ -f "$HOME/.tmux/plugins/tmux-pom/data/pom_start_time.txt" ]; then
    printf '#[fg=black,bg=yellow,bold]'
else
    printf '#[fg=black,bg=blue,bold]'
fi
printf ' XPS:%s #[nobold,italics,nounderscore]' "$2"
cat "$dir/left_pom" 2>/dev/null

# ------------------------------------------------------------ right side
printf '#[default align=right range=right]'
cat "$dir/right" 2>/dev/null
if [ "$1" = 1 ]; then
    printf '#[fg=color244,bg=brightblack,noitalics]'
    cat "$dir/quote" 2>/dev/null
    printf ' '
fi
# The clock comes from date(1) rather than tmux's own %H:%M:%S: a long-running
# tmux server keeps the timezone it started with, so after the system moved to
# Asia/Tokyo its native clock was an hour behind. date reads the current zone.
# printf + $(): job output must be one line -- tmux shows only one.
if [ "$3" = ascii ] && [ "${4:-100}" -lt 100 ]; then
    printf '%s' "$(date '+#[fg=blue,bg=brightblack,noitalics,nounderscore] %H:%M:%S #[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]')"
else
    printf '%s' "$(date '+#[fg=blue,bg=brightblack,noitalics,nounderscore] %b%d #[fg=blue,bg=brightblack]%H:%M:%S#[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]')"
fi
}

if [ "$3" = ascii ]; then
    # Preserve the desktop's style tags and live values, replacing font icons
    # with ordinary single-cell labels. Strip unknown Unicode from user text.
    # C=CPU, M=memory, CX=Codex, CL=Claude, J=JMS traffic.
    compact_filter=''
    if [ "${4:-100}" -lt 100 ]; then
        compact_filter='s/([0-9][0-9]:[0-9][0-9])//g
s/\([0-9][0-9]*\)\.[0-9][0-9]*%/\1%/g'
    fi
    render_status "$@" | sed \
        -e 's//|/g' -e 's//|/g' -e 's//|/g' -e 's//|/g' \
        -e 's//C/g' -e 's//M/g' \
        -e 's/󰚩/CX/g' -e 's/󰯉/CL/g' -e 's/󰖟/J/g' \
        -e 's//|/g' -e 's// /g' \
        -e "$compact_filter" \
        | LC_ALL=C tr -cd ' -~'
else
    render_status "$@"
fi
