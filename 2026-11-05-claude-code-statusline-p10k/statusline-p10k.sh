#!/usr/bin/env bash
# Status line in the style of ~/.p10k.zsh (rainbow powerline, nerdfont-v3):
#   left   context (only over SSH or as root), dir (last folder only, as
#          POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last), vcs (green clean,
#          yellow modified; + staged, ! unstaged, ? untracked, ⇣⇡ behind/ahead)
#   right  conda env, Claude's model · effort, context bar, 5h / 7d usage
# The Claude segments come from the old ~/.claude/statusline.sh, drawn as p10k segments.
input=$(cat)
j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

ESC=$'\e'
fg() { printf '%s[38;5;%sm' "$ESC" "$1"; }
bg() { printf '%s[48;5;%sm' "$ESC" "$1"; }
RESET="$ESC[0m"
SEP_L=''   # U+E0B0
SUB_L=''   # U+E0B1
SEP_R=''   # U+E0B2
SUB_R=''   # U+E0B3

# ---- left segments: "bg;fg;text" -------------------------------------------
left=()

if [ "$(id -u)" = 0 ] || [ -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY" ]; then
  ctx_fg=3; [ "$(id -u)" = 0 ] && ctx_fg=1
  left+=("0;$ctx_fg;$(whoami)@$(hostname -s)")
fi

dir=$(j '.workspace.current_dir // .cwd')
[ -z "$dir" ] && dir=$(pwd)
if [ "$dir" = "$HOME" ]; then
  icon=''; name='~'                 # HOME_ICON
elif [[ "$dir" == "$HOME"/* ]]; then
  icon=''; name=${dir##*/}           # HOME_SUB_ICON
elif [ "$dir" = / ]; then
  icon=''; name=/                    # FOLDER_ICON
else
  icon=''; name=${dir##*/}
fi
left+=("4;254;$icon $name")

if branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null) \
  || branch=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  status=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null)
  staged=0; unstaged=0; untracked=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    x=${line:0:1}; y=${line:1:1}
    if [ "$x$y" = "??" ]; then untracked=1; continue; fi
    [ "$x" != " " ] && staged=1
    [ "$y" != " " ] && unstaged=1
  done <<<"$status"
  vcs=" $branch"                       # VCS_BRANCH_ICON
  if counts=$(git -C "$dir" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
    read -r behind ahead <<<"$counts"
    [ "$behind" -gt 0 ] && vcs+=" ⇣$behind"
    [ "$ahead" -gt 0 ] && vcs+=" ⇡$ahead"
  fi
  marks=""
  [ "$staged" = 1 ] && marks+="+"
  [ "$unstaged" = 1 ] && marks+="!"
  [ "$untracked" = 1 ] && marks+="?"
  [ -n "$marks" ] && vcs+=" $marks"
  vcs_bg=2; [ "$staged$unstaged" != 00 ] && vcs_bg=3   # VCS_CLEAN / VCS_MODIFIED_BACKGROUND
  left+=("$vcs_bg;0;$vcs")
fi

# ---- right segments ----------------------------------------------------------
right=()

[ -n "$CONDA_DEFAULT_ENV" ] && [ "$CONDA_DEFAULT_ENV" != base ] && right+=("4;0; $CONDA_DEFAULT_ENV")

model=$(j '.model.display_name')
effort=$(j '.effort.level')
[ -n "$model" ] && right+=("5;255;$model${effort:+ · $effort}")

ctx=$(j '.context_window.used_percentage | floor')
if [ -n "$ctx" ]; then
  filled=$(( (ctx * 10 + 50) / 100 )); (( filled > 10 )) && filled=10; (( filled < 0 )) && filled=0
  bar=""; for ((i = 0; i < 10; i++)); do (( i < filled )) && bar+="▓" || bar+="░"; done
  ctx_fg=2; (( ctx >= 50 )) && ctx_fg=3; (( ctx >= 80 )) && ctx_fg=1
  right+=("0;$ctx_fg;ctx $bar ${ctx}%")
fi

usage() {  # label, percent, reset epoch, date format
  [ -z "$2" ] && return
  local s="$1 $2%" t
  [ -n "$3" ] && t=$(date -d @"$3" "$4" 2>/dev/null) && [ -n "$t" ] && s+=" ↻$t"
  local c=3; (( $2 >= 80 )) && c=1
  right+=("0;$c;$s")
}
usage 5h "$(j '.rate_limits.five_hour.used_percentage | floor')" "$(j '.rate_limits.five_hour.resets_at')" +%H:%M
usage 7d "$(j '.rate_limits.seven_day.used_percentage | floor')" "$(j '.rate_limits.seven_day.resets_at')" "+%a %H:%M"


# ---- drawing -------------------------------------------------------------------
out="$(fg 240)╭─$RESET"
prev=""
for s in "${left[@]}"; do
  IFS=';' read -r b f t <<<"$s"
  if [ -z "$prev" ]; then
    out+="$(bg "$b")$(fg "$f") $t "
  elif [ "$prev" = "$b" ]; then
    out+="$(fg "$f")$SUB_L $t "
  else
    out+="$RESET$(bg "$b")$(fg "$prev")$SEP_L$RESET$(bg "$b")$(fg "$f") $t "
  fi
  out+="$RESET"
  prev=$b
done
[ -n "$prev" ] && out+="$(fg "$prev")$SEP_L$RESET"

draw_right() {
  local prev="" s b f t r=""
  for s in "${right[@]}"; do
    IFS=';' read -r b f t <<<"$s"
    if [ "$prev" = "$b" ]; then
      r+="$(bg "$b")$(fg 244)$SUB_R$(fg "$f") $t $RESET"
    else
      r+="${prev:+$(bg "$prev")}$(fg "$b")$SEP_R$RESET$(bg "$b")$(fg "$f") $t $RESET"
    fi
    prev=$b
  done
  printf '%s' "$r"
}

width() {  # visible columns: drop colour codes, count characters
  local plain
  plain=$(sed "s/$ESC\[[0-9;]*m//g" <<<"$1")
  echo "${#plain}"
}

# Fill the line like p10k's gap: ╭─ left ···· right ─╮, ending where the zsh prompt ends.
# Rightmost segments go first when the line does not fit.
suffix="$(fg 240)─╮$RESET"
cols=$(( ${COLUMNS:-80} - 1 ))   # zsh leaves the last column free
left_width=$(width "$out")
while :; do
  r=$(draw_right)
  gap=$(( cols - left_width - $(width "$r") - 2 ))
  (( gap >= 0 || ${#right[@]} == 0 )) && break
  unset 'right[-1]'
done

dots=""
if (( gap > 0 )); then
  printf -v dots '%*s' "$gap" ''
  dots=${dots// /·}
fi

printf '%s\n' "$out$(fg 240)$dots$RESET$r$suffix"
