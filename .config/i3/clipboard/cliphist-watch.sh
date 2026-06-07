#!/usr/bin/env bash
# X11 clipboard -> cliphist watcher. Replaces the Wayland
# `wl-paste --watch cliphist store`. Polls the CLIPBOARD selection with xclip
# and stores changes into cliphist. Images are stored as their raw image bytes
# so cliphist shows its "[[ binary data ... ]]" placeholder, not raw bytes.
# Single-instance guard: hold an exclusive lock on a fixed fd. A second copy
# (e.g. from an i3 reload) can't grab the lock and exits immediately. This
# replaces the old `pgrep -f` guard in the i3 config, which self-matched its
# own command line and so never launched the watcher on a clean boot.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/cliphist-watch.lock"
flock -n 9 || exit 0

INTERVAL=1
lasthash=""

while true; do
  tgts=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null)

  if printf '%s\n' "$tgts" | grep -qiE '^image/(png|jpe?g|bmp|gif|webp)$'; then
    mime=$(printf '%s\n' "$tgts" | grep -ioE '^image/(png|jpe?g|bmp|gif|webp)$' | head -1)
    tmp=$(mktemp)
    xclip -selection clipboard -t "$mime" -o 2>/dev/null > "$tmp"
    h=$(sha1sum "$tmp" | cut -d' ' -f1)
    if [ -s "$tmp" ] && [ "$h" != "$lasthash" ]; then
      cliphist store < "$tmp"
      lasthash="$h"
    fi
    rm -f "$tmp"
  else
    txt=$(xclip -selection clipboard -o 2>/dev/null)
    if [ -n "$txt" ]; then
      h=$(printf '%s' "$txt" | sha1sum | cut -d' ' -f1)
      if [ "$h" != "$lasthash" ]; then
        printf '%s' "$txt" | cliphist store
        lasthash="$h"
      fi
    fi
  fi

  sleep "$INTERVAL"
done
