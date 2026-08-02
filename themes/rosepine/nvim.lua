-- rosepine — Neovim
--
-- Rose Pine — soho vibes. Muted rose and iris on a deep plum base.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "rosepine",
    bg        = "#191724",
    bg1       = "#1f1d2e",
    bg2       = "#26233a",
    bg3       = "#403d52",
    fg        = "#e0def4",
    fg1       = "#908caa",
    dim       = "#6e6a86",
    sel       = "#403d52",
    accent    = "#ebbcba",
    accent2   = "#c4a7e7",
    red       = "#eb6f92",
    green     = "#a3be8c",
    yellow    = "#f6c177",
    blue      = "#9ccfd8",
    purple    = "#c4a7e7",
    cyan      = "#9ccfd8",
    orange    = "#f6c177",
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#403d52",
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
