#!/usr/bin/env bash
# nwg-dock-hyprland/install.sh — dock, used by the rices that ask for it.
#
# Only started for profiles whose shell.components names it (see themes/shell.sh).

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=nwg-dock-hyprland
hc_init "$@"

hc_deps nwg-dock-hyprland
hc_hydrate
hc_link nwg-dock-hyprland
hc_done
