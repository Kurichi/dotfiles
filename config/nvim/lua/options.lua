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
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 200 })
  end,
})

-- CLAUDE.md などをmarkdownとして認識
vim.filetype.add({
  filename = {
    ["CLAUDE.md"] = "markdown",
  },
})
