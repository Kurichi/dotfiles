" Use windows clipboard.
set clipboard+=unnamedplus
let g:clipboard = {
  \   'name': 'win32yank-wsl',
  \   'copy': {
  \      '+': 'win32yank.exe -i --crlf',
  \      '*': 'win32yank.exe -i --crlf',
  \    },
  \   'paste': {
  \      '+': 'win32yank.exe -o --lf',
  \      '*': 'win32yank.exe -o --lf',
  \   },
  \   'cache_enabled': 0,
  \ }

" Auto disable ime.
if executable('zenhan')
  autocmd InsertLeave * :call system('zenhan 0')
  autocmd CmdlineLeave * :call system('zenhan 0')
endif


