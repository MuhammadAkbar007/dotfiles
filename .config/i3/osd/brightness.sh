#!/usr/bin/env bash
# Brightness OSD for i3/X11 — dunst progress bar, updates one popup in place.
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
