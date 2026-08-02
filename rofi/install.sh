#!/usr/bin/env bash
# rofi/install.sh — launcher.
#
# config.rasi is a single @import into the active rice, written relative to
# the config file so it needs no path rewriting (verified: rofi resolves
# @import relative to the importing file).

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=rofi
hc_init "$@"

hc_deps rofi

hc_hydrate
hc_link rofi

hc_done
