-- mono — Neovim
--
-- Mono — Swiss. No colour at all. Typography, grid and negative space.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "mono",
    bg        = "#0a0a0a",
    bg1       = "#121212",
    bg2       = "#1c1c1c",
    bg3       = "#2e2e2e",
    fg        = "#e8e8e8",
    fg1       = "#b4b4b4",
    dim       = "#6e6e6e",
    sel       = "#2e2e2e",
    accent    = "#ffffff",
    accent2   = "#9a9a9a",
    red       = "#c8c8c8",
    green     = "#e8e8e8",
    yellow    = "#d4d4d4",
    blue      = "#b4b4b4",
    purple    = "#9a9a9a",
    cyan      = "#c8c8c8",
    orange    = "#dcdcdc",
    transparent      = false,
    light            = false,
    italic_comments  = false,
    border           = "#2e2e2e",
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = true,
    cursorlineopt  = "number",
    winborder      = "rounded",
    fillchars      = "eob: ,vert:│",
    laststatus     = 3,
  },
}
