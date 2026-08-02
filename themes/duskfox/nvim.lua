-- duskfox — Neovim
-- Duskfox — muted violet night. Rose Pine's cousin, cooler and dimmer.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "duskfox",
    bg        = "#232136",
    bg1       = "#1d1b2a",
    bg2       = "#2d2a45",
    bg3       = "#393552",
    fg        = "#e0def4",
    fg1       = "#b6b3ce",
    dim       = "#6e6a86",
    sel       = "#393552",
    accent    = "#c4a7e7",
    accent2   = "#9ccfd8",
    red       = "#eb6f92",
    green     = "#a3be8c",
    blue      = "#569fba",
    purple    = "#c4a7e7",
    cyan      = "#9ccfd8",
    orange           = "#9ccfd8",   -- no orange in this rice; alias the accent
    yellow           = "#9ccfd8",   -- ditto, keeps the builder's contract
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#393552",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "rounded",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
