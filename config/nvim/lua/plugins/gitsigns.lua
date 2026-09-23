return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>gb", "<cmd>Gitsigns blame<cr>", desc = "Blame file" },
    { "<leader>gt", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      -- blame ウィンドウと、そこから s/S で開く commit バッファ (gitsigns://...) を q で閉じる
      pattern = { "gitsigns-blame", "git" },
      callback = function(ev)
        if ev.match == "git" and not vim.api.nvim_buf_get_name(ev.buf):match("^gitsigns://") then
          return
        end
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, desc = "Close" })
      end,
    })
  end,
  opts = {
    signs = {
      add = { text = "┃" },
      change = { text = "x" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
      untracked = { text = "┆" },
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false,   -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false,  -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      follow_files = true,
    },
    auto_attach = true,
    attach_to_untracked = false,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
    },
    current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    preview_config = {
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
  },
}
