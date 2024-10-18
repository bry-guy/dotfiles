-- vim.keymap.set({"n", "x"},"<C-j>", "<Cmd>MultipleCursorsAddDown<CR>")
-- vim.keymap.set({"n", "x"},"<C-k>", "<Cmd>MultipleCursorsAddUp<CR>")
vim.keymap.set({"n", "i", "x"},"<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>")
vim.keymap.set({"n", "i", "x"},"<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>")
vim.keymap.set({"n", "i"},"<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>")
vim.keymap.set({"n", "x"},"<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>")

require('multiple-cursors').setup()
