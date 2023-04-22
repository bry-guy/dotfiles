if (has("termguicolors"))
	set termguicolors
endif

let g:bgUnderlineMatchParen = 1
let g:bgCursorColor = 1
let g:bgVertSplits = 0

colorscheme moonfly
let g:lightline = { 'colorscheme': 'moonfly' }

" augroup CustomHighlight
"     autocmd!
"     autocmd ColorScheme moonfly background Function guifg=#74b2ff gui=bold
" augroup END

hi Visual term=reverse cterm=reverse guibg=DarkMagenta
