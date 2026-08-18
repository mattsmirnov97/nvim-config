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
          -- bordered so the popup reads as its own floating window
          -- instead of blending into / overlapping the code behind it
          border = "rounded",
        },
        documentation = {
          -- no floating doc popup unless you ask for it (avoids extra
          -- LSP resolve requests + flicker while browsing the list)
          auto_show = false,
          window = { border = "rounded" },
        },
        accept = {
          -- avoid double/misplaced brackets together with mini.pairs
          auto_brackets = { enabled = false },
        },
      },
      -- so <C-k> in insert mode drives one coherent signature popup
      -- instead of fighting with LazyVim's native vim.lsp.buf.signature_help
      signature = { enabled = true, window = { border = "rounded" } },

      keymap = {
        preset = "enter",
        -- close the menu (if open) AND move the cursor right on the same
        -- keypress. "hide" alone returns true and swallows the press, so
        -- {"hide", "fallback"} needed two presses: one to close, one to move.
        ["<Right>"] = {
          function(cmp)
            cmp.hide()
            return false -- always fall through to the real <Right>
          end,
          "fallback",
        },
      },
    },
  },
}
