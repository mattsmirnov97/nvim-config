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

-- Visual: Tab -> indent, Shift-Tab -> outdent
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent selection", silent = true })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Outdent selection", silent = true })

-- Shift+Left/Right: stop at both the start AND end of each identifier,
-- treating punctuation (`,`, `&`, `{`, `.` ...) as a separator to skip over,
-- never as a stop of its own. Native `w`/`e`/`b`/`ge` don't work for this:
-- they treat a punctuation run as its own "word" (their 3-way blank/keyword/
-- other model), so e.g. right after `userID,` a plain `w`/`e` stops on the
-- comma itself, which then throws the *next* press straight to the end of
-- the following identifier and skips its start entirely. `\<` / `\>` are
-- vim's actual keyword-boundary regex atoms (as opposed to the word/WORD
-- classes `w`/`e`/`b`/`ge` use) and ignore punctuation by construction, so
-- searching on those instead is what makes this correct rather than a patch
-- of special cases.
--
-- The cursor model here is "a gap between two characters" (how insert mode
-- actually renders it), not "sitting on a character" (how normal mode's
-- block cursor looks): `prv`/`cur` are the characters immediately to the
-- left/right of that gap. "End of word" therefore means prv is a keyword
-- char and cur isn't — i.e. positioned right after the last letter, not on
-- it — since landing ON the last letter puts an insert-mode edit one
-- character short of where typing should actually continue.
--
-- charcol()/strcharpart() (not col()/string indexing) so this is correct on
-- multibyte text (Cyrillic etc.), not just ASCII.
local function is_kw(ch)
  return ch ~= "" and vim.fn.match(ch, [[\k]]) == 0
end

local function at_word_start()
  local line = vim.fn.getline(".")
  local ccol = vim.fn.charcol(".")
  local cur = vim.fn.strcharpart(line, ccol - 1, 1)
  local prv = ccol >= 2 and vim.fn.strcharpart(line, ccol - 2, 1) or ""
  return is_kw(cur) and not is_kw(prv)
end

local function at_word_end()
  local line = vim.fn.getline(".")
  local ccol = vim.fn.charcol(".")
  local cur = vim.fn.strcharpart(line, ccol - 1, 1)
  local prv = ccol >= 2 and vim.fn.strcharpart(line, ccol - 2, 1) or ""
  return is_kw(prv) and not is_kw(cur)
end

local function smart_word_right()
  if at_word_end() then
    vim.fn.search([[\<]], "W")
  else
    vim.fn.search([[\>]], "W")
  end
end

local function smart_word_left()
  if at_word_start() then
    vim.fn.search([[\>]], "bW")
  else
    vim.fn.search([[\<]], "bW")
  end
end

map({ "n", "i" }, "<S-Right>", smart_word_right, { desc = "Word right (stop at end, then next start)", silent = true })
map({ "n", "i" }, "<S-Left>", smart_word_left, { desc = "Word left (stop at start, then prev end)", silent = true })
