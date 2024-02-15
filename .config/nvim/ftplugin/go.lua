-- indenting options
vim.opt_local.autoindent = true
vim.opt_local.si = true -- smart indent
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 4

vim.api.nvim_set_keymap('n', '<leader>dt', "<cmd>lua require('dap-go').debug_test()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dtl', "<cmd>lua require('dap-go').debug_last_test()<CR>", { noremap = true })

