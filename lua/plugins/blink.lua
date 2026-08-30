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
        -- Tab jumps out of the pair mini.pairs just closed (or to the next
        -- snippet placeholder first, if one is active) instead of indenting.
        -- Steps over exactly one closer per press — one Tab = one nesting
        -- level, so `)}` needs two presses, matching how the pair was built
        -- up in the first place. Returns the actual <Right> keycode rather
        -- than mutating the cursor directly — this runs inside an
        -- expr-mapping, and buffer/window edits are textlocked there, so
        -- nvim_win_set_cursor is a silent no-op; only returning keys to be
        -- fed is safe.
        ["<Tab>"] = {
          "snippet_forward",
          function()
            local close_chars = { [")"] = true, ["]"] = true, ["}"] = true, ['"'] = true, ["'"] = true, ["`"] = true }
            local col = vim.fn.col(".")
            local char = vim.fn.getline("."):sub(col, col)
            if not close_chars[char] then return false end
            return vim.api.nvim_replace_termcodes("<Right>", true, true, true)
          end,
          "fallback",
        },
      },
    },
  },
}
