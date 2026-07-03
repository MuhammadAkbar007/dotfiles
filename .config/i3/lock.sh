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
