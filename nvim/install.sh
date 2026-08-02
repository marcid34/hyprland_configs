#!/usr/bin/env bash
# nvim/install.sh — editor. Colourscheme follows the active rice.

source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
HC_COMPONENT=nvim
hc_init "$@"

# lazy.nvim clones plugins over git on first launch; the rest are what the
# LSP/treesitter specs shell out to.
hc_deps nvim:neovim git

hc_hydrate
hc_link nvim

hc_info "plugins install themselves on first launch (lazy.nvim, pinned by lazy-lock.json)"
hc_info "colourscheme tracks themes/current/nvim.lua — :ThemeReload applies it live"

hc_done
