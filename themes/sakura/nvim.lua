-- sakura — Neovim
-- Sakura — blossom at night. Soft pink and lilac on plum-black.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "sakura",
    bg        = "#1a1520",
    bg1       = "#221b29",
    bg2       = "#2e2436",
    bg3       = "#3d3047",
    fg        = "#f2e6ef",
    fg1       = "#cdb8c8",
    dim       = "#7a6377",
    sel       = "#3d3047",
    accent    = "#f2a6c2",
    accent2   = "#c9a7d4",
    red       = "#e8748f",
    green     = "#a7e0c8",
    blue      = "#a8d8ea",
    purple    = "#c9a7d4",
    cyan      = "#a8d8ea",
    orange           = "#c9a7d4",   -- no orange in this rice; alias the accent
    yellow           = "#c9a7d4",   -- ditto, keeps the builder's contract
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#3d3047",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "rounded",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
