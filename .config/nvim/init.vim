" https://afnan.io/posts/2018-04-12-my-neovim-development-setup/
for f in split(glob('~/.config/nvim/_*'), '\n')
		exe 'source' f
endfor

" nvim settings
filetype on 
filetype indent plugin on 
syntax on
set autowrite " save on :make commands

set nu " see vim-numbertoggle

set scrolloff=5

" typesetting defaults 
set tabstop=4
set softtabstop=4
set signcolumn=yes

set hidden
set ignorecase
set smartcase

set noswapfile

" tab settings
set splitbelow
set splitright

" key timeouts
set timeoutlen=1000
set ttimeoutlen=5

" yank to unnamed register always (clipboard)
" set clipboard=unnamedplus

set encoding=utf-8

" filetype overrides
au BufRead,BufNewFile *.cls,*.trigger set filetype=apexcode
