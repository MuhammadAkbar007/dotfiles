#!/usr/bin/env bash
# Round applet-style rofi power menu (dctxmei/rofi-themes "circle", adapted).
# Self-contained: five circular icons in a row. Actions are wired to THIS i3
# setup (loginctl lock via xss-lock, i3-msg exit, systemctl). No external
# style.sh / bin helpers from the original repo are needed.
set -u

theme="$HOME/.config/rofi/powermenu/rounded.rasi"

# Power glyphs (Ubuntu Nerd Font, Material Design). Order matters: it sets the
# left-to-right layout and the -selected-row index below.
shutdown="󰐥"
reboot="󰜉"
lock="󰌾"
suspend="󰒲"
logout="󰍃"

uptime_str="$(uptime -p 2>/dev/null | sed 's/^up //')"

options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

# Open the menu centered under the mouse (the icon you clicked) instead of the
# screen corner. The theme is north-anchored, so x-offset shifts the window's
# centre from screen centre: xoff = mouse_x - screen_w/2, clamped to keep the
# menu fully on-screen (10px margins). Width is read from the theme.
eval "$(xdotool getmouselocation --shell)"          # sets X, Y, ...
sw=$(xdotool getdisplaygeometry | cut -d' ' -f1)
ww=$(grep -oE 'width:[[:space:]]*[0-9]+' "$theme" | grep -oE '[0-9]+' | head -1)
ww=${ww:-400}
xoff=$(( X - sw / 2 ))
lim=$(( sw / 2 - ww / 2 - 10 ))
(( xoff >  lim )) && xoff=$lim
(( xoff < -lim )) && xoff=$(( -lim ))

# -selected-row 2 -> pre-select Lock (the middle icon). The offset is injected
# via -theme-str (NOT -xoffset): the theme's own window{x-offset} overrides the
# CLI -xoffset, but -theme-str is applied on top of the theme and wins.
chosen="$(echo -e "$options" | rofi -dmenu -i -selected-row 2 \
    -p "$uptime_str" -theme "$theme" -theme-str "window { x-offset: ${xoff}px; }")"

case "$chosen" in
    "$shutdown") systemctl poweroff ;;
    "$reboot")   systemctl reboot ;;
    "$lock")     loginctl lock-session ;;   # xss-lock -> ~/.config/i3/lock.sh
    "$suspend")  systemctl suspend ;;
    "$logout")   i3-msg exit ;;
esac
