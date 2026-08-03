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

# The rest of this block is everything the *rices* ask for, as opposed to what
# switch.sh itself needs. None of it is fatal — a rice whose launcher or bar is
# absent falls back to rofi / runs bare — but "installed and working" should
# not mean "13 of the 33 profiles quietly look like something else", so all of
# it gets offered.
hc_log "launchers — each rice declares one in themes/<rice>/launcher"
hc_deps wofi fuzzel tofi nwg-drawer

hc_log "desktop shells — declared in themes/<rice>/shell.components"
hc_deps waybar swww conky yambar nwg-dock-hyprland nwg-panel quickshell

hc_log "cursor themes"
# Bibata is the session-wide default set in hypr/hyprland.lua; without it that
# variable names a theme that does not exist and you silently get the fallback.
hc_deps_cursor Bibata-Modern-Classic:bibata-cursor-theme-bin

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

# Rices that build their own cursors ship a make-cursor.py. Running it here
# means a fresh clone gets them without a separate manual step; it writes only
# into ~/.local/share/icons, so it needs no root.
for maker in "$HC_REPO"/themes/*/make-cursor.py; do
    [ -f "$maker" ] || continue
    # themes/current is a symlink to the active rice, so the glob finds every
    # such rice twice. Build each one once, under its real name.
    [ -L "$(dirname "$maker")" ] && continue
    rice="$(basename "$(dirname "$maker")")"
    hc_log "building $rice's cursors"
    hc_run python3 "$maker" || hc_warn "$rice cursor build failed — that rice keeps the session cursor"
done

hc_log "wallpapers"
hc_info "included in this repo under wallpapers/<rice>/, one folder per rice."
hc_info "point a rice somewhere else by editing themes/<rice>/wallpaper;"
hc_info "switch.sh skips a missing image rather than failing, so the rest of"
hc_info "the rice still applies."

hc_done
