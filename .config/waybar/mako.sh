#!/bin/bash

# Get Mako status
# We check the modes and the history count
MODES=$(makoctl mode)
HAS_NOTIFS=$(makoctl history | grep -c '"id":')

# Determine the state
if [[ "$MODES" == *"dnd"* ]]; then
    if [ "$HAS_NOTIFS" -gt 0 ]; then
        STATE="dnd-notification"
    else
        STATE="dnd-none"
    fi
else
    if [ "$HAS_NOTIFS" -gt 0 ]; then
        STATE="notification"
    else
        STATE="none"
    fi
fi

# Output JSON for Waybar
echo "{\"alt\": \"$STATE\", \"class\": \"$STATE\"}"
