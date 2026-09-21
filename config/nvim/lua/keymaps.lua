local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.keymap.set

-- <Leader> を <Space> にする
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- LSP keymaps (neovim only, not vscode-neovim)
if not vim.g.vscode then
  keymap("n", "<Leader>,", vim.lsp.buf.code_action, opts)
  keymap("n", "<Leader>r", vim.lsp.buf.rename, opts)
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
