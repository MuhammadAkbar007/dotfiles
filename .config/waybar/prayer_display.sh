#!/bin/bash

output=$(bash ~/dotfiles/.config/waybar/prayer.sh)

echo "🕌 Prayer Times"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "$output" | jq -r '.tooltip' | sed 's/\\n/\n/g'
echo "━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$output" | jq -r '.text' | sed 's/\\n/\n/g'
