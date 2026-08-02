-- abyss — Neovim
-- Abyss — deep water. Near-black navy, teal and electric cyan.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "abyss",
    bg        = "#0b1220",
    bg1       = "#0f1a2b",
    bg2       = "#152438",
    bg3       = "#1d3050",
    fg        = "#cfe3f5",
    fg1       = "#9fbcd6",
    dim       = "#4a6483",
    sel       = "#1d3050",
    accent    = "#2ec4b6",
    accent2   = "#48cae4",
    red       = "#ef476f",
    green     = "#2ec4b6",
    blue      = "#4895ef",
    purple    = "#7b6cf6",
    cyan      = "#48cae4",
    orange           = "#48cae4",   -- no orange in this rice; alias the accent
    yellow           = "#48cae4",   -- ditto, keeps the builder's contract
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#1d3050",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "rounded",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
