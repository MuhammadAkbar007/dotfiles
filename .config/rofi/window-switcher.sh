#!/usr/bin/env bash
# rofi window switcher for i3 with .desktop-quality icons.
# Built-in `rofi -show window` looks icons up by raw WM_CLASS, which fails for
# apps whose class != icon name (Claude, Hubstaff, ...). This resolves the icon
# the same way drun does: class -> .desktop -> Icon=, then lets rofi's theme
# render it. Focuses the chosen window by i3 con_id.

APPDIRS=(
  "$HOME/.local/share/applications"
  /usr/share/applications
  /var/lib/flatpak/exports/share/applications
  "$HOME/.local/share/flatpak/exports/share/applications"
)

icon_for() {   # $1=class  $2=instance  -> prints an icon name or path
  local cls="$1" inst="$2" d f icon
  # 1) a .desktop declaring StartupWMClass = class or instance
  for d in "${APPDIRS[@]}"; do
    [ -d "$d" ] || continue
    f=$(grep -ilE "^StartupWMClass=(${cls}|${inst})$" "$d"/*.desktop 2>/dev/null | head -1)
    if [ -n "$f" ]; then
      icon=$(grep -m1 '^Icon=' "$f" | cut -d= -f2-)
      [ -n "$icon" ] && { printf '%s' "$icon"; return; }
    fi
  done
  # 2) a .desktop whose filename matches instance/class
  for d in "${APPDIRS[@]}"; do
    for n in "$inst" "$cls" "${inst,,}" "${cls,,}"; do
      if [ -f "$d/$n.desktop" ]; then
        icon=$(grep -m1 '^Icon=' "$d/$n.desktop" | cut -d= -f2-)
        [ -n "$icon" ] && { printf '%s' "$icon"; return; }
      fi
    done
  done
  # 3) fallback: lowercased class (rofi's default behaviour)
  printf '%s' "${inst,,}"
}

# Pull all real windows from the i3 tree: con_id, class, instance, title
mapfile -t rows < <(i3-msg -t get_tree | jq -r '
  .. | objects | select(.type? == "workspace")
  | .. | objects
  | select(.window != null and .window_properties != null)
  | [ (.id|tostring),
      (.window_properties.class // "?"),
      (.window_properties.instance // "?"),
      (.name // "?") ] | @tsv')

[ "${#rows[@]}" -eq 0 ] && exit 0

CIDS=(); DISP=(); ICON=()
i=0
for row in "${rows[@]}"; do
  IFS=$'\t' read -r conid cls inst title <<< "$row"
  CIDS[i]="$conid"
  DISP[i]="${title}    ·    ${cls}"
  ICON[i]="$(icon_for "$cls" "$inst")"
  i=$((i+1))
done

# Emit rows with per-row icon metadata (NUL goes straight into the pipe, never a var)
idx=$(
  for j in "${!CIDS[@]}"; do
    printf '%s\0icon\x1f%s\n' "${DISP[$j]}" "${ICON[$j]}"
  done | rofi -dmenu -i -p "Windows" -format i -show-icons
)

[ -n "$idx" ] && i3-msg "[con_id=${CIDS[$idx]}] focus" >/dev/null 2>&1
