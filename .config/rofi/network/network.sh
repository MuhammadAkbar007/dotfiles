#!/usr/bin/env bash
# Network applet (dctxmei/rofi-themes, adapted) — wraps NetworkManager.
# Three actions: toggle Wi-Fi, open nmtui (kitty), open nm-connection-editor.
# Uses only tools present on this machine (nmcli/nmtui/nm-connection-editor;
# no iwgetid/bmon/termite from the original).
set -u

theme="$HOME/.config/rofi/network/network.rasi"

radio="$(nmcli radio wifi 2>/dev/null)"   # "enabled" / "disabled" (fast)
# SSID = name of the active wireless connection. We deliberately AVOID
# `nmcli dev wifi`, which waits on a Wi-Fi *scan* and can block ~6s when the
# scan cache is stale (that was the "opens after multiple clicks" lag). Reading
# the active connection is instant and needs no scan.
ssid="$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2 ~ /wireless/{print $1; exit}')"

# First tile is the Wi-Fi toggle; reflect state in its icon + row highlight.
active=""; urgent=""
if [ "$radio" = "enabled" ] && [ -n "$ssid" ]; then
    wifi="󰖩"            # connected
    prompt="$ssid"
    active="-a 0"        # highlight toggle row green
elif [ "$radio" = "enabled" ]; then
    wifi="󰖩"            # on but not connected
    prompt="Not connected"
    urgent="-u 0"
else
    wifi="󰖪"            # wifi off
    prompt="Wi-Fi off"
    urgent="-u 0"
fi

tui="󰆍"      # nmtui (terminal)
editor="󰒓"   # nm-connection-editor (GUI)

options="$wifi\n$tui\n$editor"

chosen="$(echo -e "$options" | rofi -dmenu -i -selected-row 0 \
    -p "$prompt" $active $urgent -theme "$theme")"

case "$chosen" in
    "$wifi")
        if [ "$radio" = "enabled" ]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    "$tui")    kitty -e nmtui ;;
    "$editor") nm-connection-editor ;;
esac
