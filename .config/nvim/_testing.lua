vim.api.nvim_set_keymap('n', '<leader>tn', ':TestNearest<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tf', ':TestFile<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ts', ':TestSuite<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tl', ':TestLast<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tv', ':TestVisit<CR>', { noremap = true })

vim.g['test#neovim#start_normal'] = 1
vim.g['test#strategy'] = 'neovim'

-- TODO: Figure out how to make this work.
local function map_test_nearest_debug()
  vim.b['test#java#maventest#options'] = '-Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"'
  return ':TestNearest<CR>'
end

vim.api.nvim_set_keymap('n', '<leader>tdn', map_test_nearest_debug(), { noremap = true }) 
