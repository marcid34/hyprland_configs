-- oxocarbon — Neovim
--
-- Oxocarbon — IBM Carbon. Near-black, hard edges, electric magenta.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "oxocarbon",
    bg        = "#161616",
    bg1       = "#101010",
    bg2       = "#262626",
    bg3       = "#393939",
    fg        = "#f2f4f8",
    fg1       = "#dde1e6",
    dim       = "#525252",
    sel       = "#393939",
    accent    = "#ee5396",
    accent2   = "#33b1ff",
    red       = "#ff7eb6",
    green     = "#42be65",
    yellow    = "#ffe97b",
    blue      = "#33b1ff",
    purple    = "#be95ff",
    cyan      = "#3ddbd9",
    orange    = "#ff6f00",
    transparent      = false,
    light            = false,
    italic_comments  = true,
    border           = "#393939",
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
