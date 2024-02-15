-- https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', {noremap = true})
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', {noremap = true})
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', {noremap = true})
vim.api.nvim_set_keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", {noremap = true})
vim.api.nvim_set_keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", {noremap = true})

-- switch to previous buffer then delete the new-previous buffer
vim.api.nvim_set_keymap('n', '\\x', ':bp<cr>:bd #<cr>', {noremap = true})

vim.api.nvim_set_keymap('n', '<leader>yp', [[:let @+=expand('%:p:h')<CR>]], {noremap = true})

