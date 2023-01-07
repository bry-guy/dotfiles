call plug#begin('~/.vim/plugged')
" Setup
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

" Editing
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
Plug 'mfussenegger/nvim-dap-python'

Plug 'jayp0521/mason-nvim-dap.nvim'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'terryma/vim-multiple-cursors'

" Theming
Plug 'bry-guy/vim-bg-colors'
Plug 'itchyny/lightline.vim'

" tpope
" Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rails'

" Utils
Plug 'vim-test/vim-test'
Plug 'duggiefresh/vim-easydir'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'reedes/vim-pencil'
Plug 'editorconfig/editorconfig-vim'
Plug 'epwalsh/obsidian.nvim'
Plug 'mechatroner/rainbow_csv'

Plug 'kikito/inspect.lua', { 'dir': '~/.config/nvim/lua/inspect.lua' }

Plug 'elihunter173/dirbuf.nvim'

" Language enhancers
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'hashivim/vim-terraform'
Plug 'NoahTheDuke/vim-just'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-dap.nvim'

Plug 'sudormrfbin/cheatsheet.nvim'

call plug#end()
