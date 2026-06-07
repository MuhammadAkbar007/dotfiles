#!/usr/bin/env bash
# Volume OSD for i3/X11 — SwayOSD replacement using a dunst progress bar.
# The x-dunst-stack-tag makes repeated changes update one popup in place.
sink="@DEFAULT_SINK@"

case "$1" in
    up)
        pactl set-sink-mute "$sink" 0
        pactl set-sink-volume "$sink" +1%
        ;;
    down)
        pactl set-sink-mute "$sink" 0
        pactl set-sink-volume "$sink" -1%
        ;;
    mute) pactl set-sink-mute "$sink" toggle ;;
esac

vol=$(pactl get-sink-volume "$sink" 2>/dev/null | grep -oP '\d+(?=%)' | head -1)
muted=$(pactl get-sink-mute "$sink" 2>/dev/null | grep -oP '(?<=Mute: )\w+')
vol=${vol:-0}

if [ "$muted" = "yes" ]; then
    dunstify -a osd -u low -t 1200 \
        -h string:x-dunst-stack-tag:osd-volume \
        -h int:value:0 "󰝟   Muted"
else
    if [ "$vol" -le 0 ]; then
        g="󰕿"
    elif [ "$vol" -le 50 ]; then
        g="󰖀"
    else g="󰕾"; fi
    bar=$vol
    [ "$bar" -gt 100 ] && bar=100 # dunst progress bar maxes at 100
    dunstify -a osd -u low -t 1200 \
        -h string:x-dunst-stack-tag:osd-volume \
        -h int:value:"$bar" "$g   Volume   ${vol}%"
fi
