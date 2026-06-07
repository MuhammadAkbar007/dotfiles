#!/usr/bin/env bash
# Pulseaudio status for polybar — picks an icon from the *active output port*
# (speaker / headphone / headset / bluetooth) the way waybar's format-icons did.
# Internal/pulseaudio can only ramp on volume %, not the port, so we use a
# custom/script that tails `pactl subscribe` for instant updates on plug/unplug.

# Catppuccin: blue for active, grey when muted
C_ACTIVE="#89b4fa"
C_MUTED="#6c7086"

print_status() {
  local sink mute vol port icon
  sink=$(pactl get-default-sink 2>/dev/null)
  [ -z "$sink" ] && { echo ""; return; }

  if pactl get-sink-mute "$sink" 2>/dev/null | grep -qi yes; then
    echo "%{F${C_MUTED}}󰝟 Muted%{F-}"
    return
  fi

  vol=$(pactl get-sink-volume "$sink" 2>/dev/null | grep -oP '\d+(?=%)' | head -1)

  # Active Port of the default sink, lowercased
  port=$(pactl list sinks 2>/dev/null | awk -v s="$sink" '
    $1=="Name:"   {cur=($2==s)}
    cur && /Active Port:/ {sub(/^[ \t]*Active Port:[ \t]*/,""); print; exit}')
  port=${port,,}

  # Use Material Design glyphs (same range as the speaker icon, which renders);
  # the Font Awesome headphone glyph shows as tofu in Ubuntu Nerd Font.
  case "$port" in
    *headphone*) icon="󰋋" ;;     # headphones
    *headset*)   icon="󰋎" ;;     # headset (with mic)
    *hands-free*|*handsfree*) icon="󱡒" ;;
    *)
      if [[ "$sink" == bluez* ]]; then icon="󰂰"   # bluetooth
      else icon="󰕾"; fi                            # built-in speaker
      ;;
  esac

  echo "%{F${C_ACTIVE}}${icon} ${vol}%%{F-}"
}

print_status
# Reprint on any sink/card/server event (volume, mute, jack plug/unplug).
# Jack plug fires a `card` event slightly *before* the new Active Port is
# committed, so settle briefly before re-reading to avoid a stale icon.
pactl subscribe 2>/dev/null | while read -r line; do
  case "$line" in
    *" sink"*|*" card"*|*" server"*)
      sleep 0.2
      print_status
      ;;
  esac
done
