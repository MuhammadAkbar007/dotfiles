#!/usr/bin/env bash
# Polybar label: the most recent clipboard entry, image-aware and truncated.
max=40
out=$(cliphist list 2>/dev/null | head -n1 \
  | sed 's/\[\[ binary data.*\]\]/󰋩 Image/' \
  | cut -f2-)
out="${out//$'\t'/ }"   # flatten stray tabs ($() already trimmed the newline)

[ -z "$out" ] && { echo "Empty"; exit 0; }

# If the copied text is a path/URI to an image file, mark it with the image
# glyph so it reads as an image, not just a path string.
case "${out#file://}" in
  *.png|*.jpg|*.jpeg|*.gif|*.bmp|*.webp|*.svg|*.PNG|*.JPG|*.JPEG)
    [ -f "${out#file://}" ] && out="󰋩 $out" ;;
esac

if [ "${#out}" -gt "$max" ]; then
  printf '%s…\n' "${out:0:max}"
else
  printf '%s\n' "$out"
fi
