return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- hand every server the completion capabilities (must run before enable)
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "html", "cssls", "ts_ls", "eslint",
        "emmet_language_server", "jsonls", "bashls", "lua_ls",
      },
    })

    -- keybinds that activate once a server attaches to a file
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local b = { buffer = ev.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, b)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, b)
        vim.keymap.set("n", "K",  vim.lsp.buf.hover, b)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, b)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, b)
      end,
    })
  end,
}
