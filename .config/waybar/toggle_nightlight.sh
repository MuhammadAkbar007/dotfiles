#!/bin/bash

# Path to the binary
BIN="wlsunset"

if [ "$1" == "status" ]; then
    if pgrep "$BIN" > /dev/null; then
		echo '{"text": "󰖔", "class": "active", "tooltip": "Night Light: Active (Auto-transitioning)"}'
    else
		echo '{"text": "󰖙", "class": "inactive", "tooltip": "Night Light: Inactive"}'
    fi
    exit 0
fi

# Logic for toggling (on-click)
if pgrep "$BIN" > /dev/null; then
    pkill "$BIN"
else
    wlsunset -l 41.005 -L 71.794 -T 6500 -t 4000 &
fi

# Refresh Waybar
pkill -RTMIN+10 waybar
