#!/usr/bin/env bash
# Status line in the style of ~/.p10k.zsh (rainbow powerline, nerdfont-v3):
#   left   dir (last folder only, as
#          POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_last), vcs (green clean,
#          yellow modified; + staged, ! unstaged, ? untracked, ⇣⇡ behind/ahead)
#   right  model · effort, context, tokens, and provider quota
# The Claude segments come from the old ~/.claude/statusline.sh, drawn as p10k segments.
# On narrow terminals the line gets more compact, level by level (see build),
# and only then drops right segments, rightmost first.
input=$(cat)
j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

ESC=$'\e'
fg() { printf '%s[38;5;%sm' "$ESC" "$1"; }
bg() { printf '%s[48;5;%sm' "$ESC" "$1"; }
RESET="$ESC[0m"
SEP_L=$'\uE0B0'   # U+E0B0
SUB_L=$'\uE0B1'   # U+E0B1
SEP_R=$'\uE0B2'   # U+E0B2
SUB_R=$'\uE0B3'   # U+E0B3
BRANCH=$'\uF126'    # VCS_BRANCH_ICON
PYTHON=$'\uE73C'    # PYTHON_ICON

# ---- data (gathered once) ----------------------------------------------------

dir=$(j '.workspace.current_dir // .cwd')
[ -z "$dir" ] && dir=$(pwd)
if [ "$dir" = "$HOME" ]; then
  icon=$'\uF015'; name='~'                 # HOME_ICON
elif [[ "$dir" == "$HOME"/* ]]; then
  icon=$'\uF07C'; name=${dir##*/}    # HOME_SUB_ICON
elif [ "$dir" = / ]; then
  icon=$'\uF115'; name=/                    # FOLDER_ICON
else
  icon=$'\uF115'; name=${dir##*/}
fi

branch=""
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
  ab=""
  if counts=$(git -C "$dir" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
    read -r behind ahead <<<"$counts"
    [ "$behind" -gt 0 ] && ab+=" ⇣$behind"
    [ "$ahead" -gt 0 ] && ab+=" ⇡$ahead"
  fi
  marks=""
  [ "$staged" = 1 ] && marks+="+"
  [ "$unstaged" = 1 ] && marks+="!"
  [ "$untracked" = 1 ] && marks+="?"
  vcs_bg=2; [ "$staged$unstaged" != 00 ] && vcs_bg=3   # VCS_CLEAN / VCS_MODIFIED_BACKGROUND
else
  branch=""
fi

conda=""
[ -n "$CONDA_DEFAULT_ENV" ] && [ "$CONDA_DEFAULT_ENV" != base ] && conda=$CONDA_DEFAULT_ENV

model=$(j '.model.display_name')
model_id=$(j '.model.id')
thread=$(j '.session_name')
tokens=$(j '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)')
codex_model=""
quota_stale=""
effort=$(j '.effort.level')
ctx=$(j '.context_window.used_percentage | floor')
u5_pct=$(j '.rate_limits.five_hour.used_percentage | floor')
u5_at=$(j '.rate_limits.five_hour.resets_at')
u7_pct=$(j '.rate_limits.seven_day.used_percentage | floor')
u7_at=$(j '.rate_limits.seven_day.resets_at')
if [[ "$model_id" == gpt-* || "$model_id" == o[0-9]* ]]; then
  quota=$(python3 "$HOME/.claude/codex-quota.py" 2>/dev/null)
  codex_model=1
  u5_pct=$(jq -r '.five_hour.used_percentage // empty | floor' <<<"$quota" 2>/dev/null)
  u5_at=$(jq -r '.five_hour.resets_at // empty' <<<"$quota" 2>/dev/null)
  u7_pct=$(jq -r '.seven_day.used_percentage // empty | floor' <<<"$quota" 2>/dev/null)
  u7_at=$(jq -r '.seven_day.resets_at // empty' <<<"$quota" 2>/dev/null)
  [ "$(jq -r '.stale // false' <<<"$quota" 2>/dev/null)" = true ] && quota_stale='~'
fi

trunc() {  # text, max chars: keep the start, end with …
  if (( ${#1} > $2 )); then printf '%s…' "${1:0:$(( $2 - 1 ))}"; else printf '%s' "$1"; fi
}

# ---- segments per compactness level: "bg;fg;text" ----------------------------
#   0  full
#   1  no reset times, 5-cell context bar, short branch
#   2  no bar, model family + effort initial, no ⇣⇡ counts, shorter names
#   3  same as 2 without the ╭─ ─╮ frame and the · gap
build() {
  local lvl=$1 vcs s c bar filled i
  left=(); right=()

  if (( lvl >= 2 )); then left+=("4;254;$icon $(trunc "$name" 16)"); else left+=("4;254;$icon $name"); fi

  if [ -n "$branch" ]; then
    case $lvl in
      0) vcs="$BRANCH $branch$ab" ;;
      1) vcs="$BRANCH $(trunc "$branch" 24)$ab" ;;
      *) vcs="$BRANCH $(trunc "$branch" 14)" ;;
    esac
    [ -n "$marks" ] && vcs+=" $marks"
    left+=("$vcs_bg;0;$vcs")
  fi

  [ -n "$thread" ] && (( lvl < 2 )) && left+=("0;250;$(trunc "$thread" 24)")

  [ -n "$conda" ] && right+=("4;0;$PYTHON $conda")

  if [ -n "$model" ]; then
    if (( lvl >= 2 )); then
      case $effort in
        low) e=L ;; medium) e=M ;; high) e=H ;; xhigh) e=XH ;; max) e=MAX ;; *) e=$effort ;;
      esac
      right+=("5;255;${model%% *}${e:+ $e}")
    else
      right+=("5;255;$model${effort:+ · $effort}")
    fi
  fi

  if [ -n "$codex_model" ]; then
    usage "Codex 5h$quota_stale" "$u5_pct" "$u5_at" +%H:%M 0
    [ -z "$u5_pct" ] && right+=("0;244;Codex 5h --")
    usage "7d$quota_stale" "$u7_pct" "$u7_at" "+%a %H:%M" 0
    [ -z "$u7_pct" ] && right+=("0;244;7d --")
  fi

  if [ -n "$ctx" ]; then
    c=2; (( ctx >= 50 )) && c=3; (( ctx >= 80 )) && c=1
    if (( lvl >= 2 )); then
      right+=("0;$c;ctx ${ctx}%")
    else
      local cells=10; (( lvl >= 1 )) && cells=5
      filled=$(( (ctx * cells + 50) / 100 )); (( filled > cells )) && filled=$cells; (( filled < 0 )) && filled=0
      bar=""; for ((i = 0; i < cells; i++)); do (( i < filled )) && bar+="▓" || bar+="░"; done
      right+=("0;$c;ctx $bar ${ctx}%")
    fi
  fi

  [ -n "$tokens" ] && right+=("0;250;tok $tokens")
  if [ -z "$codex_model" ]; then
    usage 5h "$u5_pct" "$u5_at" +%H:%M "$lvl"
    usage 7d "$u7_pct" "$u7_at" "+%a %H:%M" "$lvl"
  fi
}

