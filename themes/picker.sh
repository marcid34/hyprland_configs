#!/usr/bin/env bash
# ~/.config/themes/picker.sh — rofi front-end for the rice switcher.
#
# Replaces the old per-profile waybar modules: twenty indicator dots in the
# bar was more clutter than information, and a launcher list scales while a
# row of dots does not. Bound to SUPER+T.
#
# The picker deliberately renders in the *active* rice's rofi theme, so the
# menu you use to change themes always looks like the theme you are on.

set -euo pipefail

THEMES="$HOME/.config/themes"
LIST="$THEMES/profiles.list"
CURRENT="$THEMES/current"

current_name() {
    [ -L "$CURRENT" ] && basename "$(readlink "$CURRENT")" || echo ""
}

cur="$(current_name)"

# name|label|... -> "label" rows, with the active one marked. The name is
# recovered from the row index so labels are free to contain anything.
mapfile -t names < <(grep -vE '^\s*(#|$)' "$LIST" | cut -d'|' -f1)
mapfile -t labels < <(grep -vE '^\s*(#|$)' "$LIST" | cut -d'|' -f2)

rows=""
for i in "${!names[@]}"; do
    mark="   "
    [ "${names[$i]}" = "$cur" ] && mark="●  "
    rows+="${mark}${labels[$i]}"$'\n'
done

sel="$(printf '%s' "$rows" | rofi -dmenu -i \
        -p "rice" \
        -format i \
        -theme "$THEMES/picker.rasi" \
        -no-custom 2>/dev/null || true)"

[ -n "$sel" ] || exit 0
target="${names[$sel]}"
[ -n "$target" ] || exit 0
[ "$target" = "$cur" ] && exit 0

exec "$THEMES/switch.sh" "$target"
