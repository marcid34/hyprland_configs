#!/usr/bin/env bash
# Run the active rice's launcher.
#
# Not every rice wants rofi. A console rice wants something that looks like a
# console prompt; a macOS-shaped rice wants a full-screen app grid. The rice
# declares its choice in themes/<n>/launcher (one word), and SUPER+R comes
# here rather than hardcoding a program.
#
# Falls back to rofi whenever the declared launcher isn't installed, so a
# missing package degrades to "works, looks different" rather than "nothing
# happens when I press the key".

set -uo pipefail
THEMES="$HOME/.config/themes"
CUR="$THEMES/current"

want="$(tr -d '[:space:]' < "$CUR/launcher" 2>/dev/null || echo rofi)"

have() { command -v "$1" >/dev/null 2>&1; }

case "$want" in
  fuzzel)
    have fuzzel && exec fuzzel --config "$CUR/fuzzel.ini" ;;
  wofi)
    have wofi && exec wofi --show drun --conf "$CUR/wofi.conf" \
                           --style "$CUR/wofi.css" ;;
  tofi)
    have tofi-drun && exec tofi-drun --config "$CUR/tofi.conf" ;;
  drawer)
    have nwg-drawer && exec nwg-drawer -c 6 -is 72 -s "$CUR/drawer.css" ;;
  rofi-grid)
    exec rofi -show drun -theme "$CUR/rofi-grid.rasi" ;;
  rofi-full)
    exec rofi -show drun -theme "$CUR/rofi-full.rasi" ;;
esac

# default, and the fallback for anything not installed
exec rofi -show drun
