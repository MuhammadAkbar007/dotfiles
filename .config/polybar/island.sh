#!/usr/bin/env bash
# Polybar dynamic island (module/island): a row of status icons after the
# workspaces. Each icon is compact; when its state changes (or you click it) it
# expands IN PLACE to its full form for AUTO_SECS, then collapses. One section
# open at a time. The clock/date is a separate centre module, untouched.
#
# Producers are the existing bar scripts (pomodoro.sh, mpris.sh, pulseaudio.sh,
# caffeine.sh, clip-show.sh) plus nmcli; colours come from their output / the
# current palette, so the look is unchanged. Transparent, no rounded shape.
set -u

DIR="${XDG_RUNTIME_DIR:-/tmp}/polybar-island"
BAR="$HOME/.config/polybar"
OPEN="$DIR/open"         # "<section> <expiry-epoch>"; collapsed once now > expiry
AUTO_SECS=5              # how long any open (manual or state-change) stays

G_PLAY=$''         # nf-fa-play_circle  (mpris.sh ICON_PLAY)
G_PAUSE=$''        # nf-fa-pause_circle (mpris.sh ICON_PAUSE)
# nf-md-wifi_strength ramp, matching the network module's ramp-signal glyphs
G_W0=$'\U000f092f' G_W1=$'\U000f091f' G_W2=$'\U000f0922' G_W3=$'\U000f0925' G_W4=$'\U000f0928'
G_WOFF=$'\U000f092e'
G_POWER=$'⏻'        # ⏻ IEC power (the power module's glyph)
G_CLIP=$'\U000f014d'     # nf-md-clipboard (the clipboard module's prefix glyph)
G_POMO=$'\U000f13ab'     # the timer glyph pomodoro.sh uses when running
POWERMENU="$HOME/.config/rofi/powermenu/powermenu.sh"
CLIPSHOW="$HOME/.config/i3/clipboard/clip-show.sh"
CLIPMENU="$HOME/.config/i3/clipboard/clip-menu.sh"
CLIPCLR="$HOME/.config/i3/clipboard/clip-clear.sh"
NETSH="$HOME/.config/rofi/network/network.sh"
POMOCTL="python3 /home/akbar/akbarDev/pet-projects/pomodoro/pomodoroctl.py"
VOLOSD="$HOME/.config/i3/osd/volume.sh"

mkdir -p "$DIR"

# Is section $1 the one currently open, and not yet expired?  (defined before the
# `do` handler that calls it)
opened() {
    local sec exp now
    read -r sec exp 2>/dev/null <"$OPEN" || return 1
    [ "$sec" = "$1" ] || return 1
    printf -v now '%(%s)T' -1
    ((now <= ${exp:-0}))
}

# Click dispatcher: `island.sh do <section> <button>`. A left-click on a section
# that isn't open just opens it (expands it in place); the NEXT left-click, while
# it's open, runs its primary action. Other buttons act immediately and open the
# section too. Matches the old standalone modules' actions.
if [ "${1-}" = do ]; then
    sec=${2-}; btn=${3-}
    printf -v now '%(%s)T' -1
    if [ "$btn" = left ] && ! opened "$sec"; then
        echo "$sec $((now + AUTO_SECS))" >"$OPEN"; exit 0   # first click: open only
    fi
    echo "$sec $((now + AUTO_SECS))" >"$OPEN"               # keep open + re-arm, then act
    case "$sec:$btn" in
        music:left)  exec "$BAR/mpris.sh" play-pause ;;
        music:mid)   exec "$BAR/mpris.sh" previous ;;
        music:right) exec "$BAR/mpris.sh" next ;;
        music:up)    exec "$BAR/mpris.sh" cycle ;;
        music:down)  exec "$BAR/mpris.sh" cycle-prev ;;
        pomo:left)   exec $POMOCTL toggle ;;
        pomo:right)  exec $POMOCTL next ;;
        pomo:mid)    exec $POMOCTL reset ;;
        wifi:left)   exec kitty -e nmtui ;;    # second click -> straight to the TUI
        wifi:right)  exec "$NETSH" ;;           # rofi applet on right-click
        clip:left)   exec "$CLIPMENU" ;;
        clip:right)  exec "$CLIPCLR" ;;
    esac
    exit 0
fi

