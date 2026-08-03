-- QShell Showcase — Neovim
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "qshell",
    bg        = "#0a0c0f",
    bg1       = "#111419",
    bg2       = "#171b22",
    bg3       = "#222833",
    fg        = "#eef2f7",
    fg1       = "#93a0b0",
    dim       = "#5c6673",
    sel       = "#222833",
    accent    = "#5b9dff",
    accent2   = "#4ade80",
    red       = "#f87171",
    green     = "#4ade80",
    blue      = "#5b9dff",
    purple    = "#a78bfa",
    cyan      = "#22d3ee",
    orange    = "#fbbf24",
    yellow    = "#fbbf24",
    transparent      = false,
    light            = false,
    italic_comments  = true,
    border           = "#222833",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:|",
    laststatus = 3,
  },
}
