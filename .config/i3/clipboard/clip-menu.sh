#!/usr/bin/env bash
# $mod+v / polybar left-click — browse copyq clipboard history in rofi (with
# image thumbnails) and copy the chosen entry back via `copyq select`.
#
# Detection is by reading (copyq's dataFormats() is unreliable in this build):
# a row whose text/plain is non-empty is text; otherwise a row with image/png
# bytes is an image. Image rows get a cached PNG thumbnail keyed by content hash
# and shown via rofi's "text\0icon\x1f<path>" protocol. We pick with -format i;
# because the menu emits exactly one line per row in order, the rofi index ==
# the copyq row, so `copyq select <i>` copies that row (text or image) back.

THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/copyq-thumbs"
mkdir -p "$THUMB_DIR"

# Self-heal: plain copyq commands don't auto-start the server, so make sure the
# headless daemon is up before we query it (no-op if already running).
copyq --start-server eval 'true' >/dev/null 2>&1

n="$(copyq count 2>/dev/null)"
[[ "$n" =~ ^[0-9]+$ ]] || exit 0

# Empty history: still open rofi with an explicit notice so it's clear the
# history is empty (rather than the menu silently not appearing). -no-custom
# stops a typed entry from being treated as a selection; we ignore the result.
if [ "$n" -eq 0 ]; then
  printf '󰅑 Clipboard history is empty\n' \
    | rofi -dmenu -i -no-custom -p "󰅍 Clipboard" -theme-str 'window { width: 55%; }' >/dev/null
  exit 0
fi

build_menu() {
  local i text disp imgfile tmp hash thumb
  for ((i = 0; i < n; i++)); do
    text="$(copyq read text/plain "$i" 2>/dev/null)"
    if [ -n "$text" ]; then
      disp="${text//$'\n'/ }"; disp="${disp//$'\t'/ }"
      # A text row that is itself a path/URI to an image file -> show that image.
      imgfile="${disp#file://}"
      if [[ "$imgfile" =~ \.(png|jpe?g|gif|bmp|webp|svg)$ ]] && [ -f "$imgfile" ]; then
        printf '%s\0icon\x1f%s\n' "$disp" "$imgfile"
      else
        printf '%s\n' "$disp"
      fi
    else
      # No text: try image bytes. Write to a temp file (never hold binary in a
      # shell var — NUL bytes get mangled), hash it, cache a scaled thumbnail.
      tmp="$(mktemp)"
      copyq read image/png "$i" 2>/dev/null > "$tmp"
      if [ -s "$tmp" ]; then
        hash="$(sha1sum "$tmp" | cut -d' ' -f1)"
        thumb="$THUMB_DIR/$hash.png"
        [ -f "$thumb" ] || convert "$tmp" -resize 128x128 "$thumb" 2>/dev/null || cp "$tmp" "$thumb"
        printf '%s\0icon\x1f%s\n' "󰋩 Image" "$thumb"
      else
        # Neither text nor image — emit a placeholder so indices stay aligned.
        printf '%s\n' "[binary]"
      fi
      rm -f "$tmp"
    fi
  done
}

idx="$(build_menu | rofi -dmenu -i -show-icons -format i \
        -p "󰅍 Clipboard" -theme-str 'window { width: 55%; }')" || exit 0
[ -z "$idx" ] && exit 0

# copyq handles the mime type (text or image) when copying the row back.
copyq select "$idx" 2>/dev/null
