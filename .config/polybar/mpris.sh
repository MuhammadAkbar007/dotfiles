#!/usr/bin/env bash
# Polybar MPRIS now-playing module (replaces waybar's built-in `mpris`).
#
# POLLED once per second (config.ini sets interval=1) instead of
# `playerctl --follow`. Reason: `playerctl metadata --follow` only emits on
# track/metadata changes, NOT on play/pause — PlaybackStatus is a separate
# property its follow doesn't watch — so the status icon would never update
# when you pause. Polling guarantees the state shows within ~1s.
#
# Output:  <player-icon> <status-icon> <title>
#   click = play/pause, scroll = next/prev (wired in config.ini)
# Nothing is printed when no player exists or playback is stopped.
set -u

# Status glyphs/colours copied from the waybar status-icons (exact codepoints):
ICON_PLAY=$''  #   nf-fa-play_circle
ICON_PAUSE=$'' #   nf-fa-pause_circle
COL_PLAY='#a6d189'
COL_PAUSE='#f38ba8'
COL_DIM='#6c7086' # ${colors.disabled} — dim the title when paused (like clipboard)
MAXLEN=25         # max visible title chars (polybar label-maxlen is unset; see config.ini)

# Per-player glyph (Ubuntu Nerd Font), matching the waybar player-icons map.
player_icon() {
    case "$1" in
        firefox*) printf '' ;;
        chrom*) printf '' ;;
        spotify*) printf '' ;;
        vlc*) printf '󰕼' ;;
        mpv*) printf '' ;;
        clementine*) printf '󱁇' ;;
        *) printf '' ;;
    esac
}

# One call gets status + player + title. `metadata` exposes {{status}} too.
line="$(playerctl metadata --format '{{status}}'$'\t''{{lc(playerName)}}'$'\t''{{title}}' 2>/dev/null)"
[ -z "$line" ] && exit 0

IFS=$'\t' read -r status player title <<<"$line"
[ -z "$title" ] && exit 0

case "$status" in
    Playing)
        sicon="%{F${COL_PLAY}}${ICON_PLAY}%{F-}"
        dim=0
        ;;
    Paused)
        sicon="%{F${COL_PAUSE}}${ICON_PAUSE}%{F-}"
        dim=1
        ;;
    *) exit 0 ;; # Stopped / unknown -> show nothing
esac

picon="$(player_icon "$player")"

# Truncate long titles with an ellipsis (waybar did this via max-length).
# (Done BEFORE adding colour tags so the length check counts real characters,
# not the %{F...} markup.)
if [ "${#title}" -gt "$MAXLEN" ]; then
    title="${title:0:$((MAXLEN - 1))}…"
fi

# While paused, dim the title to the disabled colour (matches the clipboard
# module) AND italicise it via the bold-italic font (%{T5} = font-4 in
# config.ini); while playing it keeps the bar's normal bold foreground.
if [ "$dim" -eq 1 ]; then
    title="%{T5}%{F${COL_DIM}}${title}%{F-}%{T-}"
fi

printf '%s %s  %s\n' "$picon" "$sicon" "$title"
