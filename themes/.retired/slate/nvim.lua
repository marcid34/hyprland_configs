-- slate — Neovim styling (Catppuccin Mocha)
--
-- Opaque on mantle, matching the terminal, so editor and shell share one
-- flat surface. Everything is pulled a step quieter than default catppuccin:
-- greyer line numbers, a surface0 statusline instead of a coloured one, and
-- the blue accent reserved for the cursor line number and float borders —
-- the same restraint the bar uses.

return {
  catppuccin = {
    flavour                = "mocha",
    transparent_background = false,
    styles = {
      comments     = { "italic" },
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
        Normal       = { fg = C.subtext1, bg = C.mantle },
        NormalFloat  = { fg = C.subtext1, bg = C.base },
        FloatBorder  = { fg = C.surface1, bg = C.base },
        CursorLine   = { bg = C.base },
        CursorLineNr = { fg = C.blue },
        LineNr       = { fg = C.surface1 },
        StatusLine   = { fg = C.subtext0, bg = C.surface0 },
        StatusLineNC = { fg = C.overlay0, bg = C.base },
        Visual       = { bg = C.surface1 },
        WinSeparator = { fg = C.surface0 },
        Pmenu        = { fg = C.subtext0, bg = C.base },
        PmenuSel     = { fg = C.text, bg = C.surface0 },
        Comment      = { fg = C.overlay0, style = { "italic" } },
      }
    end,
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = true,
    cursorlineopt  = "number",
    winborder      = "single",
    fillchars      = "eob: ,vert:│",
    laststatus     = 3,
  },
}
