#!/usr/bin/env bash
# Power menu — rofi, styled by the active rice.
#
# wlogout is the usual choice here but adding a second toolkit for five
# buttons is not worth it when rofi is already themed per profile and already
# keyboard-driven. Same reason the rice picker is rofi: one menu language for
# the whole desktop.
#
# Labels are glyph-prefixed or plain depending on the active rice, read from
# its own `show-icons` setting rather than hardcoded here. blueprint and eink
# declare show-icons:false because they are deliberately text-only, and a row
# of Nerd Font pictograms in those two would look like a different program.

set -euo pipefail

THEMES="$HOME/.config/themes"
ROFI_THEME="$THEMES/current/rofi.rasi"

icons=1
if [ -r "$ROFI_THEME" ] && grep -qE '^\s*show-icons:\s*false' "$ROFI_THEME"; then
    icons=0
fi

if [ "$icons" = 1 ]; then
    rows=$'  lock\n  suspend\n  log out\n  reboot\n  shut down'
else
    rows=$'lock\nsuspend\nlog out\nreboot\nshut down'
fi

choice="$(printf '%b\n' "$rows" \
  | rofi -dmenu -i -p "session" -format i \
         -theme "$THEMES/picker.rasi" -no-custom 2>/dev/null || true)"

case "${choice:-}" in
  0) command -v hyprlock >/dev/null && hyprlock ;;
  1) systemctl suspend ;;
  2) hyprctl dispatch exit ;;
  3) systemctl reboot ;;
  4) systemctl poweroff ;;
  *) exit 0 ;;
esac
