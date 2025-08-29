return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fD",
        function()
          require("snacks").picker.grep({
            cwd = (require("lazyvim.util").root and require("lazyvim.util").root()) or vim.loop.cwd(),
          })
        end,
        desc = "Grep Text (root dir, Snacks)",
      },
      {
        "<leader>fd",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          if file == "" then
            return
          end
          local dir = vim.fs.dirname(file)
          local name = vim.fs.basename(file)

          require("snacks").picker.grep({
            cwd = dir,
            files = { name },
          })
        end,
        desc = "Grep Text (current dir, Snacks)",
      },
      {
        "<leader>fc",
        function()
          local file = vim.api.nvim_buf_get_name(0)
          if file == "" then
            return
          end
          local dir = vim.fs.dirname(file)
          local name = vim.fs.basename(file)

          require("snacks").picker.grep({
            cwd = dir,
            args = { "-g", name },
          })
        end,
        desc = "Fuzzy Text in Current Buffer (Snacks, only this file)",
      },
      {
        "<leader>fF",
        function()
          require("snacks").picker.files({
            cwd = "/",
          })
        end,
        desc = "Files (Filesystem root, Snacks)",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker.files({ cwd = vim.loop.cwd() })
        end,
        desc = "Files (cwd, Snacks)",
      },
    },
    opts = {
      picker = {
        sources = {
          explorer = {
            actions = {
              -- copy selection (files or directories)
              fs_yank = {
                desc = "Yank files/dirs",
                action = function(p, item)
                  local sel = p:selected()
                  local list = (#sel > 0) and sel or (item and { item } or {})
                  Snacks._fs_clipboard = { mode = "copy", items = {} }
                  for _, it in ipairs(list) do
                    if it.file then
                      table.insert(Snacks._fs_clipboard.items, it.file)
                    end
                  end
                  Snacks.notify.info("Yanked " .. #Snacks._fs_clipboard.items .. " item(s)")
                end,
              },
              -- cut (move) selection
              fs_cut = {
                desc = "Cut files/dirs",
                action = function(p, item)
                  local sel = p:selected()
                  local list = (#sel > 0) and sel or (item and { item } or {})
                  Snacks._fs_clipboard = { mode = "move", items = {} }
                  for _, it in ipairs(list) do
                    if it.file then
                      table.insert(Snacks._fs_clipboard.items, it.file)
                    end
                  end
                  Snacks.notify.info("Cut " .. #Snacks._fs_clipboard.items .. " item(s)")
                end,
              },
              -- paste into cwd or into dir under cursor
              fs_paste = {
                desc = "Paste files/dirs (into dir under cursor; if on file → its parent)",
                action = function(p, item)
                  local fn = vim.fn
                  local clip = Snacks._fs_clipboard
                  if not clip or not clip.items or #clip.items == 0 then
                    Snacks.notify.warn("Clipboard is empty")
                    return
                  end

                  local dest_dir
                  if item and item.file then
                    if fn.isdirectory(item.file) == 1 then
                      dest_dir = item.file
                    else
                      dest_dir = fn.fnamemodify(item.file, ":p:h")
                    end
                  else
                    dest_dir = (p and p.cwd and p:cwd()) or fn.getcwd()
                  end

                  for _, src in ipairs(clip.items) do
                    local base = fn.fnamemodify(src, ":t")
                    local dst = dest_dir .. "/" .. base
                    if clip.mode == "move" then
                      vim.system({ "mv", src, dst }):wait()
                    else
                      if fn.isdirectory(src) == 1 then
                        vim.system({ "cp", "-R", src, dst }):wait()
                      else
                        vim.system({ "cp", src, dst }):wait()
                      end
                    end
                  end

                  Snacks.notify.info(
                    string.format(
                      "%s %d item(s) → %s",
                      clip.mode == "move" and "Moved" or "Copied",
                      #clip.items,
                      dest_dir
                    )
                  )
                  Snacks._fs_clipboard = { mode = "copy", items = {} }
                  p:action("refresh")
                end,
              },
            },
            win = {
              input = {
                keys = {
                  ["<A-w>"] = function()
                    vim.cmd("wincmd k")
                  end,
                  ["<A-a>"] = function()
                    vim.cmd("wincmd h")
                  end,
                  ["<A-s>"] = function()
                    vim.cmd("wincmd j")
                  end,
                  ["<A-d>"] = function()
                    vim.cmd("wincmd l")
                  end,
                },
              },
              list = {
                keys = {
                  ["y"] = "fs_yank",
                  ["x"] = "fs_cut",
                  ["p"] = "fs_paste",
                  ["v"] = "edit_vsplit",
                  ["s"] = "edit_split",
                  ["<A-w>"] = function()
                    vim.cmd("wincmd k")
                  end,
                  ["<A-a>"] = function()
                    vim.cmd("wincmd h")
                  end,
                  ["<A-s>"] = function()
                    vim.cmd("wincmd j")
                  end,
                  ["<A-d>"] = function()
                    vim.cmd("wincmd l")
                  end,
                },
              },
            },
          },
        },
      },
    },
  },
}
