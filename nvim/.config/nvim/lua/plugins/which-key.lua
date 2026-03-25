return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    icons = {
      mappings = false,
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Label leader key groups to match existing bindings
    wk.add({
      { "<leader>f", group = "find" },
      { "<leader>c", group = "code" },
    })
  end,
}
