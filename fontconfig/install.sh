#!/usr/bin/env bash
# fontconfig/install.sh — font rendering and family fallbacks.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=fontconfig
hc_init "$@"

hc_deps fc-cache:fontconfig

# Every family named by a rice's waybar.css, rofi.rasi or alacritty.toml. A
# missing font is not an error -- fontconfig substitutes something -- but the
# substitute is usually wrong enough to change the rice's whole character, and
# a missing Nerd Font turns every bar icon into tofu.
hc_deps_font \
    "JetBrainsMono Nerd Font:ttf-jetbrains-mono-nerd" \
    "JetBrainsMono Nerd Font Mono:ttf-jetbrains-mono-nerd" \
    "JetBrainsMono Nerd Font Propo:ttf-jetbrains-mono-nerd" \
    "UbuntuMono Nerd Font:ttf-ubuntu-mono-nerd" \
    "Symbols Nerd Font:ttf-nerd-fonts-symbols" \
    "Adwaita Sans:adwaita-fonts" \
    "Adwaita Mono:adwaita-fonts" \
    "Ubuntu:ttf-ubuntu-font-family" \
    "Ubuntu Mono:ttf-ubuntu-font-family" \
    "FreeSerif:gnu-free-fonts" \
    "FreeSans:gnu-free-fonts" \
    "xos4 Terminus:terminus-font"

hc_hydrate
hc_link fontconfig

if command -v fc-cache >/dev/null 2>&1; then
    hc_log "rebuilding font cache"
    hc_run fc-cache -f >/dev/null 2>&1 || hc_warn "fc-cache failed"
fi

hc_done
