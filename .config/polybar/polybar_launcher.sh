#!/usr/bin/env bash

# Terminate already running bar instances. Polybar can deadlock in its own
# SIGTERM handler when tray clients (zoom, telegram) refuse to unembed, so the
# wait is bounded and anything still alive after 2s gets SIGKILL. Without the
# bound this loop spins forever and no bar is ever launched.
killall -q polybar
for _ in $(seq 20); do
  pgrep -u "$UID" -x polybar >/dev/null || break
  sleep 0.1
done
killall -q -9 polybar

# One bar per connected output. Only ONE bar can own the systray (X11 tray
# manager selection is single-owner) — prefer an external monitor over the
# laptop panel (eDP-*) when one's connected, otherwise fall back to whatever
# is there. That bar gets the `example` config (has systray); every other
# monitor gets `example-notray` so it doesn't race for the selection.
monitors="$(polybar --list-monitors | cut -d: -f1)"
tray_monitor="$(echo "$monitors" | grep -v '^eDP' | head -1)"
tray_monitor="${tray_monitor:-$(echo "$monitors" | head -1)}"

for m in $monitors; do
  bar=example
  [ "$m" = "$tray_monitor" ] || bar=example-notray
  MONITOR=$m polybar "$bar" 2>&1 | tee -a /tmp/polybar.log &
  disown
done

echo "Polybar launched..."
