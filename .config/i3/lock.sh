#!/usr/bin/env bash
# i3/X11 screen locker (replaces sway's swaylock). Run by xss-lock, which is
# triggered by `loginctl lock-session` (polybar power menu) and before suspend.
#
# Uses plain i3lock with your dark wallpaper scaled to the screen. Plain i3lock
# has no ring/clock/blur; for that, build i3lock-color (see the i3 config note)
# and swap the i3lock line below for one with --ring-color=df8e1dff etc.
set -u

src="$HOME/Pictures/desktop_wallpapers/dark/treeBreeze.jpg"
img="$HOME/.cache/i3lock/lock.png"

# Detect the active resolution so the image fills the screen exactly.
res="$(xrandr 2>/dev/null | awk 'match($0,/[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/){s=substr($0,RSTART,RLENGTH); sub(/\+.*/,"",s); print s; exit}')"
res="${res:-1920x1080}"

mkdir -p "$(dirname "$img")"
# (Re)generate the scaled lock image only when missing or the source changed.
if [ ! -f "$img" ] || [ "$src" -nt "$img" ]; then
    convert "$src" -resize "${res}^" -gravity center -extent "$res" "$img" 2>/dev/null
fi

# -n: do not fork (required by xss-lock). -e: ignore empty password.
# Fall back to a solid Catppuccin-base colour if the image can't be produced,
# so a lock NEVER silently fails to appear (e.g. before suspend).
if [ -f "$img" ]; then
    exec i3lock -n -e -i "$img" -c 1e1e2e
else
    exec i3lock -n -e -c 1e1e2e
fi
