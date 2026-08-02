#!/usr/bin/env bash
# nwg-drawer/install.sh — application drawer.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=nwg-drawer
hc_init "$@"

hc_deps nwg-drawer
hc_hydrate
hc_link nwg-drawer
hc_done
