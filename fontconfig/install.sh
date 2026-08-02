#!/usr/bin/env bash
# fontconfig/install.sh — font rendering and family fallbacks.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=fontconfig
hc_init "$@"

hc_deps fc-cache:fontconfig
hc_hydrate
hc_link fontconfig

if command -v fc-cache >/dev/null 2>&1; then
    hc_log "rebuilding font cache"
    hc_run fc-cache -f >/dev/null 2>&1 || hc_warn "fc-cache failed"
fi

hc_info "the bars and terminal expect a Nerd Font — ttf-jetbrains-mono-nerd is a safe default"

hc_done
