-- シンタックスハイライトを有効化
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

local options = {
  -- encoding
  encoding = "utf-8",
  fileencoding = "utf-8",

  -- 24bit color
  termguicolors = true,

  -- statusline
  laststatus = 3,
  showcmd = true,
  cmdheight = 2,
  showtabline = 2,
  showmode = false,
  ruler = true,
  inccommand = "split",

  -- disable intro message
  shortmess = "I",

  -- line
  number = true,
  numberwidth = 4,
  relativenumber = true,
  signcolumn = "number",
  cursorline = true,

  -- help
  helplang = "ja",

  -- backup, swap
  backup = false,
  swapfile = false,

  -- enable goto end of line
  virtualedit = "onemore,block",

  -- mouse
  mouse = "a",

  -- indent
  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  smartindent = true,
  autoindent = true,

  -- editor
  -- ambiwidth = 'double',
  scrolloff = 4,

  -- search
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  hlsearch = false,

  -- completion (Neovim 0.12 組み込み補完)
  autocomplete = true,
  -- .wbu=バッファ。^5 は各ソースの件数上限。
  -- omnifunc(o) は入れない。空プレフィックスでスコープ内の全シンボルが
  -- 流れ込むため。LSP は vim.lsp.completion の autotrigger に任せる
  complete = ".^5,w^5,b^5,u^5",
  -- 既定の 0 だと打鍵ごとに即メニューが開く。タイプ速度より少し上に置く
  autocompletedelay = 150,
  -- 0 だと画面いっぱいまで伸びる
  pumheight = 10,
  pumborder = "rounded",
  -- menu が無いと noselect/noinsert が機能せず候補が直接挿入される。
  -- noselect は 'autocomplete' 時に自動付与されるが、lsp-completion のヘルプが
  -- 明示を推奨しているので書いておく
  completeopt = "menu,menuone,popup,fuzzy,noselect",

  -- manipulation
  clipboard = "unnamedplus",
  shell = "fish",

  -- key sequence timeout (for jj, jk etc.)
  timeoutlen = 300,

  -- show invisible characters
  list = true,
  listchars = {
    tab = "» ",
    nbsp = "␣",
    eol = "↲",
    extends = "›",
    precedes = "‹",
    lead = "·",
    trail = "·",
  },
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#553311" })
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.hl.on_yank({ higroup = "YankHighlight", timeout = 200 })
  end,
})

-- CLAUDE.md などをmarkdownとして認識
vim.filetype.add({
  filename = {
    ["CLAUDE.md"] = "markdown",
  },
})
