#!/usr/bin/env bash
# Start the active rice's desktop shell.
#
# Rices no longer all run waybar. Each declares its components in
# themes/<n>/shell.components; this tears down whatever the previous rice was
# running and brings up the new one's. That is what makes a profile a
# different desktop rather than a different stylesheet.
#
# Components:
#   waybar     one or more bars (the config may be a JSON array)
#   conky      readout drawn on the wallpaper, no bar
#   yambar     a different bar program entirely
#   nwg-dock   floating dock, macOS-shaped
#   (none)     no persistent chrome; status is summoned with SUPER+I

set -uo pipefail

THEMES="$HOME/.config/themes"
CUR="$THEMES/current"
COMPONENTS_FILE="$CUR/shell.components"

# Everything a rice might run. Killed unconditionally on switch so a
# component from the previous rice can never linger over the new one.
ALL="waybar conky yambar nwg-dock nwg-panel"

stop_all() {
    for c in $ALL; do pkill -x "$c" 2>/dev/null; done
    # nwg-dock-hyprland is 17 chars; Linux truncates comm to 15, so it shows
    # as "nwg-dock-hyprla" and `pkill -x nwg-dock-hyprland` never matches --
    # the dock would survive every switch and stack up. Match on the full
    # command line instead.
    pkill -f '^nwg-dock-hyprland' 2>/dev/null
    for _ in $(seq 20); do
        pgrep -x waybar >/dev/null 2>&1 || break
        sleep 0.05
    done
}

start() {
    local comps
    comps="$(cat "$COMPONENTS_FILE" 2>/dev/null || echo waybar)"

    # An empty components file means "no chrome, deliberately" (midnight,
    # matrix, mono, eink) -- respect that. But a rice that *asked* for a panel
    # and cannot have it because the package is missing should not come up
    # bare; fall back to waybar, which every rice has a config for.
    # Only a missing *panel* triggers the fallback. conky is a desktop
    # readout, not a bar: amber and matrix declare conky precisely because
    # they want no panel, and swapping in waybar there would override the
    # rice's whole point. nwg-dock is likewise supplementary.
    local panel_wanted=0 panel_have=0
    for c in $comps; do
        case "$c" in
            waybar|nwg-panel|yambar)
                panel_wanted=1
                if [ "$c" = waybar ] || command -v "$c" >/dev/null; then
                    panel_have=1
                fi ;;
        esac
    done
    if [ "$panel_wanted" = 1 ] && [ "$panel_have" = 0 ]; then
        comps="waybar $(printf '%s' "$comps" | tr ' ' '\n' \
               | grep -vE '^(nwg-panel|yambar)$' | tr '\n' ' ')"
    fi
    for c in $comps; do
        case "$c" in
            waybar)
                setsid waybar >/dev/null 2>&1 </dev/null & ;;
            conky)
                command -v conky >/dev/null && \
                  setsid conky -c "$CUR/conky.conf" >/dev/null 2>&1 </dev/null & ;;
            yambar)
                command -v yambar >/dev/null && \
                  setsid yambar -c "$CUR/yambar.yml" >/dev/null 2>&1 </dev/null & ;;
            nwg-panel)
                command -v nwg-panel >/dev/null && \
                  setsid nwg-panel -c "$CUR/nwg-panel.json" \
                         -s "$CUR/nwg-panel.css" >/dev/null 2>&1 </dev/null & ;;
            nwg-dock)
                # -s takes a *file name*, which nwg-dock resolves inside its
                # own config dir -- handing it an absolute path yields
                # ~/.config/nwg-dock-hyprland/home/birch/... and a fatal exit.
                # So stage this rice's stylesheet there and pass the bare name.
                if command -v nwg-dock-hyprland >/dev/null; then
                    mkdir -p "$HOME/.config/nwg-dock-hyprland"
                    cp -f "$CUR/dock.css" \
                          "$HOME/.config/nwg-dock-hyprland/rice.css" 2>/dev/null
                    # Position/size vary by rice (macOS wants a centred
                    # bottom dock, others differ), so read dock.args if the
                    # profile ships one.
                    local dargs="-r -i 34 -mb 12"
                    [ -r "$CUR/dock.args" ] && dargs="$(cat "$CUR/dock.args")"
                    # shellcheck disable=SC2086
                    setsid nwg-dock-hyprland -r $dargs \
                           -s rice.css >/dev/null 2>&1 </dev/null &
                fi ;;
        esac
        sleep 0.15
    done
}

case "${1:-restart}" in
    stop)    stop_all ;;
    start)   start ;;
    restart) stop_all; start ;;
    which)   cat "$COMPONENTS_FILE" 2>/dev/null || echo "waybar" ;;
    *)       echo "usage: shell.sh [start|stop|restart|which]" >&2; exit 2 ;;
esac
