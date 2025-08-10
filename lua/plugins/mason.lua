return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "gopls",
        "gofumpt",
        "goimports",
        "delve",
        "ruff",
        "ruff-lsp",
        "black",
        "isort",
        "pyright",
        "bash-language-server",
        "shellcheck",
        "shfmt",
      })
    end,
  },
}
