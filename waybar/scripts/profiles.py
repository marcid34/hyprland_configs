#!/usr/bin/env python3
"""Per-profile shapes for waybar — the rice switcher.

One custom module per profile, mirroring the workspace dots next door: the
whole row is five little indicators, each clickable, filled when it is the
active rice. The registry lives in ~/.config/themes/profiles.list so that
switch.sh and this script can never disagree about the order.

Rendering is one-shot rather than a watch loop. Switching a theme necessarily
reloads waybar (the stylesheet itself changed), and SIGUSR2 re-execs every
custom module, so the shapes repaint as a side effect of the switch. Polling
would just be re-reading a symlink a few times a second for nothing.

Usage: profiles.py render <slot>   # 1-based, matches config.jsonc
       profiles.py switch <slot>
       profiles.py list
"""

import json
import os
import subprocess
import sys

THEMES = os.path.expanduser("~/.config/themes")
LIST = os.path.join(THEMES, "profiles.list")
CURRENT = os.path.join(THEMES, "current")
SWITCH = os.path.join(THEMES, "switch.sh")


def registry():
    """[(dirname, label, active_glyph, idle_glyph)] in file order."""
    out = []
    with open(LIST, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("|")
            if len(parts) != 4:
                continue
            out.append(tuple(p.strip() for p in parts))
    return out


def active():
    """Name of the live profile, or "" if `current` is missing/dangling."""
    try:
        return os.path.basename(os.readlink(CURRENT))
    except OSError:
        return ""


def state(slot):
    entries = registry()
    if not 1 <= slot <= len(entries):
        # Slot beyond the registry: render nothing rather than crash, so a
        # trimmed profiles.list doesn't leave a broken module in the bar.
        return {"text": "", "class": "unused", "tooltip": ""}

    name, label, on, off = entries[slot - 1]
    is_active = name == active()
    return {
        "text": on if is_active else off,
        "class": "active" if is_active else "inactive",
        "tooltip": "%s%s" % (label, "  (active)" if is_active else ""),
    }


def render(slot):
    print(json.dumps(state(slot)), flush=True)


def switch(slot):
    entries = registry()
    if not 1 <= slot <= len(entries):
        raise SystemExit("profiles.py: slot %d is not in the registry" % slot)
    name = entries[slot - 1][0]
    if name == active():
        return  # already live; don't churn every app for a no-op
    subprocess.run([SWITCH, name], check=False)


def show():
    cur = active()
    for i, (name, label, on, off) in enumerate(registry(), 1):
        print("%d  %s %-12s %s" % (i, on if name == cur else off, name,
                                   "<- active" if name == cur else ""))


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "list":
        show()
    elif len(sys.argv) == 3 and sys.argv[1] in ("render", "switch"):
        (render if sys.argv[1] == "render" else switch)(int(sys.argv[2]))
    else:
        raise SystemExit(__doc__)
