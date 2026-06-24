#!/usr/bin/env bash
# copyq clipboard manager — headless setup + autostart for X11/i3.
#
# Replaces the old polling cliphist-watch.sh. copyq's server is an event-driven
# X11 clipboard monitor (no xclip polling, nothing to hang). This script is
# idempotent and safe to run on every i3 (re)start: any copyq *command* starts
# the server headless (bare `copyq` would pop the main window, so we never call
# that), so the config/eval calls below both start and configure it.

# 1. Ensure the server is actually running, headlessly. Plain copyq commands
#    (config/eval) do NOT auto-start it, and bare `copyq` would pop the main
#    window — so use --start-server, which starts the daemon in the background
#    (no window) only if it isn't already up. Idempotent on i3 reload. With
#    disable_tray already persisted (below), a fresh start shows no tray icon.
copyq --start-server eval 'true' >/dev/null 2>&1

# 2. Configuration (only the non-default we need is disable_tray; the rest are
#    set explicitly so the setup is self-contained / reproducible).
copyq config disable_tray   true  >/dev/null 2>&1   # headless: no tray icon
copyq config check_clipboard true >/dev/null 2>&1   # store clipboard copies
copyq config check_selection false >/dev/null 2>&1  # ignore mouse-highlight noise
copyq config maxitems       200   >/dev/null 2>&1

# 3. Install (idempotently) the "Polybar refresh" automatic command: on every
#    new clipboard entry, push a refresh to the polybar `clipboard` module via
#    its IPC hook. This makes the polybar label event-driven (no interval poll).
#    NOTE: keep no in-string "\n" here — copyq's eval turns it into a real
#    newline and breaks the string literal; real newlines between statements OK.
copyq eval -- "$(cat <<'JS'
var keep = commands().filter(function (c) { return c.name !== "Polybar refresh"; });
keep.push({
    name: "Polybar refresh",
    automatic: true,
    enable: true,
    cmd: "copyq: execute('polybar-msg', 'action', '#clipboard.hook.0')"
});
setCommands(keep);
JS
)" >/dev/null 2>&1