# Wrap a segment's markup with all five button actions, routed through the dispatcher.
acts() {   # $1=section  $2=content
    local s=$1 c=$2
    printf '%%{A1:%s/island.sh do %s left:}%%{A2:%s/island.sh do %s mid:}%%{A3:%s/island.sh do %s right:}%%{A4:%s/island.sh do %s up:}%%{A5:%s/island.sh do %s down:}%s%%{A}%%{A}%%{A}%%{A}%%{A}' \
        "$BAR" "$s" "$BAR" "$s" "$BAR" "$s" "$BAR" "$s" "$BAR" "$s" "$c"
}

# --- daemon -----------------------------------------------------------------
: >"$OPEN"      # start fully compact; sections open only on change/click

FIFO="$DIR/fifo.$$"
mkfifo "$FIFO"
exec 3<>"$FIFO"
set -m
pgids=()
cleanup() { local pg; for pg in "${pgids[@]}"; do kill -- -"$pg" 2>/dev/null; done; rm -f "$FIFO"; }
trap cleanup EXIT
trap 'exit 0' TERM INT

{ "$BAR/pomodoro.sh" 2>/dev/null | while IFS= read -r l; do printf 'pomo\t%s\n' "$l"; done; } 3>&- >"$FIFO" &
pgids+=("$!")
# ponytail: 1s poll, same cadence the old mpris module used
{ while :; do printf 'music\t%s\n' "$("$BAR/mpris.sh" 2>/dev/null)"; sleep 1; done; } 3>&- >"$FIFO" &
pgids+=("$!")
# wifi: "<signal>:<ssid>" for the active connection, empty when disconnected.
# Disconnected is decided by the device STATE (no scan), and the last signal is
# held when a scan momentarily returns nothing, so the icon never flickers.
{
    wlan='' last=''
    while :; do
        # Re-find the wifi device until we have one (NetworkManager may not be up at login).
        [ -z "$wlan" ] && wlan=$(nmcli -t -f DEVICE,TYPE dev 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')
        if [ -n "$wlan" ] && [[ $(nmcli -t -f GENERAL.STATE dev show "$wlan" 2>/dev/null) == *:100* ]]; then
            line=$(nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi 2>/dev/null | sed -n 's/^yes:\([0-9]*\):\(.*\)$/\1:\2/p' | head -1)
            [ -n "$line" ] && last=$line
            printf 'wifi\t%s\n' "$last"
        else
            last=''; printf 'wifi\t\n'
        fi
        sleep 5
    done
} 3>&- >"$FIFO" &
pgids+=("$!")
# caffeine: caffeine.sh prints its own coloured on/off icon each tick
{ while :; do printf 'caf\t%s\n' "$("$BAR/caffeine.sh" 2>/dev/null)"; sleep 1; done; } 3>&- >"$FIFO" &
pgids+=("$!")
# volume: pulseaudio.sh is a tail script — prints "<icon> <vol>%" on each change
{ "$BAR/pulseaudio.sh" 2>/dev/null | while IFS= read -r l; do printf 'vol\t%s\n' "$l"; done; } 3>&- >"$FIFO" &
pgids+=("$!")
# clipboard: poll clip-show.sh (already %{..}-safe and truncated). Fast poll so a
# copy shows near-instantly; clip-show.sh is a cheap copyq read.
{ while :; do printf 'clip\t%s\n' "$("$CLIPSHOW" 2>/dev/null)"; sleep 0.3; done; } 3>&- >"$FIFO" &
pgids+=("$!")

pomo='' music='' wifi='' caf='' vol='' clip='' prev=''

# Auto-open a section for AUTO_SECS when its meaningful state changes. Some
# payloads churn (pomodoro counts down every tick, wifi signal wiggles), so the
# "change key" ignores that: pomodoro keys on phase colour, wifi on SSID only.
declare -A lastkey seen
autokey() {
    case "$1" in
        pomo) printf '%s' "${2%%\}*}" ;;   # phase colour, not the countdown
        wifi) printf '%s' "${2#*:}" ;;      # ssid, not the signal level
        *)    printf '%s' "$2" ;;
    esac
}
maybe_open() {   # $1=section $2=payload
    local k now; k=$(autokey "$1" "$2")
    if [ -n "${seen[$1]:-}" ] && [ "$k" != "${lastkey[$1]:-}" ]; then
        printf -v now '%(%s)T' -1
        echo "$1 $((now + AUTO_SECS))" >"$OPEN"   # latest change wins
    fi
    lastkey[$1]=$k; seen[$1]=1
}

