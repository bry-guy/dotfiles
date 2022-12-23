vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local dirbuf = require("dirbuf")

dirbuf.setup {
  sort_order = "directories_first",
  write_cmd = "DirbufSync -confirm"
}

function Navigation_open(cmd)
  if vim.bo.filetype ~= 'dirbuf' then
	return nil
  end

  dirbuf.enter(cmd)
end

vim.api.nvim_set_keymap('n', '_', ':DirbufQuit <CR>', {})
-- TODO: Make these openable via splits with better commands (can't overwrite <C-v>!)
-- vim.api.nvim_set_keymap('n', '<C-">', '<cmd>lua Navigation_open("vsplit")<CR>', {})
-- vim.api.nvim_set_keymap('n', '<C-%>', '<cmd>lua Navigation_open("split")<CR>', {})
