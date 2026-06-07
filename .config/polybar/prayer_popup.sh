#!/usr/bin/env bash
# Opened by the polybar prayer module's click action (in a kitty window). Shows
# the full prayer-times table (the waybar tooltip equivalent) and waits for a
# keypress so the window doesn't vanish. Kept as a script to avoid quoting the
# whole thing inside polybar's click-left.
~/.config/waybar/prayer_display.sh
echo
echo "(Press Enter to close...)"
read -r
