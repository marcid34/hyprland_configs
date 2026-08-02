-- dracula — Neovim
-- Dracula — the classic. Violet, magenta and cyan on graphite.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "dracula",
    bg        = "#282a36",
    bg1       = "#21222c",
    bg2       = "#343746",
    bg3       = "#44475a",
    fg        = "#f8f8f2",
    fg1       = "#d8d8d2",
    dim       = "#6272a4",
    sel       = "#44475a",
    accent    = "#bd93f9",
    accent2   = "#ff79c6",
    red       = "#ff5555",
    green     = "#50fa7b",
    blue      = "#8be9fd",
    purple    = "#bd93f9",
    cyan      = "#8be9fd",
    orange           = "#ff79c6",   -- no orange in this rice; alias the accent
    yellow           = "#ff79c6",   -- ditto, keeps the builder's contract
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#44475a",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "rounded",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
