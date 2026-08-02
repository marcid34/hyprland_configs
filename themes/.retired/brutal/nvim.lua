-- brutal — Neovim styling (Catppuccin Mocha)
--
-- Opaque on crust to match the terminal exactly, so the editor reads as one
-- solid slab rather than a translucent layer. No italics anywhere: this rice
-- has no soft edges, and slanted text is a soft edge. Single-line borders,
-- cursorline on, block fills for the statusline.

return {
  catppuccin = {
    flavour                = "mocha",
    transparent_background = false,
    styles = {
      comments     = {},
      conditionals = {},
      keywords     = { "bold" },
      functions    = { "bold" },
    },
    integrations = {
      cmp        = true,
      treesitter = true,
      mason      = true,
      native_lsp = { enabled = true },
    },
    custom_highlights = function(C)
      return {
        Normal       = { bg = C.crust },
        NormalFloat  = { bg = C.crust },
        FloatBorder  = { fg = C.text, bg = C.crust },
        CursorLine   = { bg = C.surface0 },
        CursorLineNr = { fg = C.yellow, style = { "bold" } },
        StatusLine   = { fg = C.crust, bg = C.yellow, style = { "bold" } },
        Visual       = { fg = C.crust, bg = C.yellow },
        WinSeparator = { fg = C.text },
        Pmenu        = { bg = C.base },
        PmenuSel     = { fg = C.crust, bg = C.yellow, style = { "bold" } },
      }
    end,
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = true,
    cursorlineopt  = "number,line",
    winborder      = "solid",
    fillchars      = "eob: ,vert:█",
    laststatus     = 2,
  },
}