usage() {  # label, percent, reset epoch, date format, level
  [ -z "$2" ] && return
  local s="$1 $2%" t
  (( $5 == 0 )) && [ -n "$3" ] && t=$(date -d @"$3" "$4" 2>/dev/null) && [ -n "$t" ] && s+=" ↻$t"
  local c=3; (( $2 >= 80 )) && c=1
  right+=("0;$c;$s")
}

# ---- drawing -------------------------------------------------------------------
draw_left() {
  local prev="" s b f t l=""
  for s in "${left[@]}"; do
    IFS=';' read -r b f t <<<"$s"
    if [ -z "$prev" ]; then
      l+="$(bg "$b")$(fg "$f") $t "
    elif [ "$prev" = "$b" ]; then
      l+="$(fg "$f")$SUB_L $t "
    else
      l+="$RESET$(bg "$b")$(fg "$prev")$SEP_L$RESET$(bg "$b")$(fg "$f") $t "
    fi
    l+="$RESET"
    prev=$b
  done
  [ -n "$prev" ] && l+="$(fg "$prev")$SEP_L$RESET"
  printf '%s' "$l"
}

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
# Try each compactness level until the line fits; at the last level drop
# rightmost segments until it does.
cols=$(( ${COLUMNS:-80} - 1 ))   # zsh leaves the last column free
(( cols < 1 )) && cols=79
for lvl in 0 1 2 3; do
  build "$lvl"
  if (( lvl < 3 )); then
    prefix="$(fg 240)╭─$RESET"; suffix="$(fg 240)─╮$RESET"; frame=4
  else
    prefix=""; suffix=""; frame=0
  fi
  l=$(draw_left)
  left_width=$(width "$l")
  while :; do
    r=$(draw_right)
    gap=$(( cols - left_width - $(width "$r") - frame ))
    (( gap >= 0 || lvl < 3 || ${#right[@]} == 0 )) && break
    unset 'right[-1]'
  done
  (( gap >= 0 )) && break
done

dots=""
if (( gap > 0 )); then
  printf -v dots '%*s' "$gap" ''
  if (( lvl < 3 )); then dots=${dots// /·}; fi
fi

printf '%s\n' "$prefix$l$(fg 240)$dots$RESET$r$suffix"

