-- ftplugin/markdown.lua
vim.opt_local.textwidth=120
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true

-- Editing defaults: keep Markdown plain and unwrapped. Use <leader>vm to
-- temporarily enable reading mode with wrapping, conceal, and Markview.
vim.opt_local.wrap = false
vim.opt_local.linebreak = false
vim.opt_local.breakindent = false
vim.opt_local.conceallevel = 0
vim.opt_local.concealcursor = ""

