local dap = require('dap')
dap.configurations.java = {
  {
    type = 'java';
    request = 'attach';
    name = "Attach";
    hostName = "127.0.0.1";
	port = 5005;
  },
}

-- require('dap-python').test_runner = 'pytest'
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
require('dap-python').test_runner = 'pytest'

vim.api.nvim_set_keymap('n', '<leader>dn', "<cmd>lua require('dap-python').test_method()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dl', "<cmd>lua require('dap-python').test_class()<CR>", { noremap = true })
vim.api.nvim_set_keymap('v', '<leader>ds', "<ESC><cmd>lua require('dap-python').debug_selection()<CR>", { noremap = true })

require('telescope').load_extension('dap')

vim.api.nvim_set_keymap('n', '<leader>dc', "<cmd>lua require'telescope'.extensions.dap.commands{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dg', "<cmd>lua require'telescope'.extensions.dap.configurations{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>db', "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dv', "<cmd>lua require'telescope'.extensions.dap.variables{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dr', "<cmd>lua require'telescope'.extensions.dap.frames{}", { noremap = true })

