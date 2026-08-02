#!/usr/bin/env bash
# alacritty/install.sh — terminal.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=alacritty
hc_init "$@"

hc_deps alacritty

# working_directory in alacritty.toml is an absolute path by necessity —
# alacritty 0.17 expands neither ~ nor $HOME there, it silently falls back to
# inheriting the parent's cwd. hc_hydrate rewrites it for this machine.
hc_hydrate
hc_link alacritty

hc_done
