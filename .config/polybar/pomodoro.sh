#!/usr/bin/env bash
# Polybar pomodoro module (replaces the waybar custom/pomodoro). The state
# machine + bar text live in the pet project; this wrapper just streams its
# JSON and emits a polybar label.
#
# pomodoro.py is a long-running driver: it prints one {"text","class"} line per
# second (flushed), drives the timer, fires notify-send/sound on completion, and
# (on Wayland) spawns the break overlay. Running it here as a `tail = true`
# module makes polybar its single host, exactly like waybar was.
#
# We map `class` -> a polybar %{F} colour so work/break/paused read differently.
# NOTE: the break OVERLAY is Wayland-only (GTK Layer Shell) and won't appear on
# X11 — that piece is handled separately; the bar text + timer work fine.
PY=/home/akbar/akbarDev/pet-projects/pomodoro/pomodoro.py

exec python3 -u "$PY" | jq --unbuffered -r '
  (if   .class=="work"    then "#40a02b"
   elif .class=="break"   then "#f9e2af"
   elif .class=="paused"  then "#6c7086"
   elif .class=="waiting" then "#e64553"
   else "#df8e1d" end) as $c
  | "%{F\($c)}\(.text)%{F-}"'
