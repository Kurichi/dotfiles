return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_mixed" },
    },
  },
}
