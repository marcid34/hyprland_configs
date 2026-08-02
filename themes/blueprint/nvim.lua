-- blueprint — Neovim
-- Blueprint — drafting table. Cyan hairlines on navy, all monospace.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "blueprint",
    bg        = "#06121f",
    bg1       = "#081a2b",
    bg2       = "#0d2438",
    bg3       = "#14344f",
    fg        = "#e8f4fb",
    fg1       = "#9dc9e0",
    dim       = "#3f6b8a",
    sel       = "#14344f",
    accent    = "#35d6ff",
    accent2   = "#7fe3ff",
    red       = "#ff6b8a",
    green     = "#5fe3c0",
    blue      = "#35d6ff",
    purple    = "#9ab6ff",
    cyan      = "#7fe3ff",
    orange           = "#7fe3ff",   -- no orange in this rice; alias the accent
    yellow           = "#7fe3ff",   -- ditto, keeps the builder's contract
    transparent      = false,
    light            = false,
    italic_comments  = false,
    border           = "#14344f",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:|",
    laststatus = 3,
  },
}
