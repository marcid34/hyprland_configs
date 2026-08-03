-- calamity (crimson) — Neovim
-- Crimtane red, ichor gold, bone. The Crimson: flesh caverns, a bloodied ground and pale bone arches on the horizon.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "calamity-crimson",
    bg        = "#1a0d0c",
    bg1       = "#22110f",
    bg2       = "#331916",
    bg3       = "#4a231c",
    fg        = "#f2ded8",
    fg1       = "#d9b6ac",
    dim       = "#9a716a",
    sel       = "#4a231c",
    accent    = "#c8443a",
    accent2   = "#e8b13d",
    red       = "#e05545",
    green     = "#8a9b7a",
    blue      = "#7d8fa0",
    purple    = "#a05a7a",
    cyan      = "#86a09b",
    orange           = "#e8b13d",
    yellow           = "#e8b13d",
    transparent      = false,
    light            = false,
    italic_comments  = true,
    border           = "#c8443a",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:|",
    laststatus = 3,
  },
}
