#!/usr/bin/env bash
# i3/X11 screenshots.
#   screen : whole screen -> save to ~/Pictures/Screenshots + clipboard + notify(open)
#   area   : select a region -> save + clipboard + notify(open)
#   copy   : select a region -> clipboard only -> "copied" notify
#
# Region selection uses flameshot when available: it dims everything OUTSIDE the
# selection (the slurp "spotlight" look) and keeps the selection bright, plus a
# live size readout / magnifier. If flameshot is missing it falls back to the
# old slop + maim path (gold outline), so screenshots never break.
#
# Notifications use a clickable "Open" action (dunst do_action on left-click),
# mirroring the sway `notify-send --action=default` behaviour.

mode="${1:-screen}"
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
ts=$(date '+%Y-%m-%d_T_%H:%M:%S')
cheese="$HOME/dotfiles/.icons/candy-icons-master/apps/scalable/cheese.svg"

notify_open() {  # $1 = saved file
  local action
  action=$(dunstify -a screenshot "Screenshot captured" "Click to open" \
            -i "$1" -A "default,Open" -t 5000)
  [ "$action" = "default" ] && xdg-open "$1"
}

have_flameshot() { command -v flameshot >/dev/null 2>&1; }

# slop fallback: gold border (#df8e1d), exits non-zero on cancel (Esc/right-click).
slop_region() { slop -b 3 -c 0.875,0.557,0.114,0.9 -f "%g"; }

# Capture a selected region to $1 (a file path). Returns non-zero / empty file
# if the user cancelled. flameshot --raw streams the PNG to stdout on accept.
capture_region_to() {  # $1 = dest file
  if have_flameshot; then
    flameshot gui --raw > "$1" 2>/dev/null
    [ -s "$1" ] || { rm -f "$1"; return 1; }
  else
    local geom
    geom=$(slop_region) || return 1
    [ -z "$geom" ] && return 1
    maim --hidecursor -g "$geom" "$1" || return 1
  fi
}

case "$mode" in
  screen)
    file="$dir/$ts.png"
    maim --hidecursor "$file" || exit 1
    xclip -selection clipboard -t image/png -i "$file"
    notify_open "$file"
    ;;

  area)
    file="$dir/${ts}.png"
    capture_region_to "$file" || exit 0     # cancelled -> no screenshot
    xclip -selection clipboard -t image/png -i "$file"
    notify_open "$file"
    ;;

  copy)
    tmp=$(mktemp --suffix=.png)
    if capture_region_to "$tmp"; then
      xclip -selection clipboard -t image/png -i "$tmp"
      dunstify -a screenshot "Screenshot copied" "Region copied to clipboard" \
        -i "$cheese" -t 5000
    fi
    rm -f "$tmp"
    ;;

  *)
    echo "usage: screenshot.sh {screen|area|copy}" >&2
    exit 2
    ;;
esac
