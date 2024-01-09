local options = {
  -- Editor
  ambiwidth = 'double', 
  tabstop = 2, 
  softtabstop = 2, 
  shiftwidth = 2, 
  expandtab = true, 
  autoindent = true, 
  smartindent = true, 
  virtualedit = 'onemore', 
  scrolloff = 4,

  -- Files
  encoding = 'utf-8',
  fileencoding = 'utf-8',

  -- Visual
  number = true, 
  relativenumber = true, 
  numberwidth = 4, 
  showcmd = true, 
  cmdheight = 2, 
  showtabline = 2,
  showmode = false, 
  ruler = true, 
  cursorline = true, 
  termguicolors = true, 
  inccommand = 'split',

  -- Search
  incsearch = true, 
  ignorecase = true, 
  smartcase = true, 
  hlsearch = true, 

  -- Manipulation
  clipboard = 'unnamedplus',
  shell = 'fish', 
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
