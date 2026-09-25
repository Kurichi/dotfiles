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
    -- ,? で現在バッファのバッファローカルキーマップ一覧をフロートで出す。
    -- octo は PR / review diff / thread バッファに <localleader> 系のマップをバッファローカルで張るので、
    -- レビュー中に押せるキーの早見表になる（他プラグインのバッファでも同様に使える）
    local function show_buffer_keys()
      local seen, rows = {}, {}
      for _, mode in ipairs({ "n", "x" }) do
        for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
          if m.desc and m.desc ~= "" and not seen[m.lhs] then
            seen[m.lhs] = true
            rows[#rows + 1] = { lhs = m.lhs, desc = m.desc }
          end
        end
      end
      if #rows == 0 then
        vim.notify("No buffer-local keymaps in this buffer", vim.log.levels.INFO)
        return
      end
      table.sort(rows, function(a, b)
        return a.lhs < b.lhs
      end)

      local lhs_width = 0
      for _, r in ipairs(rows) do
        lhs_width = math.max(lhs_width, vim.fn.strdisplaywidth(r.lhs))
      end
      local lines, width = {}, 0
      for _, r in ipairs(rows) do
        local pad = string.rep(" ", lhs_width - vim.fn.strdisplaywidth(r.lhs))
        lines[#lines + 1] = " " .. r.lhs .. pad .. "  " .. r.desc .. " "
        width = math.max(width, vim.fn.strdisplaywidth(lines[#lines]))
      end

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
      vim.bo[buf].bufhidden = "wipe"
      local height = math.min(#lines, vim.o.lines - 4)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " Buffer keymaps ",
        title_pos = "center",
      })
      for _, k in ipairs({ "q", "<Esc>", "<localleader>?" }) do
        vim.keymap.set("n", k, function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true, desc = "Close" })
      end
    end
    vim.keymap.set("n", "<localleader>?", show_buffer_keys, { desc = "Show buffer keymaps" })

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
