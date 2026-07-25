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
        # clementine*) printf '󱁇' ;;
        *) printf '' ;;
    esac
}

# Bare `playerctl metadata` always answers from the FIRST player on the bus
# (D-Bus name order), so a paused clementine would shadow a playing chromium.
# `-a` lists every player, one line each, and we prefer:
#   1. whatever is Playing
#   2. the last player we saw playing (remembered below) — without this, pausing
#      the active player drops us back to bus order, so the next click would
#      resume the *other* (alphabetically first) player instead of the one you
#      just paused
#   3. the first entry
LAST_FILE="${XDG_RUNTIME_DIR:-/tmp}/polybar-mpris-last"
last="$(cat "$LAST_FILE" 2>/dev/null)" || last=''

pick_player() {
    playerctl -a metadata \
        --format '{{status}}'$'\t''{{playerName}}'$'\t''{{title}}' 2>/dev/null |
        awk -F'\t' -v last="$last" \
            '$3 != "" { if ($1 == "Playing" && !p) p = $0
                        if ($2 == last && !l) l = $0
                        if (!f) f = $0 }
             END { print (p ? p : (l ? l : f)) }'
}

line="$(pick_player)"
[ -z "$line" ] && exit 0

IFS=$'\t' read -r status player title <<<"$line"
[ -z "$title" ] && exit 0

# Remember the active player so rule 2 above has something to point at. Only on
# change, so the 1s poll isn't writing a file every tick.
if [ "$status" = Playing ] && [ "$player" != "$last" ]; then
    printf '%s' "$player" >"$LAST_FILE"
fi

# Control mode: polybar's click/scroll actions re-enter this script so they hit
# the same player the label is showing (`playerctl play-pause` alone would
# target the first bus player again — the original bug, one layer down).
case "${1-}" in
    play-pause | next | previous)
        exec playerctl -p "$player" "$1"
        ;;
    cycle | cycle-prev)
        # Rotate which player the module shows, for when several are paused and
        # you want to switch source without resuming it (left-click then plays
        # the newly-shown one). Rewrites the sticky cache to the next player in
        # bus order; the 1s poll redraws within a second. When something is
        # Playing, pick_player prefers it and this is a no-op — cycling only
        # means anything while all players are paused, which is exactly when you
        # need it.
        players="$(playerctl -a metadata --format '{{playerName}}' 2>/dev/null)"
        [ -z "$players" ] && exit 0
        next="$(printf '%s\n' "$players" | awk -v cur="$player" -v back="$([ "$1" = cycle-prev ] && echo 1)" '
            { a[NR] = $0; if ($0 == cur) i = NR }
            END {
                if (NR < 2) { print a[1]; exit }
                if (back) print a[(i + NR - 2) % NR + 1]
                else      print a[i % NR + 1]
            }')"
        printf '%s' "$next" >"$LAST_FILE"
        exit 0
        ;;
esac

player="${player,,}"

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
