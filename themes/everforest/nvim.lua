-- everforest — Neovim
--
-- Everforest — soft forest. Low-contrast greens, warm greys, easy eyes.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "everforest",
    bg        = "#2d353b",
    bg1       = "#272e33",
    bg2       = "#343f44",
    bg3       = "#475258",
    fg        = "#d3c6aa",
    fg1       = "#9da9a0",
    dim       = "#7a8478",
    sel       = "#475258",
    accent    = "#a7c080",
    accent2   = "#83c092",
    red       = "#e67e80",
    green     = "#a7c080",
    yellow    = "#dbbc7f",
    blue      = "#7fbbb3",
    purple    = "#d699b6",
    cyan      = "#83c092",
    orange    = "#e69875",
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#475258",
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
