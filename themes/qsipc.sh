#!/usr/bin/env bash
# ~/.config/themes/qsipc.sh — call an IPC function on the active rice's
# Quickshell shell, if it has one.
#
# Quickshell's GlobalShortcut registers an *action*; it does not bind a key.
# Binding one needs `bind = MOD, KEY, global, <appid>:<name>` in the compositor
# config, and this repo's Lua wrapper exposes no `global` dispatcher — so the
# shipped keybinds reach the shell over IPC instead, which works the same and
# is scriptable from anywhere.
#
# Exits quietly when the active rice ships no Quickshell shell, so a single
# global keybind is harmless on the other thirty-odd profiles.
#
# Usage:  qsipc.sh <target> <function> [args...]
#         qsipc.sh palette toggle

set -uo pipefail

QML="$HOME/.config/themes/current/quickshell/shell.qml"

[ -f "$QML" ] || exit 0
command -v quickshell >/dev/null 2>&1 || exit 0
[ $# -ge 2 ] || { echo "usage: qsipc.sh <target> <function> [args...]" >&2; exit 2; }

exec quickshell ipc --path "$QML" call "$@" >/dev/null 2>&1
