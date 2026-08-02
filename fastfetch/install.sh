#!/usr/bin/env bash
# fastfetch/install.sh — system fetch, themed per rice.
#
# Like mako, the whole config lives in the rice, so this directory holds only
# the installer.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=fastfetch
hc_init "$@"

hc_deps fastfetch

hc_run mkdir -p "$HC_CONFIG/fastfetch"
hc_theme_link fastfetch.jsonc "$HC_CONFIG/fastfetch/config.jsonc"

hc_done
