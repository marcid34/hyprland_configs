return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- master is archived; main is the only option now
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "html", "css", "javascript", "typescript", "tsx",
      "json", "bash", "lua", "markdown", "vim", "vimdoc",
    })
    -- enable highlighting on any buffer that has a parser installed
    vim.api.nvim_create_autocmd("FileType", {
      callback = function() pcall(vim.treesitter.start) end,
    })
  end,
}
