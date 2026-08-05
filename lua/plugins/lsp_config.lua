return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              analyses = { unusedparams = true, shadow = true },
              -- calling a function should just give you `Foo()` with the
              -- cursor inside, not the whole signature typed out as text
              usePlaceholders = false,
              hints = {
                -- inline "paramName:" hint before call arguments breaks
                -- left/Home cursor movement into the real text
                parameterNames = false,
              },
            },
          },
        },
        bashls = {},
      },
    },
  },
}
