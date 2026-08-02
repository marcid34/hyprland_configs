-- nord — Neovim
-- Nord — arctic. Cool blue-greys, frost cyan, zero warmth.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "nord",
    bg        = "#2e3440",
    bg1       = "#272c36",
    bg2       = "#3b4252",
    bg3       = "#4c566a",
    fg        = "#eceff4",
    fg1       = "#d8dee9",
    dim       = "#6b7789",
    sel       = "#434c5e",
    accent    = "#88c0d0",
    accent2   = "#81a1c1",
    red       = "#bf616a",
    green     = "#a3be8c",
    blue      = "#5e81ac",
    purple    = "#b48ead",
    cyan      = "#8fbcbb",
    orange           = "#81a1c1",   -- no orange in this rice; alias the accent
    yellow           = "#81a1c1",   -- ditto, keeps the builder's contract
    transparent      = false,
    light            = false,
    italic_comments  = true,
    border           = "#4c566a",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:|",
    laststatus = 3,
  },
}
