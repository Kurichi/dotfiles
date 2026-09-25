return {
  "pwntester/octo.nvim",
  -- リリースタグが無いため commit で固定
  commit = "af2411604b51cb4a0f3e2de50b1b7cacc2581c48",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  keys = {
    { "<leader>gp", "<cmd>Octo pr<cr>", desc = "PR of current branch" },
    { "<leader>gr", "<cmd>Octo review<cr>", desc = "Review PR of current branch" },
    { "<leader>gP", "<cmd>Octo pr list<cr>", desc = "List PRs" },
  },
  init = function()
    -- PR / issue バッファは q で閉じる（diffview / gitsigns と同じ流儀）。
    -- review の右ペインは use_local_fs で実ファイル、thread バッファは layout を壊すので対象外
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "octo",
      callback = function(ev)
        local name = vim.api.nvim_buf_get_name(ev.buf)
        if not name:match("^octo://.-/pull/%d+$") and not name:match("^octo://.-/issue/%d+$") then
          return
        end
        vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = ev.buf, desc = "Close" })
      end,
    })
  end,
  opts = {
    picker = "telescope",
    enable_builtin = true,
    -- review 右ペインをワークツリーの実ファイルにして LSP (gd 等) を効かせる。
    -- PR の head ブランチをチェックアウト中のときだけ有効で、それ以外は octo:// バッファにフォールバックする
    use_local_fs = true,
    -- gh token に read:project が無い警告を抑止（Projects v2 は使わない）
    suppress_missing_scope = { projects_v2 = true },
  },
}
