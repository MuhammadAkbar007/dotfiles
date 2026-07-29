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

# One bar per connected output. Systray only lands on the primary; the other
# bars log "tray already managed" and carry on.
for m in $(polybar --list-monitors | cut -d: -f1); do
  MONITOR=$m polybar example 2>&1 | tee -a /tmp/polybar.log &
  disown
done

echo "Polybar launched..."
