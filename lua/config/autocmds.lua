-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-resolve swapfiles left behind by dead sessions instead of showing the
-- interactive ATTENTION dialog.
--
-- Why this matters here specifically: snacks.nvim (file picker/explorer)
-- opens files via `vim.cmd("buffer "..bufnr)` called from Lua. Neovim can't
-- show an interactive swapfile prompt from inside a Lua-invoked `vim.cmd()`
-- call, so instead of prompting it throws `E325: ATTENTION` as a hard Lua
-- error (E5108) and aborts the command — which is why opening a file with a
-- stale swap through the explorer needs two Enter presses (the first
-- attempt errors out mid-way; the buffer ends up registered anyway, so the
-- retry succeeds).
--
-- Fix at the source: if the process that owns the swapfile is no longer
-- running, it's safe to just edit the file (no unsaved changes are at risk
-- — they're preserved in the swapfile until you overwrite it). If the owning
-- process IS still alive, fall back to the normal interactive dialog so a
-- genuinely concurrent session never gets silently clobbered.
vim.api.nvim_create_autocmd("SwapExists", {
  group = vim.api.nvim_create_augroup("resolve_stale_swapfiles", { clear = true }),
  callback = function()
    local info = vim.fn.swapinfo(vim.v.swapname)
    if info.pid and info.pid > 0 and info.host == vim.uv.os_gethostname() then
      local alive = vim.fn.system({ "kill", "-0", tostring(info.pid) }) and vim.v.shell_error == 0
      if not alive then
        vim.v.swapchoice = "e" -- edit anyway; swapfile is from a dead process
      end
    end
    -- otherwise: leave swapchoice unset so the normal dialog is shown
  end,
})
