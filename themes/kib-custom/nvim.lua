-- kib-custom — Neovim styling (Catppuccin Mocha)
--
-- Transparent so the terminal's 0.9 opacity and Hyprland's blur read
-- straight through the editor, matching the translucent-island language
-- of the bar. Rounded float borders echo the 10px window rounding.
--
-- Consumed by lua/plugins/colorscheme.lua via dofile().
-- `catppuccin` is passed to require("catppuccin").setup();
-- `opts` are applied to vim.opt after the colorscheme loads.

return {
  catppuccin = {
    flavour               = "mocha",
    transparent_background = true,
    styles = {
      comments    = { "italic" },
      conditionals = { "italic" },
    },
    integrations = {
      cmp        = true,
      treesitter = true,
      mason      = true,
      native_lsp = { enabled = true },
    },
  },

  opts = {
    number         = true,
    relativenumber = true,
    signcolumn     = "yes",
    cursorline     = false,
    winborder      = "rounded",
    fillchars      = "eob: ,vert:│",
    laststatus     = 2,
  },
}
