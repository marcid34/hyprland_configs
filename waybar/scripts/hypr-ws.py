#!/usr/bin/env python3
"""Per-workspace dots for waybar, driven by Hyprland's Lua IPC.

Waybar 0.15 still speaks Hyprland's old string IPC ("dispatch workspace 3"),
which 0.56 dropped when dispatch moved to the Lua engine. So hyprland/workspaces
paints correctly -- it reads socket2, which is unchanged -- but every click is a
silent no-op, move-to-monitor included. `on-click` can't paper over it either:
each workspace is a GtkButton whose own handler eats the press before AModule's
on-click handler on the event box ever sees it.

Hence one custom module per workspace. `render` streams state from socket2;
`focus` is the click action and reproduces move-to-monitor=true -- pull the
workspace onto the focused monitor, then switch to it.

Usage: hypr-ws.py render <id>
       hypr-ws.py focus  <id>
"""

import json
import os
import socket
import sys

ACTIVE_ICON = "●"  # ●
IDLE_ICON = "○"  # ○

# Events that can change which dot is lit. Everything else Hyprland emits
# (cursor moves, layer surfaces, submaps) is ignored so we aren't re-querying
# on every mouse twitch.
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
        os.environ.get("XDG_RUNTIME_DIR", "/run/user/%d" % os.getuid()), "hypr"
    )
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if sig and os.path.isdir(os.path.join(base, sig)):
        return os.path.join(base, sig)
    # No signature in the environment, or a stale one left over from a previous
    # session: fall back to the most recent instance directory.
    dirs = [os.path.join(base, d) for d in os.listdir(base)]
    dirs = [d for d in dirs if os.path.isdir(d)]
    if not dirs:
        raise SystemExit("no running Hyprland instance")
    return max(dirs, key=os.path.getmtime)


def request(payload):
    """Send one command on socket1 and return the reply."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(os.path.join(instance_dir(), ".socket.sock"))
        sock.sendall(payload.encode())
        chunks = []
        while True:
            data = sock.recv(65536)
            if not data:
                break
            chunks.append(data)
    return b"".join(chunks).decode()


def state(ws_id):
    monitors = json.loads(request("j/monitors"))
    workspaces = json.loads(request("j/workspaces"))

    focused = next((m for m in monitors if m.get("focused")), None)
    on_screen = {m["activeWorkspace"]["id"] for m in monitors}
    populated = {w["id"] for w in workspaces if w.get("windows", 0) > 0}

    if focused and focused["activeWorkspace"]["id"] == ws_id:
        css_class = "active"
    elif ws_id in on_screen:
        # Active on the other monitor -- worth distinguishing, since clicking
        # it is exactly the move-to-monitor case.
        css_class = "visible"
    elif ws_id in populated:
        css_class = "occupied"
    else:
        css_class = "empty"

    home = next((w["monitor"] for w in workspaces if w["id"] == ws_id), None)
    return {
        "text": ACTIVE_ICON if css_class == "active" else IDLE_ICON,
        "class": css_class,
        "tooltip": "workspace %d%s" % (ws_id, " on %s" % home if home else ""),
    }


def emit(ws_id):
    print(json.dumps(state(ws_id)), flush=True)


def render(ws_id):
    emit(ws_id)
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(os.path.join(instance_dir(), ".socket2.sock"))
        buf = b""
        while True:
            data = sock.recv(4096)
            if not data:
                break  # compositor went away; waybar restarts us
            buf += data
            complete, _, buf = buf.rpartition(b"\n")
            names = {line.split(b">>", 1)[0].decode(errors="replace")
                     for line in complete.split(b"\n") if line}
            if names & WATCHED:
                emit(ws_id)


def focus(ws_id):
    # move-to-monitor=true, expressed in the Lua dispatchers: pull the
    # workspace onto whichever monitor currently has focus, then switch to it.
    request(
        "repl "
        "local m = hl.get_active_monitor().name "
        "hl.dispatch(hl.dsp.workspace.move({workspace = %d, monitor = m})) "
        "hl.dispatch(hl.dsp.focus({workspace = %d}))" % (ws_id, ws_id)
    )


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("render", "focus"):
        raise SystemExit(__doc__)
    (render if sys.argv[1] == "render" else focus)(int(sys.argv[2]))
