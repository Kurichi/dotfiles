return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    {
      "<leader>gc",
      function()
        local file = vim.api.nvim_buf_get_name(0)
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local out = vim.fn.systemlist({
          "git", "-C", vim.fn.fnamemodify(file, ":h"),
          "blame", "-L", line .. "," .. line, "--porcelain", "--", file,
        })
        local sha = vim.v.shell_error == 0 and out[1] and out[1]:match("^(%x+)") or nil
        if not sha then
          vim.notify("git blame failed", vim.log.levels.WARN)
          return
        end
        if sha:match("^0+$") then
          vim.notify("Not committed yet", vim.log.levels.WARN)
          return
        end
        vim.cmd("DiffviewOpen " .. sha .. "^!")
      end,
      desc = "Show commit of current line",
    },
  },
  opts = {
    enhanced_diff_hl = true,
    keymaps = {
      view = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
      file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
      file_history_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
    },
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_mixed" },
    },
  },
}
