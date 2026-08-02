#!/usr/bin/env bash
# btop/install.sh — resource monitor.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=btop
hc_init "$@"

hc_deps btop
hc_hydrate
hc_link btop
hc_done
