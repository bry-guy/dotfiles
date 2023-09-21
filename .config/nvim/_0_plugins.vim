call plug#begin('~/.vim/plugged')
" Setup
Plug 'williamboman/mason.nvim' 
		Plug 'williamboman/mason-lspconfig.nvim'
		Plug 'mfussenegger/nvim-dap'
		Plug 'jayp0521/mason-nvim-dap.nvim'

Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Debugging
Plug 'mfussenegger/nvim-jdtls'
Plug 'mfussenegger/nvim-dap-python'

" Linting
Plug 'mfussenegger/nvim-lint'

" Editing
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'anuvyklack/pretty-fold.nvim'

Plug 'terryma/vim-multiple-cursors'

" Testing
Plug 'vim-test/vim-test'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-vim-test'
Plug 'nvim-neotest/neotest-go'
Plug 'nvim-neotest/neotest-python'

" Theming
" Plug 'bry-guy/vim-bg-colors'
Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
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
Plug 'duggiefresh/vim-easydir'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'reedes/vim-pencil'
Plug 'editorconfig/editorconfig-vim'
Plug 'epwalsh/obsidian.nvim'
Plug 'mechatroner/rainbow_csv'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

Plug 'kikito/inspect.lua', { 'dir': '~/.config/nvim/lua/inspect.lua' }

Plug 'elihunter173/dirbuf.nvim'

Plug 'sudormrfbin/cheatsheet.nvim'

Plug 'ellisonleao/glow.nvim'

" Language enhancers
Plug 'hashivim/vim-terraform'
Plug 'NoahTheDuke/vim-just'
Plug 'ray-x/go.nvim'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-dap.nvim'
Plug 'chip/telescope-software-licenses.nvim'

" External Integrations
Plug 'pwntester/octo.nvim'
Plug 'nvim-tree/nvim-web-devicons'


" Plugin Development
Plug 'folke/neodev.nvim'


call plug#end()
