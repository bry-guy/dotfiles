call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } },
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-vinegar'
Plug 'bluz71/vim-moonfly-colors'
call plug#end()
