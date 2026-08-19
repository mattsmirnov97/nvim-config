return {
  {
    "fei6409/log-highlight.nvim",
    ft = "log",
    config = function()
      require("log-highlight").setup({})

      -- log-highlight ships a classic ftdetect/log.vim (`set filetype=log`)
      -- that loads eagerly and unconditionally overwrites snacks.bigfile's
      -- own detection, so huge .log files were silently losing bigfile's
      -- perf guards (treesitter foldexpr + matchparen stayed on). Reapply
      -- them here, using the same thresholds as snacks.bigfile.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "log",
        group = vim.api.nvim_create_augroup("log_highlight_bigfile", { clear = true }),
        callback = function(ev)
          local path = vim.api.nvim_buf_get_name(ev.buf)
          if path == "" then
            return
          end
          local size = vim.fn.getfsize(path)
          if size <= 0 then
            return
          end
          local lines = vim.api.nvim_buf_line_count(ev.buf)
          local is_big = size > 1.5 * 1024 * 1024 or (size - lines) / lines > 1000
          if not is_big then
            return
          end
          if vim.fn.exists(":NoMatchParen") ~= 0 then
            vim.cmd("NoMatchParen")
          end
          vim.wo.foldmethod = "manual"
          vim.wo.conceallevel = 0
          vim.wo.statuscolumn = ""

          -- snacks.bigfile's own (losing) detection pass queued a deferred
          -- `buf.syntax = "bigfile"` (a filetype name, not a real syntax
          -- file) right before this autocmd ran, which wipes out log
          -- highlighting. Re-force it back to "log", scheduled so it runs
          -- after that stale callback.
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
              vim.bo[ev.buf].syntax = "log"
            end
          end)
        end,
      })
    end,
  },
}
