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
#
# IMPORTANT: the status path re-asserts the xset state every tick (idempotent,
# only acts on a real mismatch). Setting xset once on toggle is NOT enough — i3's
# `exec_always xset s/dpms` lines re-enable blanking on every $mod+Shift+r, which
# would silently un-inhibit the screen while the icon still showed green. This
# self-heals that within one interval.
set -u

STATE="${XDG_RUNTIME_DIR:-/tmp}/caffeine.on"

ON_ICON="󰅶"
OFF_ICON="󰾪"
ON_COLOR="#40a02b"   # green  (waybar .activated)
OFF_COLOR="#e64553"  # red    (waybar .deactivated)

# Enforce the xset state that matches the state file — but only when it actually
# differs, so we never reset the idle counter or spam xset in steady state.
apply() {
    local dpms_disabled=no
    xset q 2>/dev/null | grep -q 'DPMS is Disabled' && dpms_disabled=yes

    if [ -f "$STATE" ]; then
        # inhibit: screensaver + DPMS off
        [ "$dpms_disabled" = no ] && xset s off -dpms
    else
        # normal: restore the i3 startup timeouts (so OFF blanks + xss-lock locks)
        [ "$dpms_disabled" = yes ] && { xset s 300 300; xset dpms 600 600 600; }
    fi
}

print_icon() {
    if [ -f "$STATE" ]; then
        printf '%%{F%s}%s%%{F-}\n' "$ON_COLOR" "$ON_ICON"
    else
        printf '%%{F%s}%s%%{F-}\n' "$OFF_COLOR" "$OFF_ICON"
    fi
}

case "${1:-status}" in
    toggle)
        if [ -f "$STATE" ]; then
            rm -f "$STATE"
        else
            : > "$STATE"
        fi
        apply
        print_icon
        ;;
    status|*)
        apply
        print_icon
        ;;
esac
