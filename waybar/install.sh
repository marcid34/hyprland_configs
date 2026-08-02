#!/usr/bin/env bash
# waybar/install.sh — status bar. Config and stylesheet come from the rice.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=waybar
hc_init "$@"

# The custom modules under scripts/ shell out to these; waybar renders an
# empty module rather than erroring, so a miss here is quiet at runtime.
hc_deps waybar python3:python jq playerctl wpctl:wireplumber makoctl:mako \
        hyprctl:hyprland

hc_hydrate
hc_link waybar

hc_log "making bar scripts executable"
hc_run chmod +x "$HC_REPO/waybar/scripts"/*.sh "$HC_REPO/waybar/scripts"/*.py

hc_theme_link waybar.jsonc "$HC_CONFIG/waybar/config.jsonc"
hc_theme_link waybar.css   "$HC_CONFIG/waybar/style.css"

hc_done
