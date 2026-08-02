-- dawn — Neovim
--
-- Dawn — Rose Pine Dawn. A LIGHT rice: warm paper, ink, pine.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "dawn",
    bg        = "#faf4ed",
    bg1       = "#fffaf3",
    bg2       = "#f2e9e1",
    bg3       = "#dfdad9",
    fg        = "#575279",
    fg1       = "#797593",
    dim       = "#9893a5",
    sel       = "#dfdad9",
    accent    = "#286983",
    accent2   = "#907aa9",
    red       = "#b4637a",
    green     = "#618774",
    yellow    = "#ea9d34",
    blue      = "#286983",
    purple    = "#907aa9",
    cyan      = "#56949f",
    orange    = "#d7827e",
    transparent      = false,
    light            = true,
    italic_comments  = true,
    border           = "#dfdad9",
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
