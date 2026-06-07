#!/usr/bin/env bash
# Emoji picker: bemoji + rofi.
#
# BEMOJI_PICKER_CMD pins rofi as the menu. Without it bemoji auto-detects from an
# UNORDERED list and tends to grab wofi, which is Wayland-only and fails silently
# on X11 — that was the original "it didn't work". (Note: BEMOJI_DEFAULT_CMD is a
# different knob — the output action — not the picker.)
#
# The choice is copied to the clipboard via xclip (-c); paste with Ctrl+V. It
# also lands in cliphist, so it shows up in the polybar clipboard module. For
# "type straight into the focused field" instead, install xdotool and swap
# `bemoji -c` for `bemoji -t`.
#
# A wrapper script keeps the i3 binding free of inline quoting, which i3's config
# parser mangles (it strips the quotes around values containing spaces).
export BEMOJI_PICKER_CMD="rofi -dmenu -i -p 🔍"
# -t types the emoji into the focused field (xdotool on X11); -c also copies it
# to the clipboard so it stays in cliphist / the polybar clip module; -n drops
# the trailing newline.
exec bemoji -t -c -n
