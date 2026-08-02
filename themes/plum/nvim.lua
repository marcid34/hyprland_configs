-- plum — Neovim
-- Plum — aubergine and magenta. Rich, saturated, unapologetic.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "plum",
    bg        = "#17101d",
    bg1       = "#1e1526",
    bg2       = "#291c33",
    bg3       = "#3a2949",
    fg        = "#ecd9f5",
    fg1       = "#c4a8d4",
    dim       = "#7a5f8c",
    sel       = "#3a2949",
    accent    = "#e05fc4",
    accent2   = "#a678e0",
    red       = "#e5527a",
    green     = "#7fd6a8",
    blue      = "#6bb8e8",
    purple    = "#a678e0",
    cyan      = "#6bd6d6",
    orange           = "#a678e0",   -- no orange in this rice; alias the accent
    yellow           = "#a678e0",   -- ditto, keeps the builder's contract
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#3a2949",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "rounded",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
