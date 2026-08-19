return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        -- blink.cmp already renders its own signature popup (see
        -- plugins/blink.lua); noice's auto-triggered signature help was
        -- firing at the same time, producing a second, full-doc popup
        -- stacked under blink's on every "(".
        signature = { enabled = false },
      },
    },
  },
}
