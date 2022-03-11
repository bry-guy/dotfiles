" https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" switch to previous buffer then delete the new-previous buffer
nnoremap \x :bp<cr>:bd #<cr>

" exit terminal-mode
:tnoremap <Esc> <C-\><C-n>

" vim.fzf search word under cursor
nnoremap <silent> <Leader>rg :Rg <C-R><C-W><CR>
