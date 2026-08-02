return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      html = { "prettierd" }, css = { "prettierd" },
      javascript = { "prettierd" }, typescript = { "prettierd" },
      json = { "prettierd" }, sh = { "shfmt" }, lua = { "stylua" },
    },
    format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
  },
}
