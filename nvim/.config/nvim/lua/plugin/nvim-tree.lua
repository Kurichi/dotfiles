vim.api.nvim_set_var('loaded_netrw', 1)
vim.api.nvim_set_var('loaded_netrwPlugin', 1)

require('nvim-tree').setup {
  sort_by = 'extension',
  disable_netrw = true,

  view = {
    width = '15%',
  },
}

vim.keymap.set('n', '<Leader>e', vim.cmd.NvimTreeToggle)

