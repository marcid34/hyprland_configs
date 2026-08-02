-- tokyonight — Neovim
--
-- Tokyo Night — neon dusk. Deep navy glass, electric blue and violet.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "tokyonight",
    bg        = "#1a1b26",
    bg1       = "#16161e",
    bg2       = "#292e42",
    bg3       = "#3b4261",
    fg        = "#c0caf5",
    fg1       = "#a9b1d6",
    dim       = "#565f89",
    sel       = "#283457",
    accent    = "#7aa2f7",
    accent2   = "#bb9af7",
    red       = "#f7768e",
    green     = "#9ece6a",
    yellow    = "#e0af68",
    blue      = "#7aa2f7",
    purple    = "#bb9af7",
    cyan      = "#7dcfff",
    orange    = "#ff9e64",
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#3b4261",
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
