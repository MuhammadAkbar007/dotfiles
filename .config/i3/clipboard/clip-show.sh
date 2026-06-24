#!/usr/bin/env bash
# Polybar IPC hook (module/clipboard, type custom/ipc): the newest copyq entry,
# image-aware and truncated. Re-run on every clipboard change by copyq's
# "Polybar refresh" automatic command (see copyq-setup.sh) and once on bar start
# (module `initial = 1`). No polling — this only runs when the clipboard changes.
max=33

# copyq's dataFormats() is unreliable in this build, so detect by reading:
# a pure-image item has empty text/plain but non-empty image/png bytes.
out="$(copyq read text/plain 0 2>/dev/null)"
if [ -z "$out" ]; then
  if [ "$(copyq read image/png 0 2>/dev/null | head -c1 | wc -c)" -gt 0 ]; then
    echo "󰋩 Image"; exit 0
  fi
  echo "Empty"; exit 0
fi

out="${out//$'\n'/ }"   # flatten newlines/tabs into a single label line
out="${out//$'\t'/ }"

# A copied path/URI to an image file -> mark it with the image glyph.
case "${out#file://}" in
  *.png|*.jpg|*.jpeg|*.gif|*.bmp|*.webp|*.svg|*.PNG|*.JPG|*.JPEG)
    [ -f "${out#file://}" ] && out="󰋩 $out" ;;
esac

if [ "${#out}" -gt "$max" ]; then
  printf '%s…\n' "${out:0:max}"
else
  printf '%s\n' "$out"
fi
