-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

pcall(vim.keymap.del, "n", "<leader>qq")
pcall(vim.keymap.del, "n", "<leader>qa")

-- <leader>q = :q
vim.keymap.set("n", "<leader>q", "<cmd>close<cr>", { desc = "Close split", silent = true, nowait = true })

local map = vim.keymap.set

map("n", "<A-w>", "<C-w>k", { desc = "Window Up", silent = true, nowait = true })
map("n", "<A-a>", "<C-w>h", { desc = "Window Left", silent = true, nowait = true })
map("n", "<A-s>", "<C-w>j", { desc = "Window Down", silent = true, nowait = true })
map("n", "<A-d>", "<C-w>l", { desc = "Window Right", silent = true, nowait = true })

map("t", "<A-w>", [[<C-\><C-n><C-w>k]], { desc = "Window Up (term)", silent = true, nowait = true })
map("t", "<A-a>", [[<C-\><C-n><C-w>h]], { desc = "Window Left (term)", silent = true, nowait = true })
map("t", "<A-s>", [[<C-\><C-n><C-w>j]], { desc = "Window Down (term)", silent = true, nowait = true })
map("t", "<A-d>", [[<C-\><C-n><C-w>l]], { desc = "Window Right (term)", silent = true, nowait = true })
