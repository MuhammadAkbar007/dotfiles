#!/usr/bin/env python3
"""Caps/Num lock OSD for i3/X11 — a SwayOSD-style transient popup.

python-xlib has no XKB event support, so we poll the keyboard LED mask over the
existing X connection (a tiny request, negligible cost) and fire a dunst popup
only on an edge change. LED bits match `xset q`: bit 0 = Caps, bit 1 = Num.
"""
import os
import time
import fcntl
import subprocess
from Xlib import display

# Single-instance guard: hold an exclusive lock for the lifetime of the process.
# A second copy (e.g. from an i3 reload) can't acquire it and exits. Replaces
# the old `pgrep -f` guard, which self-matched its own command line.
_lock_path = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "lockkeys.lock")
_lock_fd = open(_lock_path, "w")
try:
    fcntl.flock(_lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
except OSError:
    raise SystemExit(0)

CAPS = 1  # led_mask bit 0
NUM = 2   # led_mask bit 1
POLL = 0.15


def notify(tag, name, on):
    glyph = "󰌾" if on else "󰌿"        # lock / lock-open (Material Design)
    state = "On" if on else "Off"
    subprocess.run(
        ["dunstify", "-a", "osd", "-u", "low", "-t", "1200",
         "-h", f"string:x-dunst-stack-tag:osd-{tag}",
         f"{glyph}   {name}   {state}"],
        check=False,
    )


def main():
    d = display.Display()
    prev = d.get_keyboard_control().led_mask
    while True:
        time.sleep(POLL)
        m = d.get_keyboard_control().led_mask
        changed = m ^ prev
        if not changed:
            continue
        if changed & CAPS:
            notify("caps", "Caps Lock", m & CAPS)
        if changed & NUM:
            notify("num", "Num Lock", m & NUM)
        prev = m


if __name__ == "__main__":
    main()
