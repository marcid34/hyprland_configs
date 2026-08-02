-- Colours, configured by the active rice.
--
-- ~/.config/themes/current/nvim.lua returns one of two shapes:
--
--   { catppuccin = <setup opts>, opts = <vim.opt> }   -- plugin-backed
--   { palette    = <colour table>, opts = <vim.opt> } -- builder-backed
--
-- kib-custom uses the catppuccin plugin (unchanged). Every other rice
-- supplies a palette and is rendered by config.theme, which avoids pulling
-- in nine separate upstream colorscheme plugins just to recolour an editor.

local THEME = os.getenv("HOME") .. "/.config/themes/current/nvim.lua"

local function load()
  local ok, theme = pcall(dofile, THEME)
  if not ok or type(theme) ~= "table" then
    vim.notify("theme: could not load " .. THEME .. " -- using defaults",
      vim.log.levels.WARN)
    return { catppuccin = { flavour = "mocha" }, opts = {} }
  end
  theme.opts = theme.opts or {}
  return theme
end

local function apply(theme)
  if theme.palette then
    require("config.theme").apply(theme.palette)
  else
    require("catppuccin").setup(theme.catppuccin or { flavour = "mocha" })
    vim.cmd.colorscheme("catppuccin")
  end
  -- After the colorscheme, so a rice can set fillchars/winborder without
  -- the scheme clobbering them.
  for k, v in pairs(theme.opts) do
    vim.opt[k] = v
  end
end

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    apply(load())

    -- Re-read the rice without restarting nvim.
    vim.api.nvim_create_user_command("ThemeReload", function()
      package.loaded["catppuccin"] = nil
      package.loaded["config.theme"] = nil
      apply(load())
      local link = (vim.uv or vim.loop).fs_readlink(
        os.getenv("HOME") .. "/.config/themes/current")
      vim.notify("theme: reloaded " .. vim.fn.fnamemodify(link or "?", ":t"))
    end, { desc = "Reload the active rice's nvim styling" })
  end,
}
