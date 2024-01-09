vim.g.copilot_no_tab_map = true

local keymap = vim.api.nvim_set_keymap
keymap( 'i', '<C-i>', 'copilot#Accept("<CR>")', {silent = true, expr = true, script = true, replace_keycodes = false })
keymap( 'i', '<C-j>', '<Plug>(copilot-next)' , {})
keymap( 'i', '<C-k>', '<Plug>(copilot-previous)', {} )
keymap( 'i', '<C-o>', '<Plug>(copilot-dismiss)', {} )
keymap( 'i', '<C-s>', '<Plug>(copilot-suggest)', {} )

