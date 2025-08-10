return {
  {
    "folke/snacks.nvim",
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
              list = {
                keys = {
                  ["y"] = "fs_yank",
                  ["x"] = "fs_cut",
                  ["p"] = "fs_paste",
                  ["v"] = "edit_vsplit",
                  ["s"] = "edit_split",
                },
              },
            },
          },
        },
      },
    },
  },
}
