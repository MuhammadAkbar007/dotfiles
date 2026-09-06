#!/usr/bin/env bash
# Polybar pomodoro module (replaces the waybar custom/pomodoro). The state
# machine + bar text live in the pet project; this wrapper just streams its
# JSON and emits a polybar label.
#
# pomodoro.py is READ-ONLY: it prints one {"text","class"} line per second
# (flushed) and nothing else. It does not drive the timer, notify, or spawn the
# overlay — pomodorod.py does, as a single user service started from i3. That
# split exists because polybar runs one copy of this script per connected
# output, so a second monitor used to mean two timers, two notifications and two
# overlays. Safe to put the module on every bar.
#
# We map `class` -> a polybar %{F} colour so work/break/paused read differently.
PY=/home/akbar/akbarDev/pet-projects/pomodoro/pomodoro.py

exec python3 -u "$PY" | jq --unbuffered -r '
  (if   .class=="work"    then "#40a02b"
   elif .class=="break"   then "#f9e2af"
   elif .class=="paused"  then "#6c7086"
   elif .class=="waiting" then "#e64553"
   else "#df8e1d" end) as $c
  | "%{F\($c)}\(.text)%{F-}"'
