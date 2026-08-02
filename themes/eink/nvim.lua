-- eink — Neovim
-- E-ink — paper. Pure black on warm white, no colour, no gloss.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "eink",
    bg        = "#f7f7f4",
    bg1       = "#ffffff",
    bg2       = "#ebebe6",
    bg3       = "#d6d6cf",
    fg        = "#111111",
    fg1       = "#3a3a38",
    dim       = "#8a8a84",
    sel       = "#d6d6cf",
    accent    = "#111111",
    accent2   = "#5a5a56",
    red       = "#8c2f39",
    green     = "#3a5a40",
    blue      = "#2b4c7e",
    purple    = "#4a3f6b",
    cyan      = "#2f5d62",
    orange           = "#5a5a56",   -- no orange in this rice; alias the accent
    yellow           = "#5a5a56",   -- ditto, keeps the builder's contract
    transparent      = false,
    light            = true,
    italic_comments  = false,
    border           = "#d6d6cf",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:|",
    laststatus = 3,
  },
}
