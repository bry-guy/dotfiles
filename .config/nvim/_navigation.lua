require("oil").setup({
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-s>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
  },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- dirbuf
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- local dirbuf = require("dirbuf")

-- dirbuf.setup {
--   sort_order = "directories_first",
--   write_cmd = "DirbufSync -confirm"
-- }

-- function Navigation_open(cmd)
--   if vim.bo.filetype ~= 'dirbuf' then
-- 	return nil
--   end

--   dirbuf.enter(cmd)
-- end

-- vim.api.nvim_set_keymap('n', '_', ':DirbufQuit <CR>', {})
-- TODO: Make these openable via splits with better commands (can't overwrite <C-v>!)
-- vim.api.nvim_set_keymap('n', '<C-">', '<cmd>lua Navigation_open("vsplit")<CR>', {})
-- vim.api.nvim_set_keymap('n', '<C-%>', '<cmd>lua Navigation_open("split")<CR>', {})
--
