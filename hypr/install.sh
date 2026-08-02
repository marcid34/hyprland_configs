#!/usr/bin/env bash
# hypr/install.sh — the compositor itself, plus idle/lock/wallpaper daemons.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=hypr
hc_init "$@"

# Split by what breaks without them: the first list is the desktop, the
# second is only reachable through a keybind (see hyprland.lua).
hc_deps hyprland hypridle hyprlock hyprpaper python3:python
hc_log "keybind targets"
hc_deps grim slurp swappy wl-copy:wl-clipboard brightnessctl playerctl \
        wpctl:wireplumber thunar

hc_hydrate
hc_link hypr

# Per-rice lock screen. hyprpaper.conf is deliberately absent from the repo:
# switch.sh regenerates it from `hyprctl monitors` on every theme change, so
# it is machine-specific output rather than configuration.
hc_theme_link hyprlock.conf "$HC_CONFIG/hypr/hyprlock.conf"

hc_log "monitors"
hc_info "hyprland.lua pins eDP-1 and HDMI-A-2 to explicit coordinates."
hc_info "On different hardware, edit the hl.monitor{} blocks at the top —"
hc_info "or replace both with:  hl.monitor({ output = ',preferred,auto,1' })"

hc_done
