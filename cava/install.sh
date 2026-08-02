#!/usr/bin/env bash
# cava/install.sh — audio visualiser.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=cava
hc_init "$@"

hc_deps cava
hc_hydrate
hc_link cava
hc_done
