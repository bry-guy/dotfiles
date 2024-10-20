function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" Looks better
" Plug 'benekastah/neomake', Cond(has('nvim'))
" With other options
" Plug 'benekastah/neomake', Cond(has('nvim'), { 'on': 'Neomake' })

call plug#begin('~/.vim/plugged')
if exists('g:vscode')

else
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
Plug 'leoluz/nvim-dap-go'

" Linting
Plug 'mfussenegger/nvim-lint'

" AI
Plug 'zbirenbaum/copilot.lua'

" Editing
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'dcampos/nvim-snippy'

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'brenton-leighton/multiple-cursors.nvim'

" Navigating
Plug 'stevearc/oil.nvim'

" Testing
Plug 'vim-test/vim-test'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'nvim-neotest/nvim-nio'
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-vim-test'
Plug 'nvim-neotest/neotest-go'
Plug 'nvim-neotest/neotest-python'

" Theming
" Plug 'bry-guy/vim-bg-colors'
Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
Plug 'itchyny/lightline.vim'

" 
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

Plug 'kikito/inspect.lua', { 'dir': '~/.config/nvim/lua/inspect.lua' }

Plug 'sudormrfbin/cheatsheet.nvim'

" Language enhancers
Plug 'hashivim/vim-terraform'
Plug 'NoahTheDuke/vim-just'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-dap.nvim'
Plug 'chip/telescope-software-licenses.nvim'

" External Integrations
Plug 'pwntester/octo.nvim'
Plug 'nvim-tree/nvim-web-devicons'


" Plugin Development
Plug 'folke/neodev.nvim'
endif

call plug#end()
