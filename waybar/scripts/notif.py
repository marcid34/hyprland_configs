#!/usr/bin/env python3
"""Notification state for waybar: do-not-disturb toggle + unread count.

Click toggles DND. The glyph reports state at a glance, which is the thing
mako itself cannot tell you -- there is no indication anywhere on the desktop
that you have silenced notifications, which is exactly how you miss things
for an afternoon.

Usage: notif.py render
       notif.py toggle
"""

import json
import subprocess
import sys

BELL     = ""   #  nf-fa-bell
BELL_OFF = ""   #  nf-fa-bell_slash


def modes():
    try:
        out = subprocess.run(["makoctl", "mode"], capture_output=True,
                             text=True, timeout=2).stdout
    except Exception:
        return []
    return [m.strip() for m in out.splitlines() if m.strip()]


def waiting():
    """Number of notifications currently in mako's list."""
    try:
        out = subprocess.run(["makoctl", "list"], capture_output=True,
                             text=True, timeout=2).stdout
        d = json.loads(out)
        data = d.get("data") or [[]]
        return len(data[0])
    except Exception:
        return 0


def render():
    dnd = "do-not-disturb" in modes()
    n = waiting()
    if dnd:
        state = {"text": BELL_OFF, "class": "dnd", "tooltip": "notifications silenced"}
    elif n:
        state = {"text": "%s %d" % (BELL, n), "class": "unread",
                 "tooltip": "%d notification%s" % (n, "" if n == 1 else "s")}
    else:
        state = {"text": BELL, "class": "idle", "tooltip": "notifications on"}
    print(json.dumps(state), flush=True)


def toggle():
    subprocess.run(["makoctl", "mode", "-t", "do-not-disturb"], check=False)


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] in ("render", "toggle"):
        (render if sys.argv[1] == "render" else toggle)()
    else:
        raise SystemExit(__doc__)
