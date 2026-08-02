-- haze — Neovim styling (Catppuccin Mocha)
--
-- Fully transparent, so the terminal's 0.62 opacity and Hyprland's 4-pass
-- blur pass straight through the editor — the point of this rice is that
-- every layer is glass, and an opaque editor would be the one flat surface
-- that breaks it.
--
-- Italics throughout: the soft counterpart to brutal's refusal of them.

return {
  catppuccin = {
    flavour                = "mocha",
    transparent_background = true,
    styles = {
      comments     = { "italic" },
      conditionals = { "italic" },
      keywords     = { "italic" },
      types        = { "italic" },
    },
    integrations = {
      cmp        = true,
      treesitter = true,
      mason      = true,
      native_lsp = { enabled = true },
    },
    custom_highlights = function(C)
      return {
        -- Floats stay transparent too, or they read as solid cards
        -- hovering over glass.
        NormalFloat  = { bg = C.none },
        FloatBorder  = { fg = C.pink, bg = C.none },
        CursorLineNr = { fg = C.pink },
        Visual       = { bg = C.surface1 },
        WinSeparator = { fg = C.surface0 },
        Pmenu        = { bg = C.none },
        PmenuSel     = { fg = C.pink, bg = C.surface0 },
        LineNr       = { fg = C.surface1 },
      }
    end,
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = false,
    winborder      = "rounded",
    fillchars      = "eob: ,vert: ",
    laststatus     = 3,
  },
}
