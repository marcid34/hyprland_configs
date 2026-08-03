-- calamity (corruption) — Neovim
-- Shadow-purple void, cursed-flame green. The Corruption: vertical chasms, demonite, and a sky that never warms.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "calamity-corruption",
    bg        = "#191029",
    bg1       = "#1f1533",
    bg2       = "#2b1e47",
    bg3       = "#3b2a60",
    fg        = "#e2d8f5",
    fg1       = "#c3b3e4",
    dim       = "#7d6ba8",
    sel       = "#3b2a60",
    accent    = "#9d7cd8",
    accent2   = "#7bd88f",
    red       = "#d2688f",
    green     = "#7bd88f",
    blue      = "#6a5acd",
    purple    = "#b48ee8",
    cyan      = "#74c7d8",
    orange           = "#d8b96a",
    yellow           = "#d8b96a",
    transparent      = false,
    light            = false,
    italic_comments  = true,
    border           = "#9d7cd8",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:|",
    laststatus = 3,
  },
}
