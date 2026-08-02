#!/usr/bin/env bash
# mako/install.sh — notification daemon.
#
# There is nothing to link but the rice's mako.conf: this config is entirely
# per-theme, which is why the directory is otherwise empty.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=mako
hc_init "$@"

hc_deps mako

hc_run mkdir -p "$HC_CONFIG/mako"
hc_theme_link mako.conf "$HC_CONFIG/mako/config"

hc_done
