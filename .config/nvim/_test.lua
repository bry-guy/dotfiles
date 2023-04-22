-- neotest
require("neotest").setup({
  adapters = {
    require("neotest-vim-test")({
	  allow_file_types = { "java" }
	}),
	require("neotest-go"),
	require("neotest-python")({
      -- dap = { justMyCode = false },
    })
  },
  log_level = vim.log.levels.DEBUG
})

-- neotest keymaps
vim.keymap.set('n', '<leader>tn', '<Cmd>lua require("neotest").run.run()<CR>')
vim.keymap.set('n', '<leader>tf', '<Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>')
vim.keymap.set('n', '<leader>ts', '<Cmd>lua require("neotest").run.run(vim.fn.getcwd())<CR>')
vim.keymap.set('n', '<leader>tl', '<Cmd>lua require("neotest").run.run_last()<CR>')
vim.keymap.set('n', '<leader>tt', '<Cmd>lua require("neotest").output_panel.toggle()<CR>')
vim.keymap.set('n', '<leader>tT', '<Cmd>lua require("neotest").summary.toggle()<CR>')

vim.keymap.set('n', '[t', '<Cmd>lua require("neotest").jump.prev({ status = "failed" })<CR>')
vim.keymap.set('n', ']t', '<Cmd>lua require("neotest").jump.next({ status = "failed" })<CR>')


-- vim-test keymaps
-- vim.api.nvim_set_keymap('n', '<leader>Tn', ':TestNearest<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>tf', ':TestFile<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>ts', ':TestSuite<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>tl', ':TestLast<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>tv', ':TestVisit<CR>', { noremap = true })

-- vim-test
vim.g['test#neovim#start_normal'] = 1
vim.g['test#strategy'] = 'neovim'

