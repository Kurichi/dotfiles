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

-- LSP keymaps (neovim only, not vscode-neovim)
if not vim.g.vscode then
  keymap("n", "<Leader>,", vim.lsp.buf.code_action, opts)
  keymap("n", "<Leader>r", vim.lsp.buf.rename, opts)
end

-- Insert --
keymap("i", "jj", "<Esc>", opts)
keymap("i", "jk", "<Esc>", opts)

-- Visual --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "H", "^", opts)
keymap("v", "L", "$", opts)

if not vim.g.vscode then
  keymap("v", "<Leader>,", vim.lsp.buf.code_action, opts)
end
