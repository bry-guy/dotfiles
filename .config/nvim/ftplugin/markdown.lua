-- ftplugin/markdown.lua
-- Never insert hard newlines automatically; visual wrapping is handled by `wrap`.
vim.opt_local.textwidth = 0
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true

-- Keep Markdown plain and unwrapped while editing. Use Glow in the terminal
-- for a rendered reading view.
vim.opt_local.wrap = false
vim.opt_local.linebreak = false
vim.opt_local.breakindent = false
vim.opt_local.conceallevel = 0
vim.opt_local.concealcursor = ""

