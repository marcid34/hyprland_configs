#!/usr/bin/env bash
# themes/install.sh — the rice system. Install this FIRST.
#
# Every other component reads its styling through ~/.config/themes/current,
# so until this runs and that symlink exists, waybar/mako/hyprlock/rofi have
# nothing to point at.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=themes
hc_init "$@"

# switch.sh drives every other app, so its dependency list is the union of
# what the rices can ask for. conky/yambar/nwg-dock are only used by some
# rices (see each profile's shell.components) and are checked separately.
hc_deps rofi python3:python hyprctl:hyprland makoctl:mako starship

hc_log "optional — only needed by rices that declare them in shell.components"
hc_deps waybar swww conky yambar nwg-dock-hyprland

hc_hydrate

hc_link themes

hc_log "making theme scripts executable"
hc_run chmod +x "$HC_REPO/themes"/*.sh

# Pick an active rice if there isn't one. First entry in profiles.list is the
# registry's canonical default; falling back to any directory keeps this
# working if the list is edited down.
CUR="$HC_CONFIG/themes/current"
if [ -L "$CUR" ] && [ -d "$CUR" ]; then
    hc_ok "active rice: $(basename "$(readlink "$CUR")")"
else
    DEFAULT="$(grep -vE '^\s*(#|$)' "$HC_REPO/themes/profiles.list" 2>/dev/null | head -1 | cut -d'|' -f1)"
    [ -n "$DEFAULT" ] && [ -d "$HC_REPO/themes/$DEFAULT" ] || \
        DEFAULT="$(find "$HC_REPO/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | head -1)"
    [ -n "$DEFAULT" ] || hc_die "no rices found in themes/"
    hc_log "no active rice — selecting '$DEFAULT'"
    hc_run ln -sfn "$HC_CONFIG/themes/$DEFAULT" "$CUR"
    hc_ok "active rice: $DEFAULT"
fi

# starship is the only theme link with no component directory of its own.
hc_theme_link starship.toml "$HC_CONFIG/starship.toml"

hc_log "wallpapers"
hc_info "images are NOT in this repo (48M, and mostly not mine to redistribute)."
hc_info "each rice points at ~/Pictures/Wallpapers/themes/<rice>.{jpg,png};"
hc_info "switch.sh skips a missing image rather than failing, so the rest of"
hc_info "the rice still applies. Drop your own in to fill them."

hc_done
