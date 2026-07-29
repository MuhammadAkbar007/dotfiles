#!/usr/bin/env bash
# Brightness OSD for i3/X11 — dunst progress bar, updates one popup in place.
# Laptop panel only. External monitors have no /sys/class/backlight entry, and
# the software substitute (`xrandr --output X --brightness`) is unusable here:
# gammastep owns the XRandR gamma ramp and reapplies it on every RandR change
# event, so it wipes the value within a second. Confirmed by SIGSTOPing
# gammastep — the value sticks only while it's paused.
# Use the monitor's own OSD buttons. For software control it'd have to be
# ddcutil (I2C/DDC-CI, a separate channel gammastep can't reach), which costs a
# package plus i2c group membership — deliberately not taken.
case "$1" in
    up) brightnessctl set +1% >/dev/null ;;
    down) brightnessctl set 1%- >/dev/null ;;
esac

# brightnessctl -m: class,subsystem,current,percent,max  -> field 4 is "NN%"
pct=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
pct=${pct:-0}

dunstify -a osd -u low -t 1200 \
    -h string:x-dunst-stack-tag:osd-brightness \
    -h int:value:"$pct" "󰃠   Brightness   ${pct}%"
