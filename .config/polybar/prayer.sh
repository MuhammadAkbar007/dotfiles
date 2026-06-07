#!/usr/bin/env bash
# Polybar prayer module label. Reuses the same JSON producer as the waybar
# module (~/.config/waybar/prayer.sh -> namozvaqti), but polybar can't parse
# Waybar JSON, so we extract just the `.text` field with jq. The \uXXXX Nerd
# Font glyphs in the JSON are decoded to UTF-8 by `jq -r`.
#
# Polybar has no hover tooltips, so the prayer-times list (the JSON `.tooltip`)
# is shown via the click action instead (see prayer_popup.sh / config.ini).
set -u

out="$(~/.config/waybar/prayer.sh 2>/dev/null)"
[ -n "$out" ] && printf '%s\n' "$out" | jq -r '.text // empty'
