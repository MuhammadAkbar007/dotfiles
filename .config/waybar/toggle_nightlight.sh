#!/bin/bash

if [ "$1" == "status" ]; then
    if pgrep wlsunset > /dev/null; then
        echo '{"text": "󰖔", "class": "active", "tooltip": "Night Light: On"}'
    else
        echo '{"text": "󰖔", "class": "inactive", "tooltip": "Night Light: Off"}'
    fi
    exit 0
fi

# Logic for toggling (on-click)
if pgrep wlsunset > /dev/null; then
    pkill wlsunset
else
    wlsunset -l 41.005 -L 71.794 -T 6500 -t 4000 &
fi

# Refresh Waybar
pkill -RTMIN+10 waybar
