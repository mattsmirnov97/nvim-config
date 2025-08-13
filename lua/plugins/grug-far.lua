-- lua/plugins/grug-far.lua
return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "grug-far", "grugfar" },
        callback = function(ev)
          local function feed(keys)
            local k = vim.api.nvim_replace_termcodes(keys, true, false, true)
            vim.api.nvim_feedkeys(k, "m", false)
          end
          local ll = vim.g.maplocalleader or "\\"
          local function map_alt(ch)
            local lhs = "<A-" .. ch .. ">"
            local rhs = ll .. ch
            vim.keymap.set({ "n", "i" }, lhs, function()
              if vim.fn.mode() ~= "n" then
                feed("<Esc>")
              end
              feed(rhs)
            end, { buffer = ev.buf, silent = true, nowait = true })
          end
          for ch in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch(".") do
            map_alt(ch)
          end
        end,
      })
    end,
    keys = {
      { "<leader>sr", false },
      {
        "<leader>rD",
        function()
          local ok, util = pcall(require, "lazyvim.util")
          local root = (ok and util.root()) or vim.loop.cwd()
          require("grug-far").open({
            transient = true,
            prefills = { paths = vim.fn.fnameescape(root) },
          })
        end,
        desc = "Replace in Project (root)",
      },
      {
        "<leader>rd",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          local dir = (file ~= "" and vim.fn.fnamemodify(file, ":p:h")) or vim.loop.cwd()
          require("grug-far").open({
            transient = true,
            prefills = { paths = vim.fn.fnameescape(dir) },
          })
        end,
        desc = "Replace in Current File's Directory",
      },
      {
        "<leader>rc",
        function()
          local grug = require("grug-far")
          local file = vim.fn.expand("%:p")
          if file == "" then
            grug.open({ transient = true, prefills = { paths = vim.loop.cwd() } })
            return
          end
          grug.open({
            transient = true,
            prefills = { paths = vim.fn.fnameescape(file) },
          })
        end,
        desc = "Replace in Current File",
      },
    },
  },
}
