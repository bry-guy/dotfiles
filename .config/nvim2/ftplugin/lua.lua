-- ftplugin files are loaded when ft= matches the filename, i.e. ft=lua
-- vim.opt_local options are only set for the current buffer
--
-- Set indentation to 2 spaces
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Enable auto-indentation
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true

-- Optional: Enable folding based on indentation
vim.opt_local.foldmethod = "indent"
vim.opt_local.foldlevelstart = 99

-- Optional: Disable wrapping for better code readability
vim.opt_local.wrap = false

-- Set the comment string to Lua's comment style
vim.opt_local.commentstring = "--%s"
