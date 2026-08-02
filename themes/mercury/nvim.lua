-- mercury — Neovim
-- Mercury — cool silver. Near-monochrome, one ice-blue accent.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "mercury",
    bg        = "#0e1013",
    bg1       = "#15181c",
    bg2       = "#1e2229",
    bg3       = "#2b313a",
    fg        = "#e6ecf2",
    fg1       = "#b8c2cd",
    dim       = "#6b7684",
    sel       = "#2b313a",
    accent    = "#6fa8dc",
    accent2   = "#a9c7e8",
    red       = "#e06c75",
    green     = "#8fb8a8",
    blue      = "#6fa8dc",
    purple    = "#9aa8c7",
    cyan      = "#a9c7e8",
    orange           = "#a9c7e8",   -- no orange in this rice; alias the accent
    yellow           = "#a9c7e8",   -- ditto, keeps the builder's contract
    transparent      = false,
    light            = false,
    italic_comments  = true,
    border           = "#2b313a",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
