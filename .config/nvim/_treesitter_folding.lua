-- https://www.jmaguire.tech/posts/treesitter_folding/
-- Configure folding via treesitter
local opt = vim.opt
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

augroup('open_folds', { clear = true })

autocmd('BufReadPost', {
  group = 'open_folds',
  pattern = '*',
  command = "normal zR"
})

autocmd('FileReadPost', {
  group = 'open_folds',
  pattern = '*',
  command = "normal zR"
})

autocmd('BufEnter', {
  group = 'open_folds',
  pattern = '*',
  command = "normal zx"
})

-- -- Configure pretty folding via pretty-fold.nvim
-- require('pretty-fold').setup()

