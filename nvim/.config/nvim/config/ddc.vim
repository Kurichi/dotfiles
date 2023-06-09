call ddc#custom#patch_global('sources', ['nvim-lsp', 'around', 'vsnip'])
call ddc#custom#patch_global('sourceOptions', {
     \ '_': {
     \ 'matchers': ['matcher_head'],
     \ 'sorters': ['sorter_rank'],
     \ 'converters': ['converter_remove_overlap'],
     \ },
     \ 'around': {'mark': 'A'},
     \ 'nvim-lsp': {
     \ 'mark': 'L',
     \ 'forceCompletionPattern': '\.\w*|:\w*|->\w*',
     \ },
     \ })

call ddc#custom#patch_global('sourceParams', {
     \ 'around': {'maxSize': 500},
     \ })

inoremap <silent><expr> <TAB>
     \ ddc#map#pum_visible() ? '<C-n>' :
     \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
     \ '<TAB>' : ddc#map#manual_complete()
inoremap <expr><S-TAB>  ddc#map#pum_visible() ? '<C-p>' : '<C-h>'

call ddc#enable()

imap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'
imap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'
imap <expr> <C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-f>'
smap <expr> <C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-f>'
imap <expr> <C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-b>'
smap <expr> <C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-b>'
let g:vsnip_filetypes = {}

