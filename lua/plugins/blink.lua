return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = {
          selection = {
            -- don't highlight/insert the top match automatically — nothing
            -- touches the buffer until you explicitly pick an item
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          auto_show = true,
        },
        documentation = {
          -- no floating doc popup unless you ask for it (avoids extra
          -- LSP resolve requests + flicker while browsing the list)
          auto_show = false,
        },
        accept = {
          -- avoid double/misplaced brackets together with mini.pairs
          auto_brackets = { enabled = false },
        },
      },
      -- so <C-k> in insert mode drives one coherent signature popup
      -- instead of fighting with LazyVim's native vim.lsp.buf.signature_help
      signature = { enabled = true },

      keymap = {
        preset = "enter",
        -- if the menu is open, just close it and keep moving right;
        -- otherwise behaves like a normal right arrow
        ["<Right>"] = { "hide", "fallback" },
      },
    },
  },
}
