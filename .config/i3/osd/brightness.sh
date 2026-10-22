#!/usr/bin/env bash
# Brightness OSD for i3/X11 — dunst progress bar, updates one popup in place.
# Acts on the output of the focused workspace: laptop panel via brightnessctl,
# external monitor via ddcutil (DDC/CI over I2C). `xrandr --brightness` is
# unusable here: gammastep owns the gamma ramp and wipes it within a second.
output=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).output')

if [[ $output == eDP* ]]; then
    case "$1" in
        up) brightnessctl set +1% >/dev/null ;;
        down) brightnessctl set 1%- >/dev/null ;;
    esac
    # brightnessctl -m: class,subsystem,current,percent,max  -> field 4 is "NN%"
    pct=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
else
    # Bus from the DRM connector's sysfs ddc link: --bus skips ddcutil's
    # full-bus probe (1.8s -> 0.1s per call).
    # ponytail: takes the first connected non-eDP connector; match the xrandr
    # name (HDMI-1) to the DRM one (HDMI-A-1) if a second external shows up.
    for c in /sys/class/drm/card*-*; do
        [[ $c == *eDP* || $(<"$c/status") != connected ]] && continue
        bus=$(readlink "$c/ddc") && break
    done
    [[ -n $bus ]] || exit 1
    # Drop key presses while a DDC write is in flight.
    exec 9>"${XDG_RUNTIME_DIR:-/tmp}/brightness-ddc.lock"
    flock -n 9 || exit 0
    ddc=(ddcutil --bus "${bus##*i2c-}")
    case "$1" in
        up) "${ddc[@]}" setvcp 10 + 1 ;;
        down) "${ddc[@]}" setvcp 10 - 1 ;;
    esac
    # -t getvcp 10: "VCP 10 C <current> <max>"
    read -r _ _ _ cur max < <("${ddc[@]}" -t getvcp 10 2>/dev/null)
    [[ -n $max ]] && pct=$((cur * 100 / max))
fi
pct=${pct:-0}

dunstify -a osd -u low -t 1200 \
    -h string:x-dunst-stack-tag:osd-brightness \
    -h int:value:"$pct" "󰃠   Brightness   ${pct}%  ($output)"
