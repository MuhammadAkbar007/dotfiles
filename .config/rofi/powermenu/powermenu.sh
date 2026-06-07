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

# -selected-row 2 -> pre-select Lock (the middle icon).
chosen="$(echo -e "$options" | rofi -dmenu -i -selected-row 2 \
    -p "$uptime_str" -theme "$theme")"

case "$chosen" in
    "$shutdown") systemctl poweroff ;;
    "$reboot")   systemctl reboot ;;
    "$lock")     loginctl lock-session ;;   # xss-lock -> ~/.config/i3/lock.sh
    "$suspend")  systemctl suspend ;;
    "$logout")   i3-msg exit ;;
esac
