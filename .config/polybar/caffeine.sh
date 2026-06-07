#!/usr/bin/env bash
# Caffeine / idle-inhibitor for i3 (X11 replacement for waybar's idle_inhibitor,
# which is a Wayland-only protocol). When ON, it disables the X screensaver and
# DPMS so the screen never blanks and xss-lock never auto-locks. When OFF, it
# restores the same timeouts the i3 config sets at startup (xset s 300 / dpms 600).
#
# Polybar usage:
#   exec        -> prints the current icon (called every `interval`)
#   click-left  -> `caffeine.sh toggle`
#
# State lives in XDG_RUNTIME_DIR, which is wiped on logout, so every fresh login
# starts OFF (matching the i3 config defaults). Icons/colours mirror the waybar
# module: 󰅶 green when active, 󰾪 red when inactive.
set -u

STATE="${XDG_RUNTIME_DIR:-/tmp}/caffeine.on"

ON_ICON="󰅶"
OFF_ICON="󰾪"
ON_COLOR="#40a02b"   # green  (waybar .activated)
OFF_COLOR="#e64553"  # red    (waybar .deactivated)

case "${1:-status}" in
    toggle)
        if [ -f "$STATE" ]; then
            rm -f "$STATE"
            xset s 300 300
            xset dpms 600 600 600
        else
            : > "$STATE"
            xset s off -dpms
        fi
        ;;
    status|*)
        if [ -f "$STATE" ]; then
            printf '%%{F%s}%s%%{F-}\n' "$ON_COLOR" "$ON_ICON"
        else
            printf '%%{F%s}%s%%{F-}\n' "$OFF_COLOR" "$OFF_ICON"
        fi
        ;;
esac
