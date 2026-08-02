-- emerald — Neovim
-- Emerald — deep green glass. Jewel tones on near-black forest.
-- Rendered by lua/config/theme.lua from this palette.

return {
  palette = {
    name = "emerald",
    bg        = "#071410",
    bg1       = "#0c1f18",
    bg2       = "#123024",
    bg3       = "#1a4433",
    fg        = "#d7f5e6",
    fg1       = "#9fd6bd",
    dim       = "#4b7a66",
    sel       = "#1a4433",
    accent    = "#2ee68a",
    accent2   = "#3ddbd9",
    red       = "#ff6b81",
    green     = "#2ee68a",
    blue      = "#21c7a8",
    purple    = "#8be0c2",
    cyan      = "#3ddbd9",
    orange           = "#3ddbd9",   -- no orange in this rice; alias the accent
    yellow           = "#3ddbd9",   -- ditto, keeps the builder's contract
    transparent      = true,
    light            = false,
    italic_comments  = true,
    border           = "#1a4433",
  },

  opts = {
    number = true, relativenumber = true, signcolumn = "yes",
    cursorline = true, cursorlineopt = "number",
    winborder = "single",
    fillchars = "eob: ,vert:│",
    laststatus = 3,
  },
}
