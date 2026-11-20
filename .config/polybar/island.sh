#!/usr/bin/env bash
# Polybar dynamic island. The right-side module (module/island) is a row of
# always-compact status icons. When a section's state changes (or you click it),
# the daemon parks that section's FULL form in $DIR/center for AUTO_SECS; the
# centre module (module/island-center) shows it there in place of the clock/date,
# then falls back to the date. The right icon never expands — it stays compact.
#
# Producers are the existing bar scripts (pomodoro.sh, mpris.sh, pulseaudio.sh,
# caffeine.sh, clip-show.sh) plus nmcli; colours come from their output / the
# current palette, so the look is unchanged. Transparent, no rounded shape.
set -u

DIR="${XDG_RUNTIME_DIR:-/tmp}/polybar-island"
BAR="$HOME/.config/polybar"
OPEN="$DIR/open"         # "<section> <expiry-epoch>"; collapsed once now > expiry
CENTER="$DIR/center"     # the daemon parks the centre line here
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
# Reuse the date module's exact format, so the centre's resting view is identical.
DFMT=$(sed -n 's/^date = "\(.*\)"$/\1/p' "$BAR/config.ini" | head -1); DFMT=${DFMT:-%a %d %B | %H:%M}

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
# that isn't open just opens it (shows it in the centre); the NEXT left-click,
# while it's open, runs its primary action. Other buttons act immediately and
# open the section too. Matches the old standalone modules' actions.
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

# Centre module feed: print whatever the daemon parked in $CENTER (the open
# section's full form, or the clock/date when idle).
if [ "${1-}" = centerloop ]; then
    prev=__
    while :; do
        cur=$(cat "$CENTER" 2>/dev/null)
        if [ -z "$cur" ]; then printf -v d "%($DFMT)T" -1; cur="%{F#cdd6f4}${d}%{F-}"; fi
        [ "$cur" != "$prev" ] && { printf '%s\n' "$cur"; prev=$cur; }
        sleep 0.1
    done
fi

# Wrap a compact icon with all five button actions, routed through the dispatcher.
acts() {   # $1=section  $2=content
    local s=$1 c=$2
    printf '%%{A1:%s/island.sh do %s left:}%%{A2:%s/island.sh do %s mid:}%%{A3:%s/island.sh do %s right:}%%{A4:%s/island.sh do %s up:}%%{A5:%s/island.sh do %s down:}%s%%{A}%%{A}%%{A}%%{A}%%{A}' \
        "$BAR" "$s" "$BAR" "$s" "$BAR" "$s" "$BAR" "$s" "$BAR" "$s" "$c"
}

# --- daemon -----------------------------------------------------------------
: >"$OPEN"      # start fully compact; sections open only on change/click
: >"$CENTER"    # centre falls back to the date until something opens

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

pomo='' music='' wifi='' caf='' vol='' clip='' prev='' prevc=''

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

# ---- compact icons (right island) ----
# pomodoro.sh's label varies (running = glyph+time, idle = " pomodoro "), so show
# a fixed timer glyph tinted with its phase colour. Full label shows in centre.
seg_pomo() {
    [ -z "$pomo" ] && return
    local color="${pomo%%\}*}}"   # leading "%{F#...}" = phase colour
    acts pomo "${color}${G_POMO}%{F-}"
}
seg_music() {
    [ -z "$music" ] && return
    local out
    if [[ $music == *a6d189* ]]; then out="%{F#a6d189}${G_PLAY}%{F-}"   # playing
    else out="%{F#f38ba8}${G_PAUSE}%{F-}"; fi                            # paused
    acts music "$out"
}
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
seg_wifi() { acts wifi "$(wifi_icon)"; }
# Volume never uses the centre — dunst already shows an OSD on change. It just
# sits on the right; its actions route through the OSD script (so scroll/mute
# also pop the dunst bar), never through the open/centre mechanism.
seg_vol() {
    [ -z "$vol" ] && return
    local color rest glyph icon
    color="${vol%%\}*}}"; rest="${vol#*\}}"; glyph="${rest%% *}"
    icon="${color}${glyph}%{F-}"
    printf '%%{A1:%s mute:}%%{A3:pavucontrol:}%%{A4:%s up:}%%{A5:%s down:}%s%%{A}%%{A}%%{A}%%{A}' \
        "$VOLOSD" "$VOLOSD" "$VOLOSD" "$icon"
}
seg_clip() { acts clip "%{F#cba6f7}${G_CLIP}%{F-}"; }
# caffeine toggles on click (no centre form); power launches the menu.
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

# ---- centre: the open section's full form, else the date ----
full() {
    case "$1" in
        clip) printf '%%{F#cba6f7}%s%%{F-} %%{F#6c7086}%s%%{F-}' "$G_CLIP" "$clip" ;;   # muted text
        pomo) printf '%s' "$pomo" ;;
        music) printf '%s' "$music" ;;
        wifi)
            if [ -z "$wifi" ]; then printf '%s Disconnected' "$(wifi_icon)"
            else printf '%s %s %s%%' "$(wifi_icon)" "${wifi#*:}" "${wifi%%:*}"; fi ;;
    esac
}
center() {
    local sec exp now d f
    read -r sec exp 2>/dev/null <"$OPEN"
    printf -v now '%(%s)T' -1
    # Fall through to the date if the open section has nothing to show (e.g. the
    # player quit), so the centre never goes blank for AUTO_SECS.
    if [ -n "${sec:-}" ] && ((now <= ${exp:-0})) && f=$(full "$sec") && [ -n "$f" ]; then
        acts "$sec" "$f"                    # centre item carries the same click actions
    else
        printf -v d "%($DFMT)T" -1          # builtin clock, no subshell per tick
        printf '%%{F#cdd6f4}%s%%{F-}' "$d"
    fi
}

# The right icons only change on data events, so redraw them after an event, not
# on every tick. The centre is checked each tick (cheap: builtin clock) so a
# click or state change shows within ~0.1s.
draw_right() { local out; out="$(render)"; [ "$out" != "$prev" ] && { printf '%s\n' "$out"; prev=$out; }; }
draw_right
while :; do
    c="$(center)"
    # atomic write: the 10Hz centerloop reader must never catch the file mid-write
    [ "$c" != "$prevc" ] && { printf '%s\n' "$c" >"$CENTER.tmp" && mv "$CENTER.tmp" "$CENTER"; prevc=$c; }
    if IFS=$'\t' read -r -t 0.1 -u 3 kind payload; then
        case "$kind" in
            pomo) pomo=$payload; maybe_open pomo "$payload" ;;
            music) music=$payload; maybe_open music "$payload" ;;
            wifi) wifi=$payload; maybe_open wifi "$payload" ;;
            caf) caf=$payload ;;   # no centre form -> no auto-open
            vol) vol=$payload ;;   # right-side only -> no auto-open
            clip) clip=$payload; maybe_open clip "$payload" ;;
        esac
        draw_right
    fi
done
