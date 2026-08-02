-- amber — Neovim
--
-- Amber CRT — single-phosphor terminal. One colour, tight grid, glow.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "amber",
    bg        = "#0c0a08",
    bg1       = "#141009",
    bg2       = "#1e1710",
    bg3       = "#2b2116",
    fg        = "#ffb000",
    fg1       = "#d99400",
    dim       = "#7a5400",
    sel       = "#3d2f10",
    accent    = "#ffb000",
    accent2   = "#ffcc55",
    red       = "#ff5f00",
    green     = "#ffb000",
    yellow    = "#ffcc55",
    blue      = "#d99400",
    purple    = "#ffb000",
    cyan      = "#ffcc55",
    orange    = "#ff8c00",
    transparent      = false,
    light            = false,
    italic_comments  = false,
    border           = "#2b2116",
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = true,
    cursorlineopt  = "number",
    winborder      = "solid",
    fillchars      = "eob: ,vert:|",
    laststatus     = 3,
  },
}
