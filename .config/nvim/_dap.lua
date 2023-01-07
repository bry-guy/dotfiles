local dap = require('dap')

vim.api.nvim_set_keymap('n', '<leader>dx', "<cmd>lua require'dap'.continue()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ds', "<cmd>lua require'dap'.step_over()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>di', "<cmd>lua require'dap'.step_into()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>do', "<cmd>lua require'dap'.step_out()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>db', "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dB', "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dp', "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dr', "<cmd>lua require'dap'.repl.open()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dl', "<cmd>lua require'dap'.run_last()<CR>", { noremap = true })

require("mason-nvim-dap").setup({
	ensure_installed = {
	  "javadbg",
	  "javatest",
	  "python",
	},
	automatic_setup = {}
})

require("mason-nvim-dap").setup_handlers({
  function(source_name)
	require('mason-nvim-dap.automatic_setup')(source_name)
  end,
  python = function(_)
	dap.adapters.python = {
	  type = "executable",
	  command = "/usr/bin/python3",
	  args = {
		"-m",
		"debugpy.adapter",
	  },
	}

	dap.configurations.python = {
	  {
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}", -- This configuration will launch the current file if used.
	  },
	}
  end,
})

dap.configurations.java = {
  {
    type = 'java';
    request = 'attach';
    name = "Attach";
    hostName = "127.0.0.1";
	port = 5005;
  },
}

require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
require('dap-python').test_runner = 'pytest'

-- TODO: Move these to a python filetype setup
-- vim.api.nvim_set_keymap('n', '<leader>dn', "<cmd>lua require('dap-python').test_method()<CR>", { noremap = true })
-- vim.api.nvim_set_keymap('n', '<leader>dc', "<cmd>lua require('dap-python').test_class()<CR>", { noremap = true })
-- vim.api.nvim_set_keymap('v', '<leader>dv', "<ESC><cmd>lua require('dap-python').debug_selection()<CR>", { noremap = true })

require('telescope').load_extension('dap')

vim.api.nvim_set_keymap('n', '<leader>dm', "<cmd>lua require'telescope'.extensions.dap.commands{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dg', "<cmd>lua require'telescope'.extensions.dap.configurations{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dL', "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dv', "<cmd>lua require'telescope'.extensions.dap.variables{}<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>df', "<cmd>lua require'telescope'.extensions.dap.frames{}<CR>", { noremap = true })

