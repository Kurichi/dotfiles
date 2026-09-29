local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.keymap.set

-- <Leader> を <Space> にする
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
-- <LocalLeader> は "," にする。<Leader> と同じだと octo.nvim のバッファローカルマップ
-- (<localleader>ca, <localleader>vd, <localleader>e, <localleader>b ...) が
-- <leader>ca (claudecode) / <leader>vd (review.nvim) / <leader>e / <leader>b と衝突する
vim.g.maplocalleader = ","

-- Normal --
keymap("n", "x", '"_x', opts)
keymap("n", "<Leader>d", '"_d', opts)
keymap("n", "Y", "y$", opts)
keymap("n", "H", "0", opts)
keymap("n", "L", "$", opts)
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "*", "*zz", opts)
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<CR>", opts)
keymap("n", "<Leader>w", ":w<CR>", opts)
keymap("n", "<Leader>h", "<C-w>h", opts)
keymap("n", "<Leader>j", "<C-w>j", opts)
keymap("n", "<Leader>k", "<C-w>k", opts)
keymap("n", "<Leader>l", "<C-w>l", opts)
keymap("n", "<Leader>b", "<C-o>", opts)

-- カーソル行の診断（上）と LSP ホバー（下）を 1 つのフロートに出す。
-- <Leader>e は nvim-tree のトグルなので K に集約している
local function diagnostic_and_hover()
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local lines = {}
  -- 診断メッセージの行範囲と色。診断は先頭に並べるので行番号はフロート内でもずれない
  local severity_hl = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticError",
    [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticHint",
  }
  local marks = {}

  local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })
  table.sort(diagnostics, function(a, b) return a.severity < b.severity end)
  for _, d in ipairs(diagnostics) do
    local origin = d.source and (" (" .. d.source .. (d.code and (": " .. d.code) or "") .. ")") or ""
    local msg = vim.split(d.message, "\n", { plain = true })
    msg[1] = ("[%s] %s"):format(vim.diagnostic.severity[d.severity], msg[1])
    msg[#msg] = msg[#msg] .. origin
    table.insert(marks, { first = #lines, last = #lines + #msg - 1, hl = severity_hl[d.severity] })
    vim.list_extend(lines, msg)
  end

  local function show(hover_lines)
    if #hover_lines > 0 then
      if #lines > 0 then
        vim.list_extend(lines, { "", "---" })
      end
      vim.list_extend(lines, hover_lines)
    end
    if #lines == 0 then
      return
    end
    local float_buf = vim.lsp.util.open_floating_preview(lines, "markdown", {
      border = "rounded",
      focus_id = "diagnostic_and_hover",
    })
    -- 2 回目の K（フォーカス移動）でも同じ内容なので、色は付け直して問題ない
    local ns = vim.api.nvim_create_namespace("diagnostic_and_hover")
    for _, m in ipairs(marks) do
      for l = m.first, m.last do
        -- Diagnostic* は fg のみ定義なので、行全体ではなくテキスト範囲に hl_group を当てる
        vim.api.nvim_buf_set_extmark(float_buf, ns, l, 0, { end_col = #lines[l + 1], hl_group = m.hl })
      end
    end
  end

  local win = vim.api.nvim_get_current_win()
  vim.lsp.buf_request_all(bufnr, "textDocument/hover", function(client)
    return vim.lsp.util.make_position_params(win, client.offset_encoding)
  end, function(results)
    local hover_lines = {}
    for _, res in pairs(results) do
      if res.result and res.result.contents then
        hover_lines = vim.lsp.util.convert_input_to_markdown_lines(res.result.contents, hover_lines)
      end
    end
    -- 空要素だけの結果は「ホバー無し」として扱う
    hover_lines = vim.split(vim.trim(table.concat(hover_lines, "\n")), "\n", { plain = true })
    if hover_lines[1] == "" then
      hover_lines = {}
    end
    show(hover_lines)
  end)
end

-- LSP keymaps (neovim only, not vscode-neovim)
if not vim.g.vscode then
  keymap("n", "<Leader>,", vim.lsp.buf.code_action, opts)
  keymap("n", "<Leader>r", vim.lsp.buf.rename, opts)
  keymap("n", "K", diagnostic_and_hover, opts)
end

-- Insert --
keymap("i", "jj", "<Esc>", opts)
keymap("i", "jk", "<Esc>", opts)

-- Completion (Neovim 0.12 組み込み補完)
-- 確定は必ず <C-y>。スニペット展開・auto-import・additionalTextEdits は
-- <C-y> 確定時の副作用として実行されるため、他のキーに割り当てると
-- 「補完は入るが import が付かない」状態になる
if not vim.g.vscode then
  -- <Tab>/<S-Tab> は 0.12 が既定でスニペットジャンプに割り当てているので
  -- 上書きする以上そのフォールバックは自前で維持する
  keymap({ "i", "s" }, "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      -- 'autocomplete' は候補を未選択で出すため、<C-y> だけでは何も入らない。
      -- 未選択なら先頭候補を選んでから確定する
      if vim.fn.complete_info({ "selected" }).selected == -1 then
        return "<C-n><C-y>"
      end
      return "<C-y>"
    end
    if vim.snippet.active({ direction = 1 }) then
      return "<Cmd>lua vim.snippet.jump(1)<CR>"
    end
    return "<Tab>"
  end, { expr = true, silent = true })

  keymap({ "i", "s" }, "<S-Tab>", function()
    if vim.snippet.active({ direction = -1 }) then
      return "<Cmd>lua vim.snippet.jump(-1)<CR>"
    end
    return "<S-Tab>"
  end, { expr = true, silent = true })

  keymap("i", "<C-j>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-j>"
  end, { expr = true, silent = true })

  keymap("i", "<C-k>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-k>"
  end, { expr = true, silent = true })

  -- Copilot のゴーストテキストを採用する。候補が無ければ本来の <C-f> に流す
  keymap("i", "<C-f>", function()
    if not vim.lsp.inline_completion.get() then
      return "<C-f>"
    end
  end, { expr = true, silent = true })
end

-- Visual --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "H", "^", opts)
keymap("v", "L", "$", opts)

if not vim.g.vscode then
  keymap("v", "<Leader>,", vim.lsp.buf.code_action, opts)
end
