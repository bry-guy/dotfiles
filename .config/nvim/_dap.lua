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

require('telescope').load_extension('dap')

vim.api.nvim_set_keymap('n', '<leader>dc', "lua require'telescope'.extensions.dap.commands{}", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dg', "lua require'telescope'.extensions.dap.configurations{}", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>db', "lua require'telescope'.extensions.dap.list_breakpoints{}", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>dv', "lua require'telescope'.extensions.dap.variables{}", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>df', "lua require'telescope'.extensions.dap.frames{}", { noremap = true })

-- UI
-- require("dapui").setup()

-- local dap, dapui = require("dap"), require("dapui")
-- dap.listeners.after.event_initialized["dapui_config"] = function()
--   dapui.open()
-- end
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   dapui.close()
-- end


