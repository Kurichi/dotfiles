let mapleader = "\<Space>"

" バックアップファイルを作らない
set nobackup

" スワップファイルを作らない
set noswapfile

" 編集中のファイルが変更されたら自動で読み直す
set autoread

" バッファが編集中でもその他のファイルを開けるように
set hidden

" 入力中のコマンドをステータスに表示する
set showcmd

" init.vimを保存したら自動反映
autocmd BufWritePost ~/.config/nvim/init.vim so ~/.config/nvim/init.vim

" インデント可視化
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%

" エンコーディング
set encoding=utf-8
scriptencoding utf-8

" j,jでEsc
inoremap <silent> jj <Esc>
inoremap <silent> っj <Esc>

" 行番号の表示
set number

" help日本語化
set helplang=ja

" 現在の行を強調表示
set cursorline

" 現在の行を強調表示（縦）
set cursorcolumn

" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore

" スマートインデント
set smartindent

" ビープ音を可視化
set visualbell

" 括弧入力時の対応する括弧を表示
set showmatch

" ステータスラインを常に表示
set laststatus=2

" コマンドラインの補完
set wildmode=list:longest

" 繰り返し時に表事業単位での移動できるようにする
nnoremap j gj
nnoremap k gk

" シンタックスハイライトの有効化
syntax enable

" Tabを半角スペースにする
set expandtab

" 行頭以外のTabの表示幅
set tabstop=2

" 行頭でのTabの表示幅
set shiftwidth=2

" 改行時に自動でインデント
set autoindent

" 検索文字列が小文字の場合は大文字小文字を区別しない
set ignorecase

" 検索文字列に大文字が含まれている場合は区別
set smartcase

" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch

" 検索時に最後まで行ったら最初に戻る
set wrapscan

" 検索語をハイライト表示
set hlsearch

" Esc Escでハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 挿入モードでバックスペースで削除可能に
set backspace=indent,eol,start

" 自動でカッコを閉じる
inoremap { {}<LEFT>

" 棒状カーソル
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
inoremap <Esc> <Esc>lh

" ヤンクとクリップボードの同期
set clipboard+=unnamed

nnoremap <silent><C-e> :NERDTreeToggle<CR>
