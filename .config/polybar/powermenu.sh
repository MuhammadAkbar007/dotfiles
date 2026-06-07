#!/usr/bin/env bash
# rofi power menu for polybar (i3)

options="\
 Lock
 Logout
 Suspend
 Reboot
 Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" \
    -theme-str 'window {width: 220px;} listview {lines: 5;}')

case "${chosen}" in
    *Lock)     loginctl lock-session ;;   # needs a locker (i3lock/xss-lock) configured
    *Logout)   i3-msg exit ;;
    *Suspend)  systemctl suspend ;;
    *Reboot)   systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
