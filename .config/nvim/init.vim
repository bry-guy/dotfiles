" https://afnan.io/posts/2018-04-12-my-neovim-development-setup/
for f in split(glob('~/.config/nvim/_*.vim'), '\n')
		echo f
	exe 'source' f
endfor

" nvim settings
filetype on 
filetype plugin on 

set relativenumber
set nu rnu

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

