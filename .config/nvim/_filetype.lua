-- https://neovim.discourse.group/t/introducing-filetype-lua-and-a-call-for-help/1806
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

-- see vim.filetype.add() help
vim.filetype.add({
  extension = {
	md = 'markdown',
	MD = 'markdown',
  },
  pattern = {
	['.*/.github/workflows/.*'] = 'yaml.actions',
  },
})

