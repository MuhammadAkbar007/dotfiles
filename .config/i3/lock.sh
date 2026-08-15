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

# Full virtual screen (union of all monitors, e.g. laptop + HDMI side by
# side) so the canvas covers every output, not just the first one xrandr
# lists.
canvas="$(xdpyinfo 2>/dev/null | awk '/dimensions:/{print $2}')"
canvas="${canvas:-1920x1080}"

mkdir -p "$(dirname "$img")"
# Composite the full image onto EACH monitor's own rectangle (matching
# `feh --bg-fill`'s per-output behaviour), not one image stretched across
# the whole virtual screen split between monitors. Layout can change
# between locks (external monitor plugged/unplugged), so always rebuild
# rather than trying to cache-invalidate on source mtime alone.
convert -size "$canvas" xc:"#1e1e2e" "$img" 2>/dev/null
tmp="$(mktemp --suffix=.png)"
trap 'rm -f "$tmp"' EXIT
while read -r geom; do
    wh="${geom%%+*}"     # e.g. 1920x1080
    off="+${geom#*+}"    # e.g. +1920+0
    convert "$src" -resize "${wh}^" -gravity center -extent "$wh" "$tmp" 2>/dev/null
    convert "$img" "$tmp" -geometry "$off" -composite "$img" 2>/dev/null
done < <(xrandr --query 2>/dev/null | awk '/ connected/{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) print $i}')

# Pomodoro: freeze to the next work session on lock, auto-start it on unlock.
# lock.sh is the single choke point for EVERY lock (rofi power menu, polybar
# power icon, idle/DPMS via xset, and pre-suspend), so hooking here covers them
# all. Best-effort: a missing or failing pomodoro must never block the lock.
pctl="$HOME/akbarDev/pet-projects/pomodoro/pomodoroctl.py"
[ -f "$pctl" ] && python3 "$pctl" lock 2>/dev/null || true

# -n: do not fork (required by xss-lock). -e: ignore empty password.
# Fall back to a solid Catppuccin-base colour if the image can't be produced,
# so a lock NEVER silently fails to appear (e.g. before suspend).
#
# NOTE: no `exec` here — we must regain control after i3lock exits to run the
# unlock hook. i3lock -n stays in the foreground for the whole locked period,
# so xss-lock's transferred sleep-lock fd remains held until this script
# returns (i.e. after unlock), which is exactly what we want.
if [ -f "$img" ]; then
    i3lock -n -e -i "$img" -c 1e1e2e
else
    i3lock -n -e -c 1e1e2e
fi

# Reached only after the correct password unlocks i3lock. Start the primed
# work session counting.
[ -f "$pctl" ] && python3 "$pctl" unlock 2>/dev/null || true
