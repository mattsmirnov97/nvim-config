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

-- Force the macOS input source to US whenever this nvim's terminal window is
-- actually focused and we're not mid-Insert — covers what 'langmap' (see
-- options.lua) structurally cannot: which-key's leader menu (it reads keys
-- via getcharstr(), which bypasses langmap entirely) and the `:`/`/` command
-- line (langmap explicitly excludes it, since that input is also used for
-- free text like search patterns).
--
-- SAFETY, rewritten after a previous version of this hijacked the OS layout
-- system-wide while nvim sat unfocused in the background: every single
-- macism call below is gated on `terminal_is_frontmost()`, an independent
-- OS-level check (`lsappinfo front`) of which app is *actually* in the
-- foreground right now — not just "did nvim last see a FocusGained". That
-- check fails closed (assumes NOT frontmost) on any uncertainty, including
-- not recognizing $TERM_PROGRAM at all. FocusGained/FocusLost only start and
-- stop the polling loop as an efficiency measure; they are not themselves
-- trusted as the safety boundary — even if a FocusLost is ever missed and
-- the poll keeps ticking, each tick still independently verifies real focus
-- before touching anything.
if vim.fn.executable("macism") == 1 and vim.fn.executable("lsappinfo") == 1 then
  local us_layout = "com.apple.keylayout.US"
  local saved_layout = nil
  local poll = nil

  local term_bundle_ids = {
    ghostty = "com.mitchellh.ghostty",
    ["iTerm.app"] = "com.googlecode.iterm2",
    Apple_Terminal = "com.apple.Terminal",
    WezTerm = "com.github.wez.wezterm",
    alacritty = "org.alacritty",
    kitty = "net.kovidgoyal.kitty",
  }
  local my_bundle_id = term_bundle_ids[vim.env.TERM_PROGRAM]

  local function terminal_is_frontmost()
    if not my_bundle_id then return false end -- unrecognized terminal: fail closed
    local front = vim.system({ "lsappinfo", "front" }, { text = true }):wait(200)
    local asn = front and front.code == 0 and vim.trim(front.stdout) or nil
    if not asn or asn == "" then return false end
    local info = vim.system({ "lsappinfo", "info", "-only", "bundleid", asn }, { text = true }):wait(200)
    if not info or info.code ~= 0 then return false end
    return (info.stdout or ""):find(my_bundle_id, 1, true) ~= nil
  end

  local function force_us()
    if not terminal_is_frontmost() then return end
    local mode = vim.api.nvim_get_mode().mode
    if mode:sub(1, 1) == "i" then return end
    local out = vim.system({ "macism" }, { text = true }):wait(200)
    local current = out and out.code == 0 and vim.trim(out.stdout) or nil
    if current and current ~= us_layout then
      saved_layout = current
      vim.system({ "macism", us_layout, "0" })
    end
  end

  local layout_group = vim.api.nvim_create_augroup("layout_agnostic_normal_mode", { clear = true })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = layout_group,
    callback = function()
      if not terminal_is_frontmost() then return end
      local out = vim.system({ "macism" }, { text = true }):wait(200)
      local current = out and out.code == 0 and vim.trim(out.stdout) or nil
      if current and current ~= us_layout then
        saved_layout = current
        vim.system({ "macism", us_layout, "0" })
      else
        saved_layout = nil
      end
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = layout_group,
    callback = function()
      if saved_layout and terminal_is_frontmost() then
        vim.system({ "macism", saved_layout, "0" })
      end
    end,
  })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = layout_group,
    callback = function()
      force_us()
      if poll then
        poll:stop()
      else
        poll = vim.uv.new_timer()
      end
      poll:start(500, 500, vim.schedule_wrap(force_us))
    end,
  })

  vim.api.nvim_create_autocmd("FocusLost", {
    group = layout_group,
    callback = function()
      if poll then
        poll:stop()
      end
      -- Restore whatever was active before we forced US, so switching away
      -- from nvim doesn't leave you stuck on English in the next app. Not
      -- gated on terminal_is_frontmost() — by definition focus just left,
      -- so that check would always read false here; this fires once, tied
      -- directly to a real FocusLost event, not a recurring background
      -- poll, so it doesn't carry the same risk the poll gate protects
      -- against.
      if saved_layout then
        vim.system({ "macism", saved_layout, "0" })
        saved_layout = nil
      end
    end,
  })

  -- this file loads on VeryLazy, which fires after the real VimEnter already
  -- happened, so a VimEnter autocmd here would never see it. Cover "already
  -- Cyrillic when nvim started, terminal already focused" by just running
  -- the same focus-gated check once at load time instead.
  force_us()
end
