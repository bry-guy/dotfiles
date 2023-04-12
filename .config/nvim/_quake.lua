-- nnoremap <F4> :Nuake<CR>
-- inoremap <F4> <C-\><C-n>:Nuake<CR>
-- tnoremap <F4> <C-\><C-n>:Nuake<CR>

-- let g:nuake_position = {position} (default 'bottom')	Set the Nuake position to 'bottom', 'right', 'top' or 'left'.
-- let g:nuake_size = {0-1} (default 0.25)	Set the Nuake size in percent.
-- let g:nuake_per_tab = {0,1} (default 0)	Enable the Nuake instance per tab page.
-- let g:close_if_last_standing = {0,1} (default 1)	Close the editor if the Nuake window is the last one.
-- let g:start_insert = {0,1} (default 1)	Enter insert mode when opening Nuake.

vim.keymap.set('n', '<leader>q', '<Cmd>:Nuake<CR>')
