#!/usr/bin/env bash
# $mod+v / polybar left-click — browse clipboard history in rofi (with image
# thumbnails) and copy the chosen entry back to the X11 clipboard.
#
# Image entries get a real thumbnail icon via rofi's "text\0icon\x1f<path>"
# protocol: binary images are decoded to a cached PNG; copied image-file paths
# use the file itself. We pick with -format i (row index) and map back to the
# original cliphist line so `cliphist decode` still finds the entry by its id.

THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
mkdir -p "$THUMB_DIR"

mapfile -t lines < <(cliphist list 2>/dev/null)
[ "${#lines[@]}" -eq 0 ] && exit 0

build_menu() {
  local i line id display path
  for i in "${!lines[@]}"; do
    line="${lines[$i]}"
    id="${line%%$'\t'*}"
    display="${line#*$'\t'}"

    if [[ "$display" == *'[[ binary data'*image* || "$display" == *'[[ binary data'*png* \
        || "$display" == *'[[ binary data'*jpg* || "$display" == *'[[ binary data'*jpeg* \
        || "$display" == *'[[ binary data'*gif* || "$display" == *'[[ binary data'*bmp* \
        || "$display" == *'[[ binary data'*webp* ]]; then
      # Binary image -> decode once to a cached thumbnail keyed by entry id
      local thumb="$THUMB_DIR/$id.png"
      [ -f "$thumb" ] || printf '%s\n' "$line" | cliphist decode > "$thumb" 2>/dev/null
      printf '%s\0icon\x1f%s\n' "󰋩 Image" "$thumb"
    else
      # Plain text — but if it's a path/URI to an image file, show that image
      path="${display#file://}"
      if [[ "$path" =~ \.(png|jpe?g|gif|bmp|webp|svg)$ ]] && [ -f "$path" ]; then
        printf '%s\0icon\x1f%s\n' "$display" "$path"
      else
        printf '%s\n' "$display"
      fi
    fi
  done
}

idx=$(build_menu | rofi -dmenu -i -show-icons -format i \
        -p "󰅍 Clipboard" -theme-str 'window { width: 55%; }') || exit 0
[ -z "$idx" ] && exit 0

sel="${lines[$idx]}"
if [[ "${sel#*$'\t'}" == *'[[ binary data'* ]]; then
  printf '%s\n' "$sel" | cliphist decode | xclip -selection clipboard -t image/png
else
  printf '%s\n' "$sel" | cliphist decode | xclip -selection clipboard
fi
