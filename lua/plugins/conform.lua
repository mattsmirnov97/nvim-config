return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { timeout_ms = 1500, lsp_fallback = true },
      formatters_by_ft = {
        go = { "gofumpt", "goimports" },
        python = { "isort", "black" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
    },
  },
}
