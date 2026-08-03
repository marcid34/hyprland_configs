#!/usr/bin/env bash
# calamity/mode.sh — swap the rice between its two biomes.
#
# The calamity rice has one shape and two palettes. Everything that carries
# colour lives in modes/<biome>/; the files switch.sh looks for at the rice
# root are symlinks into modes/current/. So switching biome is a single
# symlink repoint — the same trick themes/current uses, one level down — and
# then a normal re-apply of the rice so every app reloads.
#
# Usage:
#   mode.sh                     print the active biome
#   mode.sh --toggle            switch to the other one
#   mode.sh corruption|crimson  switch to a named one
#   mode.sh --waybar            JSON for the bar's button module
#   mode.sh --list              available biomes
#
# The bar's button calls this through `setsid -f`: re-applying the rice
# restarts waybar, which would otherwise kill this script as its own child
# mid-switch.

set -uo pipefail

RICE="$(dirname "$(readlink -f "$0")")"
MODES="$RICE/modes"
CURRENT="$MODES/current"
THEMES="$(dirname "$RICE")"
RICE_NAME="$(basename "$RICE")"

die() { echo "mode.sh: $*" >&2; exit 1; }

biomes() {
    find "$MODES" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort
}

active() {
    [ -L "$CURRENT" ] && basename "$(readlink "$CURRENT")" || echo ""
}

other() {
    local cur="$1" b
    while read -r b; do
        [ "$b" = "$cur" ] || { echo "$b"; return; }
    done < <(biomes)
}

apply() {
    local want="$1"
    [ -d "$MODES/$want" ] || die "no such biome: $want (have: $(biomes | tr '\n' ' '))"

    # Repoint atomically, so a reader never observes a missing `current`.
    ln -sfn "$MODES/$want" "$CURRENT.tmp"
    mv -Tf "$CURRENT.tmp" "$CURRENT"

    # Only re-apply if this rice is the live one. Switching biome while some
    # other rice is active should just record the choice for next time.
    local live=""
    [ -L "$THEMES/current" ] && live="$(basename "$(readlink "$THEMES/current")")"
    if [ "$live" = "$RICE_NAME" ]; then
        "$THEMES/switch.sh" "$RICE_NAME" >/dev/null 2>&1 || true
    fi
    echo "$want"
}

case "${1:---show}" in
    --show|"")
        active
        ;;
    --list)
        biomes
        ;;
    --waybar)
        cur="$(active)"
        [ -n "$cur" ] || cur="corruption"
        nxt="$(other "$cur")"
        case "$cur" in
            corruption) dot="#9d7cd8" ;;
            crimson)    dot="#c8443a" ;;
            *)          dot="#ffffff" ;;
        esac
        # Pango markup so the dot carries the biome colour while the label
        # stays at the bar's normal contrast.
        printf '{"text":"<span foreground=\\"%s\\">●</span>  %s","class":"%s","tooltip":"biome: %s — click to switch to %s"}\n' \
               "$dot" "$cur" "$cur" "$cur" "$nxt"
        ;;
    --toggle)
        cur="$(active)"
        [ -n "$cur" ] || cur="$(biomes | head -1)"
        apply "$(other "$cur")"
        ;;
    -*)
        die "unknown option: $1"
        ;;
    *)
        apply "$1"
        ;;
esac