# ---- segments: compact icon, or full form while open (expands in place) ----
wifi_icon() {   # coloured ramp glyph, or the disconnected glyph
    [ -z "$wifi" ] && { printf '%%{F#f38ba8}%s%%{F-}' "$G_WOFF"; return; }
    local sig=${wifi%%:*} ramp
    if   ((sig >= 80)); then ramp=$G_W4
    elif ((sig >= 60)); then ramp=$G_W3
    elif ((sig >= 40)); then ramp=$G_W2
    elif ((sig >= 20)); then ramp=$G_W1
    else ramp=$G_W0; fi
    printf '%%{F#8839ef}%s%%{F-}' "$ramp"
}
# pomodoro.sh's label varies (running = glyph+time, idle = " pomodoro "), so the
# compact icon is a fixed timer glyph tinted with the phase colour; open = label.
seg_pomo() {
    [ -z "$pomo" ] && return
    if opened pomo; then acts pomo "$pomo"
    else acts pomo "${pomo%%\}*}}${G_POMO}%{F-}"; fi
}
seg_music() {
    [ -z "$music" ] && return
    if opened music; then acts music "$music"; return; fi
    if [[ $music == *a6d189* ]]; then acts music "%{F#a6d189}${G_PLAY}%{F-}"   # playing
    else acts music "%{F#f38ba8}${G_PAUSE}%{F-}"; fi                            # paused
}
seg_wifi() {
    local ic; ic="$(wifi_icon)"
    if opened wifi; then
        if [ -z "$wifi" ]; then acts wifi "$ic Disconnected"
        else acts wifi "$ic ${wifi#*:} ${wifi%%:*}%"; fi
    else acts wifi "$ic"; fi
}
seg_clip() {
    if opened clip; then acts clip "%{F#cba6f7}${G_CLIP}%{F-} %{F#6c7086}${clip}%{F-}"   # muted text
    else acts clip "%{F#cba6f7}${G_CLIP}%{F-}"; fi
}
# Volume has no open form — dunst already shows an OSD on change. It just sits on
# the right; its actions route through the OSD script (so scroll/mute also pop
# the dunst bar), never through the open mechanism.
seg_vol() {
    [ -z "$vol" ] && return
    local color rest glyph icon
    color="${vol%%\}*}}"; rest="${vol#*\}}"; glyph="${rest%% *}"
    icon="${color}${glyph}%{F-}"
    printf '%%{A1:%s mute:}%%{A3:pavucontrol:}%%{A4:%s up:}%%{A5:%s down:}%s%%{A}%%{A}%%{A}%%{A}' \
        "$VOLOSD" "$VOLOSD" "$VOLOSD" "$icon"
}
# caffeine toggles on click (no open form); power launches the menu.
seg_caffeine() { [ -z "$caf" ] && return; printf '%%{A1:%s/caffeine.sh toggle:}%s%%{A}' "$BAR" "$caf"; }
seg_power() { printf '%%{A1:%s:}%%{F#f38ba8}%s%%{F-}%%{A}' "$POWERMENU" "$G_POWER"; }

render() {
    local out='' seg
    for seg in "$(seg_clip)" "$(seg_pomo)" "$(seg_music)" "$(seg_wifi)" "$(seg_vol)" "$(seg_caffeine)" "$(seg_power)"; do
        [ -n "$seg" ] || continue
        [ -n "$out" ] && out+=' '
        out+="$seg"
    done
    printf '%s' "$out"
}

# Redraw only when the icons could have changed: after a data event (dirty), or
# when the open-state signature changes (click, or a section expiring). This
# keeps the idle bar from re-running render() — and its subshells — every tick.
draw() { local out; out="$(render)"; [ "$out" != "$prev" ] && { printf '%s\n' "$out"; prev=$out; }; }
prevsig=''; dirty=1
while :; do
    read -r osec oexp 2>/dev/null <"$OPEN" || { osec=''; oexp=0; }
    printf -v now '%(%s)T' -1
    sig="$osec $((now <= ${oexp:-0}))"
    { [ "$sig" != "$prevsig" ] || [ "$dirty" = 1 ]; } && { draw; prevsig=$sig; dirty=0; }
    if IFS=$'\t' read -r -t 0.2 -u 3 kind payload; then
        case "$kind" in
            pomo) pomo=$payload; maybe_open pomo "$payload" ;;
            music) music=$payload; maybe_open music "$payload" ;;
            wifi) wifi=$payload; maybe_open wifi "$payload" ;;
            caf) caf=$payload ;;   # no open form -> no auto-open
            vol) vol=$payload ;;   # right-side only -> no auto-open
            clip) clip=$payload; maybe_open clip "$payload" ;;
        esac
        dirty=1
    fi
done
