-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

pcall(vim.keymap.del, "n", "<leader>qq")
pcall(vim.keymap.del, "n", "<leader>qa")

-- <leader>q = :q
vim.keymap.set("n", "<leader>q", "<cmd>close<cr>", { desc = "Close split", silent = true, nowait = true })
