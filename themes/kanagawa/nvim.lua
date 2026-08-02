-- kanagawa — Neovim
--
-- Kanagawa — ink wash. Warm sumi blacks, wave blue and carp yellow.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "kanagawa",
    bg        = "#1f1f28",
    bg1       = "#16161d",
    bg2       = "#2a2a37",
    bg3       = "#363646",
    fg        = "#dcd7ba",
    fg1       = "#c8c093",
    dim       = "#727169",
    sel       = "#2d4f67",
    accent    = "#e6c384",
    accent2   = "#7e9cd8",
    red       = "#c34043",
    green     = "#98bb6c",
    yellow    = "#e6c384",
    blue      = "#7e9cd8",
    purple    = "#957fb8",
    cyan      = "#7aa89f",
    orange    = "#ffa066",
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#363646",
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = true,
    cursorlineopt  = "number",
    winborder      = "rounded",
    fillchars      = "eob: ,vert:│",
    laststatus     = 3,
  },
}
