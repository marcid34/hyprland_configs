vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")

-- Transparency is a per-rice decision now: it comes from
-- ~/.config/themes/current/nvim.lua via catppuccin's transparent_background.
-- The hardcoded Normal/NormalFloat/FloatBorder/Pmenu bg=none that used to
-- live here would have overridden every theme that wants an opaque editor.
