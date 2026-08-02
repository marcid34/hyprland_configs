-- outrun — Neovim
--
-- Outrun — 1984 neon. Indigo night, hot magenta, cyan horizon.
--
-- Rendered by lua/config/theme.lua, which turns this palette into a full
-- highlight set (syntax, treesitter, LSP, diagnostics, cmp, diff, terminal).

return {
  palette = {
    name = "outrun",
    bg        = "#0d0221",
    bg1       = "#190b33",
    bg2       = "#241b4d",
    bg3       = "#3b2d6b",
    fg        = "#f0e6ff",
    fg1       = "#c9b8f0",
    dim       = "#6b5b9a",
    sel       = "#3b2d6b",
    accent    = "#ff2e97",
    accent2   = "#00f0ff",
    red       = "#ff2e97",
    green     = "#3bf4a0",
    yellow    = "#fffb96",
    blue      = "#00f0ff",
    purple    = "#b967ff",
    cyan      = "#00f0ff",
    orange    = "#ff9e2c",
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#3b2d6b",
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
