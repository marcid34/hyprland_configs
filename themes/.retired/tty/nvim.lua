-- tty — Neovim styling (Catppuccin Mocha)
--
-- Opaque on crust, matching the terminal exactly so there is no visible
-- seam between shell and editor — in a console rice the editor is not a
-- separate surface, it is the same screen in a different mode.
--
-- ASCII-ish fillchars and a single-line winborder, because box-drawing at
-- this size is the closest thing to a curses frame.

return {
  catppuccin = {
    flavour                = "mocha",
    transparent_background = false,
    styles = {
      comments     = {},
      conditionals = {},
    },
    integrations = {
      cmp        = true,
      treesitter = true,
      mason      = true,
      native_lsp = { enabled = true },
    },
    custom_highlights = function(C)
      return {
        Normal       = { fg = C.green, bg = C.crust },
        NormalFloat  = { fg = C.green, bg = C.crust },
        FloatBorder  = { fg = C.green, bg = C.crust },
        CursorLine   = { bg = C.base },
        CursorLineNr = { fg = C.green, style = { "bold" } },
        LineNr       = { fg = C.surface1 },
        StatusLine   = { fg = C.crust, bg = C.green },
        StatusLineNC = { fg = C.overlay0, bg = C.base },
        Visual       = { fg = C.crust, bg = C.green },
        WinSeparator = { fg = C.surface1 },
        Pmenu        = { fg = C.green, bg = C.base },
        PmenuSel     = { fg = C.crust, bg = C.green },
        Comment      = { fg = C.overlay0 },
      }
    end,
  },

  opts = {
    number         = true,
    relativenumber = false,   -- absolute only; a console shows line numbers
    signcolumn     = "yes",
    cursorline     = true,
    cursorlineopt  = "line",
    winborder      = "single",
    fillchars      = "eob:~,vert:|",
    laststatus     = 2,
  },
}
