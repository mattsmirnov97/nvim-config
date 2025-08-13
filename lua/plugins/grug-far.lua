-- lua/plugins/grug-far.lua
return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {},
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
