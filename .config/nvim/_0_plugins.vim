call plug#begin('~/.vim/plugged')
Plug 'neovim/nvim-lspconfig'

Plug 'mfussenegger/nvim-jdtls'

Plug 'vimwiki/vimwiki'
" Plug 'michal-h21/vim-zettel'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } },
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'bluz71/vim-moonfly-colors'
Plug 'bry-guy/vim-bg-colors'

Plug 'itchyny/lightline.vim'

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rails'

Plug 'vim-test/vim-test'

Plug 'duggiefresh/vim-easydir'

Plug 'jeffkreeftmeijer/vim-numbertoggle'

Plug 'reedes/vim-pencil'

Plug 'plasticboy/vim-markdown'
call plug#end()
