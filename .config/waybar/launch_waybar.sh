#!/bin/bash

# Kill only the EXACT process named 'waybar'
# -x ensures it doesn't kill 'launch_waybar.sh'
pkill -x waybar
killall -q swaync-client

# Wait for it to fully shut down
while pgrep -x waybar >/dev/null; do sleep 0.1; done

# Start Waybar
waybar &
