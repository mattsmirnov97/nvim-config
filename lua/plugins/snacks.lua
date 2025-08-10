return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
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
