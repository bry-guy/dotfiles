call plug#begin('~/.vim/plugged')
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

Plug 'mfussenegger/nvim-jdtls'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

Plug 'vimwiki/vimwiki'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } },
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
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

" Plug 'plasticboy/vim-markdown'

Plug 'editorconfig/editorconfig-vim'

Plug 'epwalsh/obsidian.nvim'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'hashivim/vim-terraform'

Plug 'NoahTheDuke/vim-just'

call plug#end()
