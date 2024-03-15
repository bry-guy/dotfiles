" https://www.swamphogg.com/2015/vim-setup/
" https://secluded.site/vim-as-a-markdown-editor/

" vim-markdown
" The following commands are useful to open and close folds:

"    zr: reduces fold level throughout the buffer
"    zR: opens all folds
"    zm: increases fold level throughout the buffer
"    zM: folds everything all the way
"    za: open a fold your cursor is on
"    zA: open a fold your cursor is on recursively
"    zc: close a fold your cursor is on
"    zC: close a fold your cursor is on recursively

autocmd FileType markdown setlocal spell spelllang=en_us
"   [s to search for misspelled words above the cursor
"   ]s to search for misspelled words below the cursor
"   z= to see replacement suggestions
"   zg to add the word to your dictionary

" autocmd FileType markdown set cursorline
autocmd FileType markdown setlocal conceallevel=2
" autocmd FileType markdown set linebreak " Have lines wrap instead of continue off-screen
autocmd FileType markdown setlocal expandtab " Converts tabs to spaces
autocmd FileType markdown setlocal tabstop=2 " Use two spaces instead of tabs
autocmd FileType markdown setlocal shiftwidth=2 " The same but for indents
autocmd FileType markdown setlocal scrolloff=12 " Keep cursor in approximately the middle of the screen
autocmd FileType markdown setlocal mouse= " Disable mouse support

" vim-markdown
let g:vim_markdown_conceal = 2
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_follow_anchor = 1

" vim-pencil
let g:pencil#textwidth = 120

augroup pencil
  autocmd!
  autocmd FileType markdown,md,mkd	call pencil#init({'wrap': 'soft'})
  " autocmd FileType text				call pencil#init({'wrap': 'hard', 'autoformat': 1})
augroup END

" goyo
let g:goyo_width = 120

" limelight
let g:limelight_paragraph_span = 1

" glow

lua << EOF
require('glow').setup({
  -- glow_path = "", -- will be filled automatically with your glow bin in $PATH, if anyglow
  -- install_path = "~/.local/bin", -- default path for installing glow binary
  -- border = "shadow", -- floating window border config
  -- style = "dark|light", -- filled automatically with your current editor background, you can override using glow json style
  -- pager = false,
  width = 180,
  height = 100,
  width_ratio = 0.85, -- maximum width of the Glow window compared to the nvim window size (overrides `width`)
  height_ratio = 0.85,
})
EOF
