#!/usr/bin/env python3
"""Workspace indicator with pluggable styles, for waybar.

hypr-ws.py renders one dot per workspace and nothing else, which meant every
rice ended up with the same five-dot row. This renders the same state in any
of several shapes, and can drive either one module per workspace (clickable
individually) or a single module for the whole set (click/scroll to move) --
so a bar can be five pills, or one line reading "03 / 05", or a segmented
block meter, without changing anything but a config string.

Clicks still go through Hyprland's Lua engine: waybar 0.15 speaks the old
string dispatchers, which 0.56 dropped.

Usage:
  ws.py render <style> <n>     one module for workspace n
  ws.py all <style>            single module covering every workspace
  ws.py focus <n>              click action for `render`
  ws.py cycle <+1|-1>          click/scroll action for `all`

Styles: dots numbers roman blocks meter names fraction page brackets
"""

import json
import os
import socket
import subprocess
import sys

COUNT = 5
NAMES = ["web", "code", "term", "chat", "media"]
ROMAN = ["I", "II", "III", "IV", "V"]

WATCHED = {
    "workspace", "workspacev2", "focusedmon", "focusedmonv2",
    "createworkspace", "createworkspacev2", "destroyworkspace",
    "destroyworkspacev2", "moveworkspace", "moveworkspacev2",
    "openwindow", "closewindow", "movewindow", "movewindowv2",
    "activespecial", "monitoradded", "monitoraddedv2", "monitorremoved",
    "configreloaded",
}


def instance_dir():
    base = os.path.join(
        os.environ.get("XDG_RUNTIME_DIR", "/run/user/%d" % os.getuid()), "hypr")
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if sig and os.path.isdir(os.path.join(base, sig)):
        return os.path.join(base, sig)
    dirs = [os.path.join(base, d) for d in os.listdir(base)]
    dirs = [d for d in dirs if os.path.isdir(d)]
    if not dirs:
        raise SystemExit("no running Hyprland instance")
    return max(dirs, key=os.path.getmtime)


def request(payload):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(os.path.join(instance_dir(), ".socket.sock"))
        s.sendall(payload.encode())
        chunks = []
        while True:
            d = s.recv(65536)
            if not d:
                break
            chunks.append(d)
    return b"".join(chunks).decode()


def state():
    mons = json.loads(request("j/monitors"))
    wss = json.loads(request("j/workspaces"))
    focused = next((m for m in mons if m.get("focused")), None)
    active = focused["activeWorkspace"]["id"] if focused else 0
    on_screen = {m["activeWorkspace"]["id"] for m in mons}
    populated = {w["id"] for w in wss if w.get("windows", 0) > 0}
    return active, on_screen, populated


def klass(i, active, on_screen, populated):
    if i == active:
        return "active"
    if i in on_screen:
        return "visible"
    if i in populated:
        return "occupied"
    return "empty"


def glyph(style, i, cls):
    a = cls == "active"
    live = cls in ("active", "visible")
    if style == "dots":
        return "●" if a else ("◉" if live else ("○" if cls == "occupied" else "·"))
    if style == "numbers":
        return str(i)
    if style == "roman":
        return ROMAN[i - 1]
    if style == "blocks":
        return "█" if a else ("▓" if live else ("▒" if cls == "occupied" else "░"))
    if style == "meter":
        return "▰" if a else ("▩" if live else ("▩" if cls == "occupied" else "▱"))
    if style == "names":
        return NAMES[i - 1]
    if style == "brackets":
        return "[%d]" % i if a else " %d " % i
    return str(i)


# ── one module per workspace ────────────────────────────────────────────
def render(style, i):
    a, o, p = state()
    cls = klass(i, a, o, p)
    print(json.dumps({
        "text": glyph(style, i, cls),
        "class": cls,
        "tooltip": "workspace %d%s" % (i, "  ·  " + NAMES[i - 1] if i <= len(NAMES) else ""),
    }), flush=True)


# ── one module for the whole set ────────────────────────────────────────
def render_all(style):
    a, o, p = state()
    if style == "fraction":
        text = "%02d / %02d" % (a if 1 <= a <= COUNT else 0, COUNT)
    elif style == "page":
        text = "%d of %d" % (a if 1 <= a <= COUNT else 0, COUNT)
    else:
        # blocks/brackets are designed to abut; everything else needs air,
        # and word-style labels need more of it than glyphs do.
        sep = {"blocks": "", "brackets": "", "names": "  ·  "}.get(style, " ")
        text = sep.join(glyph(style, i, klass(i, a, o, p))
                        for i in range(1, COUNT + 1))
    print(json.dumps({
        "text": text,
        "class": "ws",
        "tooltip": "workspace %d of %d  ·  click/scroll to move" % (a, COUNT),
    }), flush=True)


def watch(fn):
    fn()
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(os.path.join(instance_dir(), ".socket2.sock"))
        buf = b""
        while True:
            d = s.recv(4096)
            if not d:
                break
            buf += d
            done, _, buf = buf.rpartition(b"\n")
            names = {l.split(b">>", 1)[0].decode(errors="replace")
                     for l in done.split(b"\n") if l}
            if names & WATCHED:
                fn()


def focus(i):
    # move-to-monitor semantics, matching hypr-ws.py: pull the workspace to
    # the focused monitor, then switch to it.
    request("repl "
            "local m = hl.get_active_monitor().name "
            "hl.dispatch(hl.dsp.workspace.move({workspace = %d, monitor = m})) "
            "hl.dispatch(hl.dsp.focus({workspace = %d}))" % (i, i))


def cycle(delta):
    a, _, _ = state()
    nxt = a + delta
    if nxt < 1:
        nxt = COUNT
    if nxt > COUNT:
        nxt = 1
    focus(nxt)


if __name__ == "__main__":
    av = sys.argv[1:]
    if len(av) == 3 and av[0] == "render":
        watch(lambda: render(av[1], int(av[2])))
    elif len(av) == 2 and av[0] == "all":
        watch(lambda: render_all(av[1]))
    elif len(av) == 2 and av[0] == "focus":
        focus(int(av[1]))
    elif len(av) == 2 and av[0] == "cycle":
        cycle(int(av[1]))
    else:
        raise SystemExit(__doc__)
