#!/usr/bin/env bash
# nwg-panel/install.sh — alternative panel.
#
# The icon sets that normally sit here (icons_light/, icons_dark/, icons_color/)
# ship with the package and are not tracked — 1.4M of files nobody edits. The
# package restores them on install; nothing here references them by repo path.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=nwg-panel
hc_init "$@"

hc_deps nwg-panel
hc_log "used by the executors/ modules"
hc_deps jq curl python3:python

hc_hydrate
hc_link nwg-panel

hc_log "making executors executable"
hc_run chmod +x "$HC_REPO/nwg-panel/executors"/*

hc_info "executors/github.sh reads a token from ~/.config/github/notifications.token"
hc_info "(upstream sample — delete the module if you don't use it)"

hc_done
